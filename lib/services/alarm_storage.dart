import 'dart:convert';
import 'package:alarmapp/model/alarm_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alarmapp/helper/constants.dart';


 class AlarmStorage {
  static final AlarmStorage _instance = AlarmStorage._internal();
  factory AlarmStorage() => _instance;
  AlarmStorage._internal();

  static late SharedPreferences sharedPreferences;

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  // Load all alarms
  static Future<List<AlarmModel>> loadAllAlarms() async {
  //  await sharedPreferences.remove(AppConstants.alarmKey);
    final raw = sharedPreferences.getStringList(AppConstants.alarmsKey) ?? [];
    if(raw.isEmpty) return <AlarmModel>[];
    debugPrint('Alram is found ${raw.first}');
    return raw
        .map((e) => AlarmModel.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  // Save alarm
  static Future<bool> saveAlarm(AlarmModel alarm) async {
    final alarms = await loadAllAlarms();

    alarms.add(alarm);
    return await _saveAlarms(alarms);
  }

  // Update alarm
  static Future<bool> updateAlarm(AlarmModel updatedAlarm) async {
    final alarms = await loadAllAlarms();
    
    final index = alarms.indexWhere((a) => a.id == updatedAlarm.id);
    if (index == -1) return false;

    alarms[index] = updatedAlarm;
    return await _saveAlarms(alarms);
  }

  // Delete alarm
  static Future<bool> deleteAlarm(int alarmId) async {
    final alarms = await loadAllAlarms();
    if(alarms.isEmpty) return false;
    alarms.removeWhere((a) => a.id == alarmId);
    return await _saveAlarms(alarms);
  }

  // Find alarm by ID
  static Future<AlarmModel?> findAlarmById(int alarmId) async {
    final alarms = await loadAllAlarms();
    try {
      return alarms.firstWhere((a) => a.id == alarmId);
    } catch (_) {
      return null;
    }
  }

  // Save alarms list
  static Future<bool> _saveAlarms(List<AlarmModel> alarms) async {
    final encoded = alarms.map((a) => jsonEncode(a.toJson())).toList();
    return await sharedPreferences.setStringList(AppConstants.alarmsKey, encoded);
  }
}
