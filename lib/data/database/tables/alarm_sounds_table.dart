import 'package:drift/drift.dart';

class AlarmSoundsTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get soundFilePath => text()();
  DateTimeColumn get createDateTime =>
      dateTime().withDefault(currentDateAndTime)();
}
