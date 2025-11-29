import 'package:another_telephony/telephony.dart';
import 'package:flutter_boot_receiver/flutter_boot_receiver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/slack_api.dart';
import 'battery_monitor_service.dart';

// Background SMS handler for boot receiver - same logic as main.dart backgroundMessageHandler
@pragma('vm:entry-point')
Future<void> _bootBackgroundSmsHandler(SmsMessage message) async {
  const String keySlackWebhookUrl = 'slack_webhook_url';

  try {
    final prefs = await SharedPreferences.getInstance();
    final webhookUrl = prefs.getString(keySlackWebhookUrl);

    if (webhookUrl == null || webhookUrl.isEmpty) {
      // ignore: avoid_print
      print('Slack webhook URL not configured');
      return;
    }

    final dio = Dio();
    final api = SlackApi(dio, baseUrl: webhookUrl);

    final receivedDate = message.date != null
        ? DateTime.fromMillisecondsSinceEpoch(message.date!)
        : DateTime.now();

    final text = '''
📱 New SMS Received (Background - Boot)
From: ${message.address ?? 'Unknown'}
Date: $receivedDate${message.date == null ? ' (received time)' : ''}
Message: ${message.body ?? '(empty)'}
    ''';

    final slackMessage = SlackMessage(text: text);
    await api.postMessage(slackMessage);
  } catch (e) {
    // ignore: avoid_print
    print('Failed to send SMS to Slack from boot background: $e');
  }
}

// Boot completed callback - called when the device boots up
// Restarts SMS monitoring, battery threshold monitoring, and scheduled battery reports
@pragma('vm:entry-point')
void onBootCompleted() async {
  // ignore: avoid_print
  print('Boot completed callback triggered');

  try {
    final batteryService = BatteryMonitorService.internal();
    final settings = await batteryService.getSettings();

    if (settings == null) {
      // ignore: avoid_print
      print('No monitoring settings found on boot');
      return;
    }

    final monitorTime = settings['monitorTime'] as String?;
    if (monitorTime == null || monitorTime.isEmpty) {
      // ignore: avoid_print
      print('Invalid monitor time setting on boot');
      return;
    }

    // Reschedule battery check alarm
    await batteryService.scheduleBatteryCheck(monitorTime);
    // ignore: avoid_print
    print('Scheduled battery check restarted after boot');

    // Start SMS monitoring on boot
    // The another_telephony package supports background listening
    final telephony = Telephony.instance;
    
    // Request permissions before starting SMS monitoring
    final bool? hasPermission = await telephony.requestPhoneAndSmsPermissions;
    if (hasPermission == true) {
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) async {
          await _bootBackgroundSmsHandler(message);
        },
        listenInBackground: true,
        onBackgroundMessage: _bootBackgroundSmsHandler,
      );
      // ignore: avoid_print
      print('SMS monitoring restarted after boot');
    } else {
      // ignore: avoid_print
      print('SMS permissions not granted on boot');
    }

    // ignore: avoid_print
    print('Boot completed callback finished successfully');
  } catch (e) {
    // ignore: avoid_print
    print('Error in boot completed callback: $e');
  }
}

class BootReceiverService {
  // Initialize boot receiver to listen for device boot events
  static Future<bool> initialize() async {
    try {
      final success = await BootReceiver.initialize(onBootCompleted);
      // ignore: avoid_print
      print('Boot receiver initialized: $success');
      return success;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to initialize boot receiver: $e');
      return false;
    }
  }
}
