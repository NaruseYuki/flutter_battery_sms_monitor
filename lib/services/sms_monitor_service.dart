import 'package:another_telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/slack_api.dart';

class SmsMonitorService {
  static const String _keySlackWebhookUrl = 'slack_webhook_url';

  final Telephony _telephony = Telephony.instance;

  // Flag to track if we are currently monitoring and should process SMS
  bool _isMonitoring = false;

  // Flag to track if the listener has been registered
  // (another_telephony's listenIncomingSms returns void and cannot be cancelled)
  bool _listenerRegistered = false;

  // Start listening to SMS messages
  Future<void> startSmsMonitoring() async {
    _isMonitoring = true;

    // Only register the listener once since another_telephony doesn't support
    // unregistering listeners. The _isMonitoring flag controls whether
    // received messages are actually processed.
    if (_listenerRegistered) {
      return;
    }

    _listenerRegistered = true;

    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        _handleSmsReceived(message);
      },
      listenInBackground: false,
    );
  }

  // Stop listening to SMS messages
  Future<void> stopSmsMonitoring() async {
    // Note: another_telephony does not provide an API to unregister the listener.
    // Setting _isMonitoring to false prevents processing of incoming SMS messages.
    _isMonitoring = false;
  }

  // ライフサイクル等で呼べる dispose
  Future<void> dispose() async {
    await stopSmsMonitoring();
  }

  // Handle received SMS
  Future<void> _handleSmsReceived(SmsMessage message) async {
    // Skip processing if monitoring is disabled
    if (!_isMonitoring) {
      return;
    }

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
  Future<void> _sendSmsToSlack(SmsMessage message, String webhookUrl) async {
    try {
      final dio = Dio();
      final api = SlackApi(dio, baseUrl: webhookUrl);

      final receivedDate = message.date != null
          ? DateTime.fromMillisecondsSinceEpoch(message.date!)
          : DateTime.now();

      final text = '''
📱 New SMS Received
From: ${message.address ?? 'Unknown'}
Date: $receivedDate${message.date == null ? ' (received time)' : ''}
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

  bool get isMonitoring => _isMonitoring;
}