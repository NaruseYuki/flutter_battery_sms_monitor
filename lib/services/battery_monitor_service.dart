import 'package:battery_plus/battery_plus.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../api/slack_api.dart';

@pragma('vm:entry-point')
Future<void> batteryCheckCallback() async {
  final service = BatteryMonitorService.internal(); // 内部コンストラクタでインスタンス化
  final settings = await service.getSettings();

  if (settings == null) {
    // ignore: avoid_print
    print('Battery monitoring settings not found.');
    return;
  }

  final battery = Battery();
  final batteryLevel = await battery.batteryLevel;
  final threshold = settings['batteryThreshold'] as int;
  final webhookUrl = settings['slackWebhookUrl'] as String;

  // バッテリーチェックとアラート送信
  if (batteryLevel <= threshold) {
    await service.sendBatteryAlert(batteryLevel, webhookUrl);
  }

  // 💡 1回実行した後に、翌日の同じ時刻に再スケジュールしたい場合は、
  service.scheduleBatteryCheck(settings['monitorTime']) ;

  // ignore: avoid_print
  print('Battery check completed. Level: $batteryLevel%.');
}

// ----------------------------------------------------------------------

class BatteryMonitorService {
  static const String _keyMonitorTime = 'monitor_time';
  static const String _keyBatteryThreshold = 'battery_threshold';
  static const String _keySlackWebhookUrl = 'slack_webhook_url';
  static const int _batteryAlarmId = 0;

  final Battery _battery = Battery();

  // 外部からのインスタンス化
  BatteryMonitorService();

  // コールバック関数から利用するための内部コンストラクタ（_batteryは利用しない）
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

  // 🚨 修正されたメソッド: 一度だけバッテリーチェックをスケジュールします
  // Schedule battery monitoring (one-shot)
  Future<void> scheduleBatteryCheck(String timeStr) async {
    // Parse time string (HH:MM)
    final parts = timeStr.split(':');
    if (parts.length != 2) return;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return;

    // 現在時刻を取得
    final now = DateTime.now();

    // 指定された時刻で今日の日付のDateTimeオブジェクトを作成
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    // スケジュール時刻が現在時刻よりも過去の場合、翌日の時刻に設定
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // 既存のアラームをキャンセル
    await AndroidAlarmManager.cancel(_batteryAlarmId);

    // oneShot で一度だけ実行するようスケジュール
    await AndroidAlarmManager.oneShot(
      scheduledTime.difference(now), // 現在から実行時刻までのDuration
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
  }

  // Send battery alert to Slack
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

  // Get current battery level
  Future<int> getCurrentBatteryLevel() async {
    return await _battery.batteryLevel;
  }
}