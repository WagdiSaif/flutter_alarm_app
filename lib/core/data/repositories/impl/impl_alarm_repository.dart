import 'package:alarmapp/core/data/database/app_database.dart';
import 'package:alarmapp/core/extensions.dart';
import 'package:alarmapp/core/data/models/alarm_days_model.dart';
import 'package:alarmapp/core/data/models/alarm_model.dart';

import 'package:alarmapp/core/data/repositories/alarm_repository.dart';

import 'package:drift/drift.dart';


import 'package:rxdart/rxdart.dart';

class ImplAlarmRepository implements AlarmRepository {
  final AlarmDatabase db;
  ImplAlarmRepository(this.db);
  @override
  Future<void> saveAlarm(AlarmModel alarmDetails) async {
    try {
      List<AlarmDaysTableCompanion> repeatDays = [];
      final alarm = AlarmsTableCompanion(
        soundPath: Value(alarmDetails.soundPath),
        vibrate: Value(alarmDetails.vibrate),
        
        isEnabled: Value(alarmDetails.isEnabled),
        firedTimeMinutes: Value(alarmDetails.firedTime.toMinutes),
        name: Value(alarmDetails.name),
        alarmId: Value(alarmDetails.alarmId),
        title: Value(alarmDetails.title),
        nextTrigger: Value(alarmDetails.nextTrigger),
      );
      if (alarmDetails.alarmDaysModel.isNotEmpty) {
        repeatDays = alarmDetails.alarmDaysModel
            .map(
              (day) => AlarmDaysTableCompanion(
                excutionId: Value(day.excutionId!),
                alarmId: Value(day.alarmId!),
                repeatDays: Value(day.repeatedDays!),
              ),
            )
            .toList();
      }
      await db.saveAlarm(alarm, repeatDays);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Stream<List<AlarmModel>> alarmsStream() {
    final alarmsStream = db.watchAlarms();

    final daysStream = db.watchAlarmsRepeatedDays();

    return Rx.combineLatest2(alarmsStream, daysStream, ((
      List<AlarmsTableData> alarms,
      List<AlarmDaysTableData> days,
    ) {
      Map<int, List<AlarmDaysModel>> alarmsDays = {};
      for (var tableData in days) {
        final modelData = AlarmDaysModel(
          alarmId: tableData.alarmId,
          excutionId: tableData.excutionId,
          repeatedDays: tableData.repeatDays,
        );
        alarmsDays.putIfAbsent(tableData.alarmId, () => []).add(modelData);
      }
      

      return alarms
          .map(
            (a) => (AlarmModel(
              repeatDays:alarmsDays[a.alarmId]!=null? alarmsDays[a.alarmId]!.map((e)=>e.repeatedDays!).toList():[],
              name: a.name,
              title: a.title,
              vibrate: a.vibrate,
              isEnabled: a.isEnabled,
              soundPath: a.soundPath,
              alarmDaysModel: alarmsDays[a.alarmId] ?? [],
              firedTime: a.firedTimeMinutes.toTimeOfDay,
              alarmId: a.alarmId,
              
              nextTrigger: a.nextTrigger.toLocalTz,
              createdDate: a.createdDate.toLocalTz,
            )),
          )
          .toList();
    }));
  }

 

  @override
  Future<AlarmModel?> getAlarmById(int alarmId) async {
    try {
      //First Fetch Alarm Data
      final alarmData = await db.fetchAlarmById(alarmId);
      final repeatedDays = await db.fetchAlarmRepeatedDays(alarmId);
      if (alarmData != null) {
        final alarmDetails = AlarmModel(
          soundPath: alarmData.soundPath,
          alarmId: alarmData.alarmId,
          firedTime: alarmData.firedTimeMinutes.toTimeOfDay,
          nextTrigger: alarmData.nextTrigger.toLocalTz,
          createdDate: alarmData.createdDate.toLocalTz,
          title: alarmData.title,
          name: alarmData.name,
          isEnabled: alarmData.isEnabled,
          vibrate: alarmData.vibrate,
        );

        if (repeatedDays.isEmpty) return alarmDetails;
        final days = repeatedDays
            .map(
              (d) => AlarmDaysModel(
                alarmId: d.alarmId,
                excutionId: d.excutionId,
                repeatedDays: d.repeatDays,
              ),
            )
            .toList();
        return alarmDetails.copyWith(alarmDaysModel: days);
      }
    } catch (_) {
      rethrow;
    }
    return null;
  }

  @override
  Future<int> removeAlarmById(int alarmId) async {
    return await db.deleteAlarmById(alarmId);
  }

  @override
  Future<void> updateAlarm(AlarmModel alarmDetails) async {
    try {
      List<AlarmDaysTableCompanion> repeatDays = [];
      final alarm = AlarmsTableCompanion(
        isEnabled: Value(alarmDetails.isEnabled),
        firedTimeMinutes: Value(alarmDetails.firedTime.toMinutes),
        name: Value(alarmDetails.name),
        alarmId: Value(alarmDetails.alarmId),
        title: Value(alarmDetails.title),
        nextTrigger: Value(alarmDetails.nextTrigger),
      );
      if (alarmDetails.alarmDaysModel.isNotEmpty) {
        repeatDays = alarmDetails.alarmDaysModel
            .map(
              (day) => AlarmDaysTableCompanion(
                excutionId: Value(day.excutionId!),
                alarmId: Value(day.alarmId!),
                repeatDays: Value(day.repeatedDays!),
              ),
            )
            .toList();
      }
      await db.updateAlarm(alarm, repeatDays);
    } catch (_) {
      rethrow;
    }
  }
   @override
  Future<List<AlarmModel>> fetchAllAlarms() async {
    try {
      final activeAlarms = await db.getAllAlarms();
  final alarmRepeatDays=await db.getAllAlarmsDays();

      final data = await Future.wait(
        activeAlarms.map((alarm) async {
          
       
          //  await db.fetchAlarmRepeatedDays(alarm.alarmId);
         
          var allAlarms = AlarmModel(
            name: alarm.name,
            alarmId: alarm.alarmId,
            firedTime: alarm.firedTimeMinutes.toTimeOfDay,
            nextTrigger: alarm.nextTrigger.toLocalTz,
            createdDate: alarm.createdDate.toLocalTz,
            soundPath: alarm.soundPath,
            isEnabled: alarm.isEnabled,
            title: alarm.title,
            vibrate: alarm.vibrate,
          );
          allAlarms = extractRepeatDays(alarmRepeatDays, alarm, allAlarms);
          return allAlarms;
        }).toList(),
      );

      return data;
    } catch (_) {
      rethrow;
    }
  }

   AlarmModel extractRepeatDays(List<AlarmDaysTableData> alarmRepeatDays, AlarmsTableData alarm, AlarmModel allAlarms) {
      if (alarmRepeatDays.isEmpty) {
         return allAlarms;
      }
     
        final alarmDays = alarmRepeatDays.where((d)=>d.alarmId==alarm.alarmId).toList();
        if(alarmDays.isNotEmpty){
       final days = alarmDays
           .map(
             (d) => AlarmDaysModel(
               alarmId: d.alarmId,
               excutionId: d.excutionId,
               repeatedDays: d.repeatDays,
             ),
           )
           .toList();
       allAlarms=allAlarms.copyWith(alarmDaysModel: days);
     }
     return allAlarms;
   }

  @override
  Future<List<AlarmModel>> getActiveAlarms() async {
    try {
      final activeAlarms = await db.getActiveAlarms();
        final alarmRepeatDays=await db.getAllAlarmsDays();

      final data = await Future.wait(
        activeAlarms.map((alarm) async {
       
          var allAlarms = AlarmModel(
         
            name: alarm.name,
            alarmId: alarm.alarmId,
            firedTime: alarm.firedTimeMinutes.toTimeOfDay,
            nextTrigger: alarm.nextTrigger.toLocalTz,
            createdDate: alarm.createdDate.toLocalTz,
            soundPath: alarm.soundPath,
            isEnabled: alarm.isEnabled,
            title: alarm.title,
            vibrate: alarm.vibrate,
          );
            allAlarms = extractRepeatDays(alarmRepeatDays, alarm, allAlarms);
          return allAlarms;
        }).toList(),
      );

      return data;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> saveAllAlarms(List<AlarmModel> alarm) async {
    List<AlarmDaysTableCompanion> repeatDays = [];
    try {
      final data = await Future.wait(
        alarm.map((alarmDetails) async {
          final allAlarms = AlarmsTableCompanion(
            isEnabled: Value(alarmDetails.isEnabled),
            firedTimeMinutes: Value(alarmDetails.firedTime.toMinutes),
            name: Value(alarmDetails.name),
            alarmId: Value(alarmDetails.alarmId),
            title: Value(alarmDetails.title),
            nextTrigger: Value(alarmDetails.nextTrigger),
          );
          if (alarmDetails.alarmDaysModel.isNotEmpty) {
            final days = alarmDetails.alarmDaysModel
                .map(
                  (day) => AlarmDaysTableCompanion(
                    excutionId: Value(day.excutionId!),
                    alarmId: Value(day.alarmId!),
                    repeatDays: Value(day.repeatedDays!),
                  ),
                )
                .toList();
            repeatDays = [...repeatDays, ...days];
            
          }

          return allAlarms;
        }).toList(),
      );
      await db.saveAllAlarms(data, repeatDays);
    } catch (_) {
      rethrow;
    }
  }
  
  @override
  Future<void> addAlarmSound(String soundPath)async {
 try {
  final sound=AlarmSoundsTableCompanion( soundFilePath: Value(soundPath), createDateTime: Value(DateTime.now().toLocalTz));
  await db.insertSound(sound);
 } catch (_) {
   rethrow;
 }
  }
  
  @override
  Stream<List<Map<String, dynamic>>> alarmsSlounds() {
 final sounds= db.watchAlarmSounds();

final data= sounds.map((s)=>s.map((sound)=><String,dynamic>{'id':sound.id,'path' :sound.soundFilePath,'createDateTime': sound.createDateTime} ).toList() );

return data;
  }
  
  @override
  Future<void> removeSoundById(int id)async {

 try {
  
  await db.deleteSound(id);
 } catch (_) {
   rethrow;
 }
  }
}
