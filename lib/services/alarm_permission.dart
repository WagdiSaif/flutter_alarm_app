import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

class AlarmPermission {
  static Future<bool> checkBatteryOptimizationDisabled() async {
    PermissionStatus status =
        await Permission.ignoreBatteryOptimizations.status;

    if (status.isDenied) {
      status = await Permission.ignoreBatteryOptimizations.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }
    if (status.isPermanentlyDenied ) {
      return await openAppSettings();
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

  static Future<void> showPermissionHelpDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permissions Required"),
        content: const Text(
          "Some permissions were denied. You can enable them manually in app settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
