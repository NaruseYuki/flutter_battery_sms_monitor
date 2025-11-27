import 'dart:async';
import 'package:system_state/system_state.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/slack_api.dart';

// Scheduled time callback - sends current battery level to Slack (regardless of threshold)
@pragma('vm:entry-point')
Future<void> batteryCheckCallback() async {
  final service = BatteryMonitorService.internal();
  final settings = await service.getSettings();

  if (settings == null) {
    // ignore: avoid_print
    print('Battery monitoring settings not found.');
    return;
  }

  final webhookUrl = settings['slackWebhookUrl'] as String;

  // Get current battery level using system_state
  final batteryState = await SystemState.battery.getBattery();
  final batteryLevel = batteryState.level;

  // At scheduled time, always send current battery level to Slack (regardless of threshold)
  await service.sendScheduledBatteryReport(batteryLevel, webhookUrl);

  // Reschedule for the next day
  await service.scheduleBatteryCheck(settings['monitorTime']);

  // ignore: avoid_print
  print('Scheduled battery report completed. Level: $batteryLevel%.');
}

// ----------------------------------------------------------------------

class BatteryMonitorService {
  static const String _keyMonitorTime = 'monitor_time';
  static const String _keyBatteryThreshold = 'battery_threshold';
  static const String _keySlackWebhookUrl = 'slack_webhook_url';
  static const String _keyLowBatteryAlertSent = 'low_battery_alert_sent';
  static const int _batteryAlarmId = 0;

  StreamSubscription<BatteryState>? _batterySubscription;
  bool _isMonitoringRealtime = false;
  
  // Cached alert state to reduce SharedPreferences I/O
  bool? _cachedAlertSent;
  // Flag to prevent concurrent processing of battery state changes
  bool _isProcessingBatteryChange = false;

  // External instantiation
  BatteryMonitorService();

  // Internal constructor for callback functions (does not use _battery)
  BatteryMonitorService.internal();

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

  // Start real-time battery monitoring
  // Sends Slack alert immediately when battery falls below threshold (regardless of time)
  // Returns true if monitoring started successfully, false otherwise
  Future<bool> startRealtimeBatteryMonitoring() async {
    if (_isMonitoringRealtime) return true;

    final settings = await getSettings();
    if (settings == null) return false;

    final threshold = settings['batteryThreshold'] as int;
    final webhookUrl = settings['slackWebhookUrl'] as String;

    // Initialize cached alert state from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _cachedAlertSent = prefs.getBool(_keyLowBatteryAlertSent) ?? false;

    _isMonitoringRealtime = true;

    // Listen to battery state changes
    _batterySubscription = SystemState.battery.listen((batteryState) async {
      // Prevent concurrent processing of rapid battery state changes
      if (_isProcessingBatteryChange) return;
      _isProcessingBatteryChange = true;

      try {
        final batteryLevel = batteryState.level;

        // Send alert immediately when battery falls below threshold (regardless of time)
        if (batteryLevel < threshold && !(_cachedAlertSent ?? false)) {
          await sendBatteryAlert(batteryLevel, webhookUrl);
          _cachedAlertSent = true;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_keyLowBatteryAlertSent, true);
          // ignore: avoid_print
          print('Low battery alert sent. Level: $batteryLevel%');
        } else if (batteryLevel >= threshold && (_cachedAlertSent ?? false)) {
          // Reset alert flag when battery level recovers above threshold
          _cachedAlertSent = false;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_keyLowBatteryAlertSent, false);
        }
      } finally {
        _isProcessingBatteryChange = false;
      }
    });

    return true;
  }

  // Stop real-time battery monitoring
  void stopRealtimeBatteryMonitoring() {
    _batterySubscription?.cancel();
    _batterySubscription = null;
    _isMonitoringRealtime = false;
    _cachedAlertSent = null;
    _isProcessingBatteryChange = false;
  }

  // Schedule battery monitoring (one-shot)
  // At scheduled time, sends current battery level to Slack (regardless of threshold)
  Future<void> scheduleBatteryCheck(String timeStr) async {
    // Parse time string (HH:MM)
    final parts = timeStr.split(':');
    if (parts.length != 2) return;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // If scheduled time is in the past, schedule for the next day
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Cancel existing alarm
    await AndroidAlarmManager.cancel(_batteryAlarmId);

    // Schedule one-shot alarm
    await AndroidAlarmManager.oneShot(
      scheduledTime.difference(now),
      _batteryAlarmId,
      batteryCheckCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    // ignore: avoid_print
    print('Scheduled one-shot battery check at: $scheduledTime');
  }

  // Cancel battery monitoring
  Future<void> cancelBatteryCheck() async {
    await AndroidAlarmManager.cancel(_batteryAlarmId);
    stopRealtimeBatteryMonitoring();
  }

  // Send low battery alert to Slack (when battery falls below threshold)
  Future<void> sendBatteryAlert(int batteryLevel, String webhookUrl) async {
    try {
      final dio = Dio();
      final api = SlackApi(dio, baseUrl: webhookUrl);
      
      final message = SlackMessage(
        text: '⚠️ Battery Alert: Battery level is low at $batteryLevel%',
      );

      await api.postMessage(message);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to send battery alert: $e');
    }
  }

  // Send scheduled battery report to Slack (at scheduled time, regardless of threshold)
  Future<void> sendScheduledBatteryReport(int batteryLevel, String webhookUrl) async {
    try {
      final dio = Dio();
      final api = SlackApi(dio, baseUrl: webhookUrl);
      
      final now = DateTime.now();
      final message = SlackMessage(
        text: '🔋 Scheduled Battery Report\nTime: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}\nBattery Level: $batteryLevel%',
      );

      await api.postMessage(message);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to send scheduled battery report: $e');
    }
  }

  // Get current battery level
  Future<int> getCurrentBatteryLevel() async {
    final batteryState = await SystemState.battery.getBattery();
    return batteryState.level;
  }
}