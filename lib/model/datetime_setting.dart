

class DateTimeSetting{
  int year;
  int month;
  int day;
  int hour;
  int second;
  int minute;
  int millisecond;
  int microsecond;
  String peroid;
  

  DateTimeSetting({
    this.second = 0,
  
    this.minute = 0,
    this.year = 0,
    this.month = 1,
    this.day = 1,
    this.hour = 0,
    this.millisecond = 0,
    this.microsecond = 0,
    this.peroid = 'AM',
  });
  factory DateTimeSetting.fromDate(DateTimeSetting obj) => DateTimeSetting(
        year: obj.year,
        month: obj.month,
        day: obj.day,
        hour: obj.hour,
        minute: obj.minute,
        microsecond: obj.microsecond,
        millisecond: obj.millisecond,
        second: obj.second,
        peroid: obj.peroid,
        );
  
  DateTime get totDateTime=> DateTime(year, month, day, hour, minute,second, millisecond, microsecond);
  
}
