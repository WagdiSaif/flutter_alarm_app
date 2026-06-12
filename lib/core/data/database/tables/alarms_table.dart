
import 'package:alarmapp/core/constant/constant.dart';
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_nextTrigger', columns: {#nextTrigger})
@TableIndex(name: 'idx_enabled_next', columns: {#isEnabled, #nextTrigger})
class AlarmsTable extends Table {


  IntColumn get alarmId => integer()();

  TextColumn get name => text()();

  TextColumn get title => text().withDefault(const Constant(''))();

  TextColumn get soundPath =>
      text().withDefault(const Constant(AppConstants.defaultSound))();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  BoolColumn get vibrate => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdDate =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get nextTrigger => dateTime()();
  IntColumn get firedTimeMinutes => integer()();
  @override
  Set<Column> get primaryKey => {alarmId};

   
}




