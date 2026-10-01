import 'package:alarmapp/core/enums/enums.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:flutter_timezone/flutter_timezone.dart' as timezone;

AlarmDays getAlarmDay(int weekday) {
  return AlarmDays.values[weekday - 1];
}

String formatDateMD(TZDateTime time) {
  return DateFormat.MMMd().format(time);
}

String twoDigits(int n) => n.toString().padLeft(2, '0');
String formatTimerDuration(Duration duration) {
  final second = twoDigits(duration.inSeconds.remainder(60));

  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final hours = duration.inHours.remainder(60);
  if (hours > 0) {
    return '${twoDigits(hours)}:$minutes:$second';
  }
  return '$minutes:$second';
}

String formatStopwatchDuration(Duration duration) {
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final second = twoDigits(duration.inSeconds.remainder(60));
  final milliseconds = twoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
  if (duration.inHours > 1) {
    final hours = twoDigits(duration.inHours.remainder(60));

    return '$hours:$minutes:$second.$milliseconds';
  }

  return '$minutes:$second.$milliseconds';
}

tz.TZDateTime get nowDateTime => tz.TZDateTime.now(tz.local);
tz.TZDateTime customDateTime({
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

bool isAfterDaysFromToday(tz.TZDateTime time, {int day = 1}) {
  final now = nowDateTime;

  final nextDate = tz.TZDateTime(tz.local, now.year, now.month, now.day + day);

  return time.difference(nextDate).inDays >= 1;
}

String formatBackgroundDuration(Duration duration) {
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final second = twoDigits(duration.inSeconds.remainder(60));
  if (duration.inHours > 1) {
    final hours = twoDigits(duration.inHours.remainder(60));

    return '$hours:$minutes:$second';
  }

  return '$minutes:$second';
}

tz.TZDateTime calculateNextTriggerTime(TimeOfDay dayTime) {
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

Future<void> initTimeZone() async {
  tz.initializeTimeZones();
  final localTimezone = await timezone.FlutterTimezone.getLocalTimezone();

  tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
}

String formatTime12Hours(TimeOfDay time, {required bool use24Hour}) {
  //final use24Hour = MediaQuery.of(context).alwaysUse24HourFormat;

  if (use24Hour) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  } else {
    final hour = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    return '$hour:${time.minute.toString().padLeft(2, '0')}';
  }
}
