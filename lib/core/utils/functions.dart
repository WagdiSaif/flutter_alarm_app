import 'package:alarmapp/core/enum/enums.dart';


AlarmDays getAlarmDay(int weekday) {
  
  return AlarmDays.values[weekday - 1];
  
}

 