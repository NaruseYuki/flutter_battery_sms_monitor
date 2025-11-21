import 'package:sms_advanced/sms_advanced.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/slack_api.dart';

class SmsMonitorService {
  static const String _keySlackWebhookUrl = 'slack_webhook_url';
  
  final SmsReceiver _smsReceiver = SmsReceiver();
  
  // Start listening to SMS messages
  void startSmsMonitoring() {
    _smsReceiver.onSmsReceived?.listen((SmsMessage message) {
      _handleSmsReceived(message);
    });
  }
  
  // Handle received SMS
  Future<void> _handleSmsReceived(SmsMessage message) async {
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
      
      final text = '''
📱 New SMS Received
From: ${message.address ?? 'Unknown'}
Date: ${message.date ?? DateTime.now()}
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
  
  // Get recent SMS messages
  Future<List<SmsMessage>> getRecentMessages({int count = 10}) async {
    final query = SmsQuery();
    final messages = await query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: count,
    );
    return messages;
  }
}
