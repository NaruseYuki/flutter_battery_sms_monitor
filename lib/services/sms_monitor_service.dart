import 'package:readsms/readsms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../api/slack_api.dart';

class SmsMonitorService {
  static const String _keySlackWebhookUrl = 'slack_webhook_url';

  final Readsms _readSms = Readsms();
  StreamSubscription<SMS>? _smsSubscription;

  // Guard to prevent concurrent starts
  bool _starting = false;

  // Start listening to SMS messages
  Future<void> startSmsMonitoring() async {
    // If we already have an active subscription, nothing to do.
    if (_smsSubscription != null) {
      return;
    }

    // Prevent concurrent calls from racing and double-initializing the plugin.
    if (_starting) {
      return;
    }
    _starting = true;

    try {
      _readSms.read();
    } catch (e) {
      // Other initialization errors — log and continue.
      // ignore: avoid_print
      print('readsms.read() threw: $e');
    }

    // Subscribe to the stream and keep the subscription so we can cancel later.
    _smsSubscription = _readSms.smsStream.listen((SMS message) {
      _handleSmsReceived(message);
    }, onError: (err) async {
      // Log error and clear state.
      // ignore: avoid_print
      print('SMS stream error: $err');

      // Clear subscription reference.
      await _smsSubscription?.cancel();
      _smsSubscription = null;

      // Try to dispose the plugin so future start attempts can reinitialize cleanly.
      _readSms.dispose();
    });
  }

  // Stop listening to SMS messages
  Future<void> stopSmsMonitoring() async {
    if (_smsSubscription != null) {
      try {
        await _smsSubscription!.cancel();
      } catch (e) {
        // ignore
      } finally {
        _smsSubscription = null;
      }
    }

    // readsms に停止 API を呼び出す
    try {
      _readSms.dispose();
    } catch (e) {
      // ignore
    }
  }

  // ライフサイクル等で呼べる dispose
  Future<void> dispose() async {
    await stopSmsMonitoring();
  }

  // Handle received SMS
  Future<void> _handleSmsReceived(SMS message) async {
    final prefs = await SharedPreferences.getInstance();
    final webhookUrl = prefs.getString(_keySlackWebhookUrl);

    if (webhookUrl == null || webhookUrl.isEmpty) {
      // ignore: avoid_print
      print('Slack webhook URL not configured');
      return;
    }

    await _sendSmsToSlack(message, webhookUrl);
  }

  // Send SMS to Slack
  Future<void> _sendSmsToSlack(SMS message, String webhookUrl) async {
    try {
      final dio = Dio();
      final api = SlackApi(dio, baseUrl: webhookUrl);

      final text = '''
📱 New SMS Received
From: ${message.sender ?? 'Unknown'}
Date: ${message.timeReceived ?? DateTime.now()} ${message.timeReceived == null ? '(received time)' : ''}
Message: ${message.body ?? '(empty)'}
      ''';

      final slackMessage = SlackMessage(text: text);
      await api.postMessage(slackMessage);
    } catch (e) {
      // Log error - in production, consider using a proper logging framework
      // ignore: avoid_print
      print('Failed to send SMS to Slack: $e');
    }
  }

  Future<void> saveSlackWebhookUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySlackWebhookUrl, url);
  }

  Future<String?> getSlackWebhookUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySlackWebhookUrl);
  }

  bool get isMonitoring => _smsSubscription != null;
}