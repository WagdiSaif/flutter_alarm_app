import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;

class PermissoinDialog {
  static Future<void> showPermissionOpenSettingsDialog(BuildContext context) async {
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
  Navigator.pop(context);
  await openAppSettings();

            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }


 static Future<bool?> showPermissionDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Permissions Required"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "This app needs the following permissions to work properly:",
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.notifications, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "• Notifications - to alert you when alarm rings",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.alarm, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text("• Exact alarms - to ring at precise time"),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
    return result;
  }
}