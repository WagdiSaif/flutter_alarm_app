import 'package:flutter/material.dart';

class HelperMessage {
  static void scaffoldSetAlarmMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Alarm set for$message"),
      ),
    );
  }
}
