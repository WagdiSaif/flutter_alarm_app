import 'package:alarmapp/core/enum/enums.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

AlarmDays getAlarmDay(int weekday) {
  return AlarmDays.values[weekday - 1];
}

String formateDateMD(TZDateTime time) {
  return DateFormat.MMMd().format(time);
}
