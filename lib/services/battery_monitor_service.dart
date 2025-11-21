import 'package:battery_plus/battery_plus.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/slack_api.dart';

class BatteryMonitorService {
  static const String _keyMonitorTime = 'monitor_time';
  static const String _keyBatteryThreshold = 'battery_threshold';
  static const String _keySlackWebhookUrl = 'slack_webhook_url';
  static const String _keyAlarmId = 'alarm_id';
  
  final Battery _battery = Battery();
  
  // Save monitoring settings
  Future<void> saveSettings({
    required String monitorTime,
    required int batteryThreshold,
    required String slackWebhookUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMonitorTime, monitorTime);
    await prefs.setInt(_keyBatteryThreshold, batteryThreshold);
    await prefs.setString(_keySlackWebhookUrl, slackWebhookUrl);
  }
  
  // Get monitoring settings
  Future<Map<String, dynamic>?> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final monitorTime = prefs.getString(_keyMonitorTime);
    final batteryThreshold = prefs.getInt(_keyBatteryThreshold);
    final slackWebhookUrl = prefs.getString(_keySlackWebhookUrl);
    
    if (monitorTime == null || batteryThreshold == null || slackWebhookUrl == null) {
      return null;
    }
    
    return {
      'monitorTime': monitorTime,
      'batteryThreshold': batteryThreshold,
      'slackWebhookUrl': slackWebhookUrl,
    };
  }
  
  // Schedule battery monitoring
  Future<void> scheduleBatteryCheck(String timeStr) async {
    // Parse time string (HH:MM)
    final parts = timeStr.split(':');
    if (parts.length != 2) return;
    
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    
    if (hour == null || minute == null) return;
    
    // Calculate the time until the next occurrence
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    
    // Cancel any existing alarm
    await AndroidAlarmManager.cancel(0);
    
    // Schedule the alarm
    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      0,
      batteryCheckCallback,
      startAt: scheduledTime,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }
  
  // Cancel battery monitoring
  Future<void> cancelBatteryCheck() async {
    await AndroidAlarmManager.cancel(0);
  }
  
  // Check battery level and send alert if needed
  static Future<void> batteryCheckCallback() async {
    final service = BatteryMonitorService();
    final settings = await service.getSettings();
    
    if (settings == null) return;
    
    final battery = Battery();
    final batteryLevel = await battery.batteryLevel;
    final threshold = settings['batteryThreshold'] as int;
    final webhookUrl = settings['slackWebhookUrl'] as String;
    
    if (batteryLevel <= threshold) {
      await service._sendBatteryAlert(batteryLevel, webhookUrl);
    }
  }
  
  // Send battery alert to Slack
  Future<void> _sendBatteryAlert(int batteryLevel, String webhookUrl) async {
    try {
      final dio = Dio();
      final api = SlackApi(dio, baseUrl: webhookUrl);
      
      final message = SlackMessage(
        text: '⚠️ Battery Alert: Battery level is low at $batteryLevel%',
      );
      
      await api.postMessage(message);
    } catch (e) {
      // Log error - in production, consider using a proper logging framework
      // ignore: avoid_print
      print('Failed to send battery alert: $e');
    }
  }
  
  // Get current battery level
  Future<int> getCurrentBatteryLevel() async {
    return await _battery.batteryLevel;
  }
}
