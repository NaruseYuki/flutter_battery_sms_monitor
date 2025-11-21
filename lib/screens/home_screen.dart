import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/battery_monitor_service.dart';
import '../services/sms_monitor_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _batteryService = BatteryMonitorService();
  final _smsService = SmsMonitorService();
  
  final _webhookController = TextEditingController();
  final _timeController = TextEditingController();
  final _thresholdController = TextEditingController();
  
  int _currentBatteryLevel = 0;
  bool _isMonitoring = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getCurrentBattery();
    _requestPermissions();
  }
  
  Future<void> _requestPermissions() async {
    await Permission.sms.request();
    await Permission.scheduleExactAlarm.request();
  }
  
  Future<void> _loadSettings() async {
    final settings = await _batteryService.getSettings();
    if (settings != null) {
      setState(() {
        _webhookController.text = settings['slackWebhookUrl'] ?? '';
        _timeController.text = settings['monitorTime'] ?? '';
        _thresholdController.text = settings['batteryThreshold']?.toString() ?? '';
        _isMonitoring = true;
      });
    }
  }
  
  Future<void> _getCurrentBattery() async {
    final level = await _batteryService.getCurrentBatteryLevel();
    setState(() {
      _currentBatteryLevel = level;
    });
  }
  
  Future<void> _saveSettings() async {
    final time = _timeController.text;
    final threshold = int.tryParse(_thresholdController.text);
    final webhook = _webhookController.text;
    
    if (time.isEmpty || threshold == null || webhook.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    
    // Validate time format (HH:MM) and values
    final timeRegex = RegExp(r'^(\d{2}):(\d{2})$');
    final match = timeRegex.firstMatch(time);
    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Time format should be HH:MM')),
      );
      return;
    }
    
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid time. Hours: 00-23, Minutes: 00-59')),
      );
      return;
    }
    
    await _batteryService.saveSettings(
      monitorTime: time,
      batteryThreshold: threshold,
      slackWebhookUrl: webhook,
    );
    
    await _batteryService.scheduleBatteryCheck(time);
    _smsService.startSmsMonitoring();
    
    setState(() {
      _isMonitoring = true;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved and monitoring started')),
      );
    }
  }
  
  Future<void> _stopMonitoring() async {
    await _batteryService.cancelBatteryCheck();
    _smsService.stopSmsMonitoring();
    setState(() {
      _isMonitoring = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monitoring stopped')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery & SMS Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Battery Level
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Current Battery Level',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_currentBatteryLevel%',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _getCurrentBattery,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Monitoring Status
            Card(
              color: _isMonitoring ? Colors.green.shade50 : Colors.grey.shade200,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isMonitoring ? Icons.check_circle : Icons.cancel,
                      color: _isMonitoring ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isMonitoring ? 'Monitoring Active' : 'Monitoring Inactive',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Settings Form
            const Text(
              'Monitor Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _webhookController,
              decoration: const InputDecoration(
                labelText: 'Slack Webhook URL',
                border: OutlineInputBorder(),
                hintText: 'https://hooks.slack.com/services/...',
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Monitor Time (HH:MM)',
                border: OutlineInputBorder(),
                hintText: '09:00',
              ),
              keyboardType: TextInputType.datetime,
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _thresholdController,
              decoration: const InputDecoration(
                labelText: 'Battery Alert Threshold (%)',
                border: OutlineInputBorder(),
                hintText: '20',
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save & Start Monitoring'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isMonitoring ? _stopMonitoring : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Stop Monitoring'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ Information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('• Battery level will be checked at the specified time daily'),
                    Text('• Alert will be sent if battery level is below the threshold'),
                    Text('• SMS messages will be automatically forwarded to Slack'),
                    Text('• Make sure to grant SMS and alarm permissions'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _smsService.stopSmsMonitoring();
    _webhookController.dispose();
    _timeController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }
}
