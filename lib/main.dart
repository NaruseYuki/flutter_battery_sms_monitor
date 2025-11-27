import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'screens/home_screen.dart';
import 'api/slack_api.dart';

@pragma('vm:entry-point')
backgroundMessageHandler(SmsMessage message) async {
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
📱 New SMS Received (Background)
From: ${message.address ?? 'Unknown'}
Date: $receivedDate${message.date == null ? ' (received time)' : ''}
Message: ${message.body ?? '(empty)'}
    ''';

    final slackMessage = SlackMessage(text: text);
    await api.postMessage(slackMessage);
  } catch (e) {
    // ignore: avoid_print
    print('Failed to send SMS to Slack from background: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Android Alarm Manager
  await AndroidAlarmManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battery & SMS Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
