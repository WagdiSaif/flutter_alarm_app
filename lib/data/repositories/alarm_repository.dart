import 'package:alarmapp/data/models/alarm_model.dart';

abstract interface class AlarmRepository {
  Future<bool> saveAlarm(AlarmModel alarm);
  Stream<List<AlarmModel>> streamAlarm();
  Future<List<AlarmModel>> fetchAllAlarms();
  Future<List<AlarmModel>> getActiveAlarms();
  Future<AlarmModel?> getAlarmById(int alarmId);
  Future<bool> saveAllAlarms(List<AlarmModel> alarm);
  Future<bool> deleteAlarmById(int alarmId);
  Future<bool> saveUpdatedAlarm(AlarmModel alarm);
  Stream<List<Map<String, dynamic>>> alarmsSlounds();
  Future<bool> removeSoundById(int alarmId);
  Future<bool> addSound(String soundPath);
}
