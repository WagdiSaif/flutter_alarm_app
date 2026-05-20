
import 'package:flutter/material.dart';

import 'package:timezone/timezone.dart' as tz;

extension ToMinutesTime on TimeOfDay{

int get toMinutes=>((this).hour*60+(this).minute);
}
extension ToTimeOfDay on int{

TimeOfDay get toTimeOfDay=>(TimeOfDay(hour: (this)~/60, minute: (this)%60));
}
extension ToTimeZones on DateTime {
  tz.TZDateTime get toLocalTz =>
      tz.TZDateTime.from(this, tz.local);

  tz.TZDateTime get toUtcTz =>
      tz.TZDateTime.from(this, tz.UTC);
}