
import 'package:flutter/material.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter_timezone/flutter_timezone.dart' as timezone;
class TimeManager {
  static tz.TZDateTime calculateNextTriggerTime(TimeOfDay dayTime) {
    final nowDateTime =tz.TZDateTime.now(tz.local);
    final scheduled = tz.TZDateTime(tz.local,
      nowDateTime.year,
      nowDateTime.month,
      nowDateTime.day,
      dayTime.hour,
      dayTime.minute,

    );
    if (scheduled.isBefore(nowDateTime)) {
      return scheduled.add(Duration(days: 1));
    }
    return scheduled;
  }

static Future<void> initTimeZone() async {
   tz.initializeTimeZones();
final localTimezone =await timezone.FlutterTimezone.getLocalTimezone();
  
tz.setLocalLocation(tz.getLocation(localTimezone.identifier));


  
}
  static String formatTimeShow(TimeOfDay time, BuildContext context) {
    final use24Hour = MediaQuery.of(context).alwaysUse24HourFormat;

    if (use24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hour == 0
          ? 12
          : (time.hour > 12 ? time.hour - 12 : time.hour);
      return '$hour:${time.minute.toString().padLeft(2, '0')}';
    }
  }
  
   
}
