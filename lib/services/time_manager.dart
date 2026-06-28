import 'package:flutter/material.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter_timezone/flutter_timezone.dart' as timezone;

class TimeManager {
  static tz.TZDateTime calculateNextTriggerTime(TimeOfDay dayTime) {
    final now = nowDateTime;

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      dayTime.hour,
      dayTime.minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        dayTime.hour,
        dayTime.minute,
      );
    }

    return scheduled;
  }

  static Future<void> initTimeZone() async {
    tz.initializeTimeZones();
    final localTimezone = await timezone.FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
  }

  static String formatTime(TimeOfDay time, BuildContext context) {
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

  static tz.TZDateTime get nowDateTime => tz.TZDateTime.now(tz.local);
  static tz.TZDateTime customDateTime({
    int year = 0,
    int month = 0,
    int day = 0,
    int hour = 0,
    int minute = 0,
  }) {
    final dateTime = tz.TZDateTime(
      tz.local,

      nowDateTime.year + year,
      nowDateTime.month + month,
      nowDateTime.day + day,
      nowDateTime.hour + hour,
      nowDateTime.minute + minute,
    );

    return dateTime;
  }

  static bool isAfterDaysFromToday(tz.TZDateTime time, {int day = 1}) {
    final now = nowDateTime;

    final nextDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + day,
    );

    return time.difference(nextDate).inDays >= 1;
  }
}
