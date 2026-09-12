enum AlarmDays {
  monday, //weakday 1
  tuesday, //2
  wednesday, //3
  thursday,
  friday,
  saturday,
  sunday;

  String get shortName {
    return switch (this) {
      AlarmDays.monday => 'Mon',
      AlarmDays.tuesday => 'Tue',
      AlarmDays.wednesday => 'Wed',
      AlarmDays.thursday => 'Thu',
      AlarmDays.friday => 'Fri',
      AlarmDays.saturday => 'Sat',
      AlarmDays.sunday => 'Sun',
    };
  }
}
