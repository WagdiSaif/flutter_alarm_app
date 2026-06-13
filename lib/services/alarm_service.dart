import 'dart:async';

import 'dart:developer';

import 'package:alarmapp/data/repositories/alarm_repository.dart';

import 'package:alarmapp/data/models/alarm_model.dart';

class AlarmService {
  final AlarmRepository _alarmRepository;

  AlarmService(this._alarmRepository);

  Stream<List<AlarmModel>> alarmsWatch() {
    return _alarmRepository.alarmsStream();
  }

  Future<bool> addAlarm(AlarmModel alarm) async {
    try {
      await _alarmRepository.saveAlarm(alarm);

      return true;
    } catch (e, stack) {
      log('Add alarm failed', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<bool> insertAll(List<AlarmModel> alarm) async {
    try {
      await _alarmRepository.saveAllAlarms(alarm);

      return true;
    } catch (e, stack) {
      log('Save All alarm failed', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<List<AlarmModel>> getAllAlarms() async {
    try {
      return await _alarmRepository.fetchAllAlarms();
    } catch (e, stack) {
      log('fetch All Alrms failed', error: e, stackTrace: stack);
      return [];
    }
  }

  Future<AlarmModel?> getAlarmById(int alarmId) async {
    try {
      return await _alarmRepository.getAlarmById(alarmId);
    } catch (e, stack) {
      log('fetch alarm failed', error: e, stackTrace: stack);
      return null;
    }
  }

  Future<bool> deleteAlarmById(int alarmId) async {
    final rowsAffected = await _alarmRepository.removeAlarmById(alarmId);
    if (rowsAffected == 0) {
      return false;
    }
    return true;
  }

  Future<bool> updateAlarm(AlarmModel alarm) async {
    try {
      await _alarmRepository.updateAlarm(alarm);

      return true;
    } catch (e, stack) {
      log('Update alarm failed', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<List<AlarmModel>> getActiveAlarms() async {
    try {
      return await _alarmRepository.getActiveAlarms();
    } catch (e, stack) {
      log(' Failed to get active alarms: ', error: e, stackTrace: stack);
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> watchAlarmSounds() {
    return _alarmRepository.alarmsSlounds();
  }

  Future<void> addSound(String path) async {
    try {
      await _alarmRepository.addAlarmSound(path);
    } catch (e, stack) {
      log("Add Alarm Sound Failed", error: e, stackTrace: stack);
    }
  }

  Future<void> removeSound(int id) async {
    try {
      await _alarmRepository.removeSoundById(id);
    } catch (e, stack) {
      log("Delete Alarm Sound Failed", error: e, stackTrace: stack);
    }
  }
}
