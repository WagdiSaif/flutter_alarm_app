import 'package:permission_handler/permission_handler.dart';

class AlarmPermission {
  static Future<bool> checkBatteryOptimizationDisabled() async {
    final status = await Permission.ignoreBatteryOptimizations.status;

    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    status = await Permission.notification.request();

    return status.isGranted;
  }

  static Future<bool> ensureExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isGranted) return true;

    final status = await Permission.scheduleExactAlarm.status;

    if (status.isPermanentlyDenied) {
      return false;
    }

    // Request permission
    final result = await Permission.scheduleExactAlarm.request();
    return result.isGranted;
  }
}
