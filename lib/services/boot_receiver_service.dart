import 'package:flutter_boot_receiver/flutter_boot_receiver.dart';
import 'battery_monitor_service.dart';

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

    // Note: SMS monitoring and realtime battery monitoring require
    // the app to be running in foreground/background with Flutter engine.
    // They will be restarted when the app is launched.
    // The scheduled alarm (battery check) is the main feature that
    // needs to be restarted on boot since it uses AndroidAlarmManager
    // which persists alarms across reboots.

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
