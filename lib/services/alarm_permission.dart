
import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

class AlarmPermission {
  // static Future<void> checkBatteryOptimizationDisabled() async {
  //   bool? isAutoStartEnabled =
  //       await DisableBatteryOptimization.isAutoStartEnabled;
  //   if (!(isAutoStartEnabled ?? false)) {
  //     await DisableBatteryOptimization.showEnableAutoStartSettings(
  //       "Enable Auto Start",
  //       "Follow the steps and enable the auto start of this app",
  //     );
  //   }
  // }

  //  Future<bool?> androidRequestNotifictionPermission()async{
  //   FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.hasNotificationPolicyAccess();
  // final isAllow=   await FlutterLocalNotificationsPlugin()
  //         .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin
  //         >()
  //         ?.requestNotificationsPermission();

  // return isAllow;
  // }
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return true;
    }
    if (status.isPermanentlyDenied || status.isLimited) {
      return await openAppSettings();
    }

    final result = await Permission.notification.request();
     if (await Permission.criticalAlerts.isDenied) {
    await Permission.criticalAlerts.request();
  }

    return result.isGranted;
  }

  static Future<bool> ensureExactAlarmPermission() async {
    // For Android 12+
    if (await Permission.scheduleExactAlarm.isGranted) return true;

    // Check if we can request
    final status = await Permission.scheduleExactAlarm.status;

    if (status.isPermanentlyDenied) {
      return false;
    }

    // Request permission
    final result = await Permission.scheduleExactAlarm.request();
    return result.isGranted;
  }

  static void showPermissionHelpDialog(BuildContext context) {
    showDialog(
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
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }
}
