
import 'package:alarmapp/helper/constants.dart';
import 'package:alarmapp/model/alarm_model.dart';
import 'package:alarmapp/services/alarm_service.dart';
import 'package:alarmapp/services/alarm_storage.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'notification_settings.g.dart';

@riverpod
class AlarmController extends _$AlarmController {
  @override
 List<AlarmModel> build() {
 loadAlarms();
return [];
  } 

  // Load alarms
  Future<void> loadAlarms() async {
    state = await AlarmStorage.loadAllAlarms();
  }

  // Add new alarm
  Future<bool> addAlarm({required AlarmModel alarm}) async {
    try {
      // Save to storage first
      final saved = await AlarmStorage.saveAlarm(alarm);
      if (!saved) return false;

      // Update state
      state = [...state, alarm];

      // Schedule the alarm
      final notificationService = AlarmNotificationService();
      await notificationService.scheduleNotification(alarm);

      return true;
    } catch (e) {
      debugPrint('Error adding alarm: $e');
      return false;
    }
  }

  // Update existing alarm
  Future<bool> updateAlarm(AlarmModel updatedAlarm) async {
    try {
      // Update in storage
      final updated = await AlarmStorage.updateAlarm(updatedAlarm);
      if (!updated) return false;

      // Update state
      state = state.map((a) => a.id == updatedAlarm.id ? updatedAlarm : a).toList();

      // Reschedule if enabled
      final notificationService = AlarmNotificationService();
      if (updatedAlarm.isEnabled) {
        await notificationService.scheduleNotification(updatedAlarm);
      } else {
        await AndroidAlarmManager.cancel(updatedAlarm.id);
      }

      return true;
    } catch (e) {
      debugPrint('Error updating alarm: $e');
      return false;
    }
  }

  // Delete alarm
    Future<bool> deleteAllAlarm() async {
    try {
      // Cancel scheduled alarm
        await FlutterForegroundTask.stopService();
      //final prefs = AlarmStorage.sharedPreferences;
           final prefs = AlarmStorage.sharedPreferences;
    //  await prefs.remove(AppConstants.alarmsKey);
  await prefs.clear();
       state = await AlarmStorage.loadAllAlarms();

      return true;
    } catch (e) {
      debugPrint('Error deleting alarm: $e');
      return false;
    }
  }
  
  Future<bool> deleteAlarm(int alarmId) async {
    try {
      // Cancel scheduled alarm
        await FlutterForegroundTask.stopService();
      await AndroidAlarmManager.cancel(alarmId);

      // Delete from storage
      final deleted = await AlarmStorage.deleteAlarm(alarmId);
      if (!deleted) return false;

      // Update state
      state = state.where((a) => a.id != alarmId).toList();

      return true;
    } catch (e) {
      debugPrint('Error deleting alarm: $e');
      return false;
    }
  }

  // Toggle alarm enabled state
  Future<bool> toggleAlarm(int alarmId) async {
    final index = state.indexWhere((a) => a.id == alarmId);
    if (index == -1) return false;

    final updated = state[index].copyWith(isEnabled: !state[index].isEnabled);
    return await updateAlarm(updated);
  }
}