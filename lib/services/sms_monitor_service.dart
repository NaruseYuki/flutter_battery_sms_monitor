import 'package:readsms/readsms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import '../api/slack_api.dart';

class SmsMonitorService {
  static const String _keySlackWebhookUrl = 'slack_webhook_url';
  
  final ReadSms _readSms = ReadSms();
  StreamSubscription<SMS>? _smsSubscription;
  
  // Start listening to SMS messages
  void startSmsMonitoring() {
    // Cancel existing subscription to prevent duplicates
    _smsSubscription?.cancel();
    
    // Start reading SMS
    _readSms.read();
    
    _smsSubscription = _readSms.smsStream.listen((SMS message) {
      _handleSmsReceived(message);
    });
  }
  
  // Stop listening to SMS messages
  void stopSmsMonitoring() {
    _smsSubscription?.cancel();
    _smsSubscription = null;
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
  
  // Note: The readsms package only supports listening to incoming SMS messages
  // in real-time. It does not support querying historical messages.
  // If you need to retrieve historical messages, you would need to use a
  // different package or Android's SMS ContentProvider directly.
}
