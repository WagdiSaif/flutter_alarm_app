import 'package:intl/intl.dart';

extension  ToAmPm on DateTime{

String get amPmTime=>  DateFormat('a').format(this);
}
extension  ToHourseDate on DateTime{

String get toHours=>  DateFormat('HH').format(this);
}
extension  ToMinutesDate on DateTime{

String get toMinutes=>  DateFormat('mm').format(this);
}