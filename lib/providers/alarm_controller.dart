import 'dart:async';
import 'dart:developer';

import 'package:alarmapp/data/repositories/alarm_repository.dart';
import 'package:alarmapp/services/alarm_shared_preference.dart';
import 'package:alarmapp/core/extensions.dart';

import 'package:alarmapp/data/models/alarm_model.dart';
import 'package:alarmapp/services/alarm_scheduler.dart';

import 'package:flutter/material.dart';

import 'package:timezone/timezone.dart' as tz;

class AlarmController {
  AlarmController(this.scheduler, {required AlarmRepository repository})
    : _repository = repository;

  final AlarmScheduler scheduler;
  final AlarmRepository _repository;

  Stream<List<AlarmModel>> get alarmStream => _repository.streamAlarm();

  Future<bool> addAlarm({
    required TimeOfDay selectedTime,
    required String title,
    required tz.TZDateTime fireAt,
  }) async {
    final alarmId = scheduler.generateId;
    final alarm = AlarmModel(
      alarmId: alarmId, // Unique ID
      firedTime: selectedTime,
      nextTrigger: fireAt,
      name: '',
      title: title,
      isEnabled: true,
      createdDate: DateTime.now().toLocalTz,
    );

    // Save to DB
    final isSaved = await _repository.saveAlarm(alarm);

    if (!isSaved) return false;

    try {
      await scheduler.scheduleAlarm(alarm);
      return true;
    } catch (e, stack) {
      log(e.toString(), error: e, stackTrace: stack);

      await _repository.deleteAlarmById(alarmId);

      return false;
    }
  }

  Future<void> rescheduleAlarms() async {
    if (await scheduler.isRinging) return;
    var activeAlarms = await _repository.fetchAllAlarms();

    if (activeAlarms.isEmpty) return;
    try {
      final restoredAlarms = await scheduler.reschedulePresentAlarms(
        activeAlarms,
      );
      await _repository.saveAllAlarms(restoredAlarms);
    } catch (e, stack) {
      log(e.toString(), error: e, stackTrace: stack);
    }
  }

  Future<bool> updateAlarm(AlarmModel updatedAlarm) async {
    try {
      if (!updatedAlarm.isEnabled) {
        final isUpdated = await _repository.saveUpdatedAlarm(updatedAlarm);
        return isUpdated;
      }
      final scheduledAlarm = await scheduler.updateScheduledAlarm(updatedAlarm);
      final isUpdated = await _repository.saveUpdatedAlarm(scheduledAlarm);

      return isUpdated;
    } catch (e, stack) {
      log(e.toString(), error: e, stackTrace: stack);

      return false;
    }
  }

  Future<bool> deleteAlarm(AlarmModel alarm) async {
    try {
      await scheduler.cancelScheduledAlarm(alarm);
    } catch (e, stack) {
      log(e.toString(), error: e, stackTrace: stack);
    }
    return await _repository.deleteAlarmById(alarm.alarmId);
  }

  Future<bool> toggleAlarm(AlarmModel alarm) async {
    final bool newState = !alarm.isEnabled;
    if (newState) {
      final update = await updateAlarm(alarm.copyWith(isEnabled: newState));
      return update;
    }
    try {
      await scheduler.cancelScheduledAlarm(alarm);
    } catch (e, stack) {
      log(e.toString(), error: e, stackTrace: stack);
    }
    return await _repository.saveUpdatedAlarm(
      alarm.copyWith(isEnabled: newState),
    );
  }

  Future<bool> canNavigateToRingingScreen(int id) async {
    bool isNavigationAllowed = true;
    await AlarmSharedPrefs.preferencesReload();
    ////Prevent duplicate Navigation for the Same Alarm
    if (AlarmSharedPrefs.isRingingState &&
        AlarmSharedPrefs.getRingingId == id) {
      await scheduler.stopAlarm(id);
      isNavigationAllowed = false;
    }
    //Prevent Navigation Upcoming Alarm if Already any Snooze found
    if (AlarmSharedPrefs.isSnoozeState &&
        AlarmSharedPrefs.getSnoozeId != 0 &&
        AlarmSharedPrefs.getSnoozeId != id) {
      await scheduler.stopAlarm(id);
      isNavigationAllowed = false;
    }
    //Prevent incoming Alarm Navigation if There is Already Alarm found
    if (AlarmSharedPrefs.isRingingState &&
        AlarmSharedPrefs.getRingingId != id) {
      await scheduler.stopAlarm(id);
      isNavigationAllowed = false;
    }
    return isNavigationAllowed;
  }

  Stream<List<Map<String, dynamic>>> get sounds => _repository.alarmsSlounds();
  Future<void> addCustomSound(String path) async =>
      await _repository.addSound(path);
  Future<void> deleteSound(int id) async =>
      await _repository.removeSoundById(id);
}
