import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:alarmapp/core/utils/functions.dart';
import 'package:alarmapp/services/alarm_shared_preference.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:alarmapp/core/enums/enums.dart';
import 'package:alarmapp/data/models/alarm_days_model.dart';

import 'package:alarmapp/data/models/alarm_model.dart';

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
      androidStopAlarmOnTermination: false,
      id: alarm.alarmId,

      allowAlarmOverlap: false,
      dateTime: alarm.nextTrigger,
      assetAudioPath: alarm.soundPath,
      loopAudio: true,
      vibrate: alarm.vibrate,
      iOSBackgroundAudio: true,
      allowSameSecondScheduling: false,
      androidSnoozeDuration: Duration(minutes: 2),

      warningNotificationOnKill: true,
      androidFullScreenIntent: true,

      volumeSettings: VolumeSettings.fade(
        volume: 0.5,
        fadeDuration: const Duration(minutes: 2),
        volumeEnforced: false,
      ),
      notificationSettings: NotificationSettings(
        androidStopAlarmOnDismiss: false,

        title: alarm.title,
        body: alarm.name,
        icon: 'ic_bg_service_notification',
        stopButton: 'STOP',
        androidSnoozeButton: "Snooze",
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
  }

  // Snooze alarm
  Future<void> snoozeAlarm(int orignalId, tz.TZDateTime current) async {
    final activeAlarm = await Alarm.getAlarm(orignalId);
    final alarmSharedPrefs = AlarmSharedPrefs.instance;
    if (activeAlarm == null) return;
    await stopAlarm(orignalId);

    final snoozeId = generateId;

    await alarmSharedPrefs.removeAllState();
    await alarmSharedPrefs.setAlarmState(snooze, snoozeId);
    await Alarm.set(
      alarmSettings: activeAlarm.copyWith(
        id: snoozeId,
        dateTime: current.add(Duration(minutes: 2)),
      ),
    );
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.isEnabled) return;

    await _setAlarm(alarm);
  }

  Future<bool> get isRinging async => await Alarm.isRinging();

  Future<List<AlarmModel>> reschedulePresentAlarms(
    List<AlarmModel> activeAlarms,
  ) async {
    if (await isRinging || activeAlarms.isEmpty) {
      return activeAlarms;
    }

    return await Future.wait(
      activeAlarms.map((al) {
        return _recheduleNextOccurrence(al);
      }).toList(),
    );
  }

  Future<AlarmModel> _recheduleNextOccurrence(AlarmModel alarm) async {
    if (!alarm.isEnabled) return alarm;
    if (alarm.alarmDaysModel.isEmpty) {
      final updatedAlarm = await _enureValidNextTriggerTime(alarm);
      await _setAlarm(updatedAlarm);

      return updatedAlarm;
    }

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
  }

  Future<AlarmModel> _enureValidNextTriggerTime(AlarmModel alarm) async {
    // fix if any missed Alarm

    await Alarm.stop(alarm.alarmId);
    final nowDateTime = tz.TZDateTime.now(tz.local);
    if (alarm.nextTrigger.isBefore(nowDateTime) ||
        alarm.nextTrigger.isAtSameMomentAs(nowDateTime)) {
      final nearestExpectedNextTrigger = calculateNextTriggerTime(
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
      // This First Time  repeated Days  added

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
  }

  tz.TZDateTime _calculateNextRepeat(
    tz.TZDateTime from,

    AlarmDays repeatDays,
    TimeOfDay alarmTime,
  ) {
    final now = tz.TZDateTime.now(tz.local);

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
        : 7 - (now.weekday - targetWeekday); //Move to The Target day/compute days until target weekday

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
      return tz.TZDateTime(
        tz.local,
        nextTrigger.year,
        nextTrigger.month,
        nextTrigger.day + 7,
        alarmTime.hour,
        alarmTime.minute,
      );
    }
    return nextTrigger;
  }
}
