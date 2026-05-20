import 'package:drift/drift.dart';

import '../../../core/enum/enums.dart';
import 'alarms_table.dart' show AlarmsTable;

class AlarmDaysTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get excutionId => integer()();//excutionId for  each day unique id exmple,we want update nextTrigger specific day

  IntColumn get repeatDays => intEnum<AlarmDays>()();

  IntColumn get alarmId => integer()
      .references(
        AlarmsTable, 
        #alarmId, 
        onDelete: KeyAction.cascade, 
        onUpdate: KeyAction.cascade, 
      )();

}