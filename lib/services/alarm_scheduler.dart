import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:alarmapp/services/alarm_shared_preference.dart';
import 'package:alarmapp/core/exceptions/database_exceptions.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:alarmapp/core/enum/enums.dart';
import 'package:alarmapp/models/alarm_days_model.dart';

import 'package:alarmapp/models/alarm_model.dart';
import 'package:alarmapp/services/time_manager.dart';

import 'package:flutter/material.dart';

class AlarmScheduler {
  int _counterId = 0;
  int get generateId {
    final baseId = DateTime.now().millisecondsSinceEpoch % 1000000;
    _counterId = (_counterId + 1) % 1000;
    return (baseId * 1000) + _counterId;
  }

  Future<void> _setAlarm(AlarmModel alarm) async {
    final alarmSettings = AlarmSettings(
      id: alarm.alarmId,
      allowAlarmOverlap: false,
      dateTime: alarm.nextTrigger,
      assetAudioPath: alarm.soundPath,
      loopAudio: true,
      vibrate: alarm.vibrate,

      warningNotificationOnKill: Platform.isIOS,
      androidFullScreenIntent: true,
      volumeSettings: VolumeSettings.fade(
        volume: 0.8,
        fadeDuration: const Duration(seconds: 5),
        volumeEnforced: true,
      ),
      notificationSettings: NotificationSettings(
        title: alarm.title,
        body: alarm.name,
        stopButton: 'STOP',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> stopAlarm(int id) async {
    await Alarm.stop(id);
  }

  Future<bool> isAlarmPresent(int id) async {
    return await Alarm.getAlarm(id) != null;
  }

  Future<void> cancelScheduledAlarm(AlarmModel dbAlarm) async {
    try {
      if (dbAlarm.alarmDaysModel.isEmpty) {
        await stopAlarm(dbAlarm.alarmId);
        return;
      }
      final relatedAlarms = {
        ...dbAlarm.alarmDaysModel
            .where((e) => e.excutionId != null)
            .map((exId) => exId.excutionId!),
      };

      await Future.wait(relatedAlarms.map(Alarm.stop));
    } catch (e, stack) {
      throw ScheduleFailure(e, stack);
    }
  }

  Future<bool> stopAllAlarms() async {
    try {
      await Alarm.stopAll();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Snooze alarm
  Future<void> snoozeAlarm(int orignalId, tz.TZDateTime current) async {
    final activeAlarm = await Alarm.getAlarm(orignalId);
    if (activeAlarm == null) return;
    await stopAlarm(orignalId);

    final snoozeId = generateId;

    await AlarmSharedPrefs.removeAllState();
    await AlarmSharedPrefs.setAlarmState(snooze, snoozeId);
    await Alarm.set(
      alarmSettings: activeAlarm.copyWith(
        id: snoozeId,
        dateTime: current.add(Duration(minutes: 2)),
      ),
    );
  }

  Future<List<AlarmSettings>> getActiveAlarms() async {
    try {
      return await Alarm.getAlarms();
    } catch (e) {
      debugPrint(' Failed to get active alarms: $e');
      return [];
    }
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    try {
      if (!alarm.isEnabled) return;

      await _setAlarm(alarm);
    } catch (e, stack) {
      throw ScheduleFailure(e, stack);
    }
  }

  Future<bool> get isRinging async => await Alarm.isRinging();

  Future<List<AlarmModel>> reschedulePresentAlarms(
    List<AlarmModel> activeAlarms,
  ) async {
    //Here  restores Alarms for Rechedule
    try {
      if (await isRinging || activeAlarms.isEmpty) {
        return activeAlarms;
      }

      return await Future.wait(
        activeAlarms.map((al) {
          return _recheduleNextOccurrence(al);
        }).toList(),
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<AlarmModel> _recheduleNextOccurrence(AlarmModel alarm) async {
    try {
      if (alarm.alarmDaysModel.isEmpty) {
        final updatedAlarm = await _enureValidNextTriggerTime(alarm);
        await _setAlarm(updatedAlarm);

        return updatedAlarm;
      }

      // return alarm;R

      final relatedAlarms = {
        alarm.alarmId,
        ...alarm.alarmDaysModel
            .where((e) => e.excutionId != null)
            .map((alrm) => alrm.excutionId!),
      };
    
      await Future.wait(relatedAlarms.map(Alarm.stop));

      final validDays = alarm.alarmDaysModel
          .where((day) => day.repeatedDays != null && day.excutionId != null)
          .toList();

      final nowDateTime = tz.TZDateTime.now(tz.local);
      final searchStart = tz.TZDateTime(
        tz.local,
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        alarm.firedTime.hour,
        alarm.firedTime.minute,
      );

      alarm = alarm.copyWith(
        nextTrigger: searchStart,
      ); //Move Base Time to Currentlly
      await Future.wait(
        validDays.map((day) async {
          final nextTriggerTime = _calculateNextRepeat(
            alarm.nextTrigger,
            day.repeatedDays!,
            alarm.firedTime,
          );

          final updatedAlarm = alarm.copyWith(
            alarmId: day.excutionId!,
            nextTrigger: nextTriggerTime,
          );

          return _setAlarm(updatedAlarm);
        }),
      );

      return alarm;
    } catch (e, stack) {
      throw ScheduleFailure(e, stack);
    }
  }

  Future<AlarmModel> _enureValidNextTriggerTime(AlarmModel alarm) async {
    //This will fix if any missed Alarm

    await Alarm.stop(alarm.alarmId);
    final nowDateTime = tz.TZDateTime.now(tz.local);
    if (alarm.nextTrigger.isBefore(nowDateTime) ||
        alarm.nextTrigger.isAtSameMomentAs(nowDateTime)) {
      final nearestExpectedNextTrigger = TimeManager.calculateNextTriggerTime(
        alarm.firedTime,
      );
      return alarm.copyWith(nextTrigger: nearestExpectedNextTrigger);
    }
    return alarm;
  }

  Future<AlarmModel> _scheduleRepeatDays(AlarmModel alarm) async {
    if (alarm.alarmDaysModel.isEmpty && alarm.repeatDays.isEmpty) {
      return alarm;
    } else if (alarm.repeatDays.isEmpty && alarm.alarmDaysModel.isNotEmpty) {
      //Meaning All repeated Days Removed

      final relatedAlarms = {
        ...alarm.alarmDaysModel
            .where((e) => e.excutionId != null)
            .map((alrm) => alrm.excutionId!),
      };

      await Future.wait(relatedAlarms.map(Alarm.stop));
      //come back to Orignal Alarm DateTime

      return alarm.copyWith(alarmDaysModel: []);
    } else if (alarm.repeatDays.isNotEmpty && alarm.alarmDaysModel.isEmpty) {
      //Meaning This First Time  repeated Days  added

      alarm = alarm.copyWith(
        alarmDaysModel: alarm.repeatDays
            .map(
              (d) => AlarmDaysModel(
                alarmId: alarm.alarmId,
                excutionId: generateId,
                repeatedDays: d,
              ),
            )
            .toList(),
      );
      return alarm;
    } else {
      //Here meaning some updated Occurred within Alarm Repeat Days
      final relatedAlarms = {
        ...alarm.alarmDaysModel
            .where((e) => e.excutionId != null)
            .map((alrm) => alrm.excutionId!),
      };

      await Future.wait(relatedAlarms.map(Alarm.stop));

      alarm = alarm.copyWith(
        alarmDaysModel: alarm.repeatDays
            .map(
              (d) => AlarmDaysModel(
                alarmId: alarm.alarmId,
                excutionId: generateId,
                repeatedDays: d,
              ),
            )
            .toList(),
      );
      return alarm;
    }
  }

  Future<AlarmModel> updateScheduledAlarm(AlarmModel alarmToSchedule) async {
    try {
      if (!alarmToSchedule.isEnabled) alarmToSchedule;
      var updatedAlarm = await _scheduleRepeatDays(alarmToSchedule);

      if (updatedAlarm.alarmDaysModel.isEmpty) {
        final alarm = await _enureValidNextTriggerTime(updatedAlarm);

        await _setAlarm(alarm);
        return alarm;
      }
      final nowDateTime = tz.TZDateTime.now(tz.local);
      final searchStart = tz.TZDateTime(
        tz.local,
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        updatedAlarm.firedTime.hour,
        updatedAlarm.firedTime.minute,
      );
      updatedAlarm = updatedAlarm.copyWith(
        nextTrigger: searchStart,
      ); //Move Base Time to Current Tiem
      await stopAlarm(updatedAlarm.alarmId);

      final validDays = updatedAlarm.alarmDaysModel
          .where((day) => day.repeatedDays != null && day.excutionId != null)
          .toList();

      await Future.wait(
        validDays.map((day) async {
          final nextTriggerTime = _calculateNextRepeat(
            updatedAlarm.nextTrigger,
            day.repeatedDays!,
            updatedAlarm.firedTime,
          );

          final nextAlarm = updatedAlarm.copyWith(
            alarmId: day.excutionId!,
            nextTrigger: nextTriggerTime,
          );

          return _setAlarm(nextAlarm);
        }),
      );

      return updatedAlarm;
    } catch (e, stack) {
      throw ScheduleFailure(e, stack);
    }
  }

  tz.TZDateTime _calculateNextRepeat(
    tz.TZDateTime from,

    AlarmDays repeatDays,
    TimeOfDay alarmTime,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    //Search within the current week (from today to +6 days)
    for (int i = 0; i < 7; i++) {
      final candidate = tz.TZDateTime(
        tz.local,
        from.year,
        from.month,
        from.day + i,
        alarmTime.hour,
        alarmTime.minute,
      );

      if (repeatDays.index == candidate.weekday - 1) {
        if (candidate.isBefore(now)) continue;

        return candidate;
      }
    }

    //Look if  No match, found this week calculate next week occurrence
    final targetWeekday = repeatDays.index + 1;

    final nextWeakDayTrigger = targetWeekday > now.weekday
        ? targetWeekday - now.weekday
        : 7 -
              (now.weekday -
                  targetWeekday); //Move to The Target day/compute days until target weekday

    final nextTrigger = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + nextWeakDayTrigger,
      alarmTime.hour,
      alarmTime.minute,
    );
    if (nextTrigger.isBefore(now)) {
      //Handle edge case,  same day but missed AM/PM
      return tz.TZDateTime.from(nextTrigger, tz.local).add(Duration(days: 7));
    }
    return nextTrigger;
  }
}
