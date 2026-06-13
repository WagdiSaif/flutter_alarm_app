import 'dart:async';

import 'package:alarmapp/core/exceptions/database_exceptions.dart';
import 'package:alarmapp/data/database/tables/alarms_table.dart';

import 'package:drift/drift.dart';
import 'package:alarmapp/core/constants/constant.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:alarmapp/core/enum/enums.dart';

import 'tables/alarm_days_table.dart';
import 'tables/alarm_sounds_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [AlarmsTable, AlarmDaysTable, AlarmSoundsTable],
) 
class AlarmDatabase extends _$AlarmDatabase {
  AlarmDatabase() : super(driftDatabase(name: 'alarm_db'));

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      
    },
    beforeOpen: (details) async {
 
    },
  );

  @override
  int get schemaVersion => 1;
  Future<void> saveAlarm(
    AlarmsTableCompanion alarm,
    List<AlarmDaysTableCompanion> repeatedDay,
  ) async {
    try {
      if (repeatedDay.isEmpty) {
        await into(alarmsTable).insertOnConflictUpdate(alarm);
      } else {
        await transaction(() async {
          await into(alarmsTable).insertOnConflictUpdate(alarm);

          await batch((b) {
            b.insertAll(alarmDaysTable, repeatedDay);
          });
        });
      }
    } on SqliteException catch (e, stack) {
      throw DataBaseFailure(e, stack);
    } catch (e, stack) {
      throw UnExcepectedFailure(e, stack);
    }
  }

  Future<void> saveAllAlarms(
    List<AlarmsTableCompanion> alarms,
    List<AlarmDaysTableCompanion> repeatedDay,
  ) async {
    try {
      if (repeatedDay.isEmpty) {
        await transaction(() async {
          // await delete(alarmDaysTable).
          await batch((delete) {
            delete.deleteAll(alarmsTable);
          });
          await batch((insert) {
            insert.insertAll(alarmsTable, alarms);
          });
        });
      } else {
        await transaction(() async {
          // await delete(alarmDaysTable).

          await batch((delete) {
            delete.deleteAll(alarmsTable);
          });
          await batch((insert) {
            insert.insertAll(alarmsTable, alarms);
          });
          await batch((deleteDays) {
            deleteDays.deleteAll(alarmDaysTable);
          });
          await batch((b) {
            b.insertAll(alarmDaysTable, repeatedDay);
          });
        });
      }
    } on SqliteException catch (e, stack) {
      throw DataBaseFailure(e, stack);
    } catch (e, stack) {
      throw UnExcepectedFailure(e, stack);
    }
  }

  Future<void> updateAlarm(
    AlarmsTableCompanion alarm,
    List<AlarmDaysTableCompanion> repeatedDay,
  ) async {
    try {
      await transaction(() async {
        //todo: First remove all fields of current alarmDaysTable than reinsert all
        await (delete(
          alarmDaysTable,
        )..where((tbl) => tbl.alarmId.equals(alarm.alarmId.value))).go();
        await into(alarmsTable).insertOnConflictUpdate(alarm);

        await (delete(
          alarmDaysTable,
        )..where((tbl) => tbl.alarmId.equals(alarm.alarmId.value))).go();

        if (repeatedDay.isNotEmpty) {
          await batch((b) {
            b.insertAll(alarmDaysTable, repeatedDay);
          });
        }
      });
    } on SqliteException catch (e, stack) {
      throw DataBaseFailure(e, stack);
    } catch (e, stack) {
      throw UnExcepectedFailure(e, stack);
    }
  }

  Future<List<AlarmDaysTableData>?> getAlarmDaysByAlarmId(int alarmId) {
    return (select(
      alarmDaysTable,
    )..where((t) => t.alarmId.equals(alarmId))).get();
  }

  Future<List<AlarmDaysTableData>> getAllAlarmsDays() {
    return (select(alarmDaysTable).get());
  }

  Future<List<AlarmsTableData>> getAllAlarms() async {
    final data =
        await (select(alarmsTable)..orderBy([
              (u) => OrderingTerm(
                expression: u.nextTrigger,
                mode: OrderingMode.asc,
              ),
            ]))
            .get();

    return data;
  }

  Stream<List<AlarmsTableData>> watchAlarms() {
    return (select(alarmsTable)..orderBy([
          (t) =>
              OrderingTerm(expression: t.nextTrigger, mode: OrderingMode.asc),
        ]))
        .watch();
  }

  Stream<List<AlarmDaysTableData>> watchAlarmsRepeatedDays() {
    return select(alarmDaysTable).watch();
  }

  Future<int> upsertAlarm(AlarmsTableCompanion alarm) async {
    return await into(alarmsTable).insertOnConflictUpdate(alarm);
  }

  //  Delete
  Future<int> deleteAlarmById(int alarmId) {
    return (delete(alarmsTable)..where((t) => t.alarmId.equals(alarmId))).go();
  }

  Future<AlarmsTableData?> getAlarmById(int alarmId) {
    return (select(
      alarmsTable,
    )..where((t) => t.alarmId.equals(alarmId))).getSingleOrNull();
  }

  Future<AlarmsTableData?> getNextAlarm() {
    return (select(alarmsTable)
          ..where((t) => t.isEnabled.equals(true))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.nextTrigger, mode: OrderingMode.asc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<AlarmsTableData>> getActiveAlarms() {
    return (select(alarmsTable)..where((t) => t.isEnabled.equals(true))).get();
  }

  Future<AlarmsTableData?> fetchAlarmById(int id) async {
    try {
      return await (select(
        (alarmsTable),
      )..where((u) => u.alarmId.equals(id))).getSingleOrNull();
    } on SqliteException catch (e, stack) {
      throw DataBaseFailure(e, stack);
    } catch (e, stack) {
      throw UnExcepectedFailure(e, stack);
    }
  }

  Future<List<AlarmDaysTableData>> fetchAlarmRepeatedDays(int id) async {
    try {
      return await (select(
        (alarmDaysTable),
      )..where((u) => u.alarmId.equals(id))).get();
    } on SqliteException catch (e, stack) {
      throw DataBaseFailure(e, stack);
    } catch (e, stack) {
      throw UnExcepectedFailure(e, stack);
    }
  }

  void updateAlarmById(int id) async {
    (update((alarmsTable))..where((u) => u.alarmId.equals(id)));
  }

  //Deal with Alarm Sound Storage in  Local  File Path
  Future<void> insertSound(AlarmSoundsTableCompanion sound) async {
    try {
      await into(alarmSoundsTable).insertOnConflictUpdate(sound);
    } on SqliteException catch (e, stack) {
      throw DataBaseFailure(e, stack);
    } catch (e, stack) {
      throw UnExcepectedFailure(e, stack);
    }
  }

  Future<void> deleteSound(int id) async {
    try {
      await (delete(alarmSoundsTable)..where((u) => u.id.equals(id))).go();
    } on SqliteException catch (e, stack) {
      throw DataBaseFailure(e, stack);
    } catch (e, stack) {
      throw UnExcepectedFailure(e, stack);
    }
  }

  Stream<List<AlarmSoundsTableData>> watchAlarmSounds() {
    return (select(alarmSoundsTable)..orderBy([
          (d) => OrderingTerm(
            expression: d.createDateTime,
            mode: OrderingMode.asc,
          ),
        ]))
        .watch();
  }
}
