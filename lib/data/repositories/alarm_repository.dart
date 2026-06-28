import 'package:alarmapp/data/models/alarm_model.dart';

abstract interface class AlarmRepository {
  Future<void> saveAlarm(AlarmModel alarm);
  Stream<List<AlarmModel>> streamAlarm();
  Future<List<AlarmModel>> fetchAllAlarms();
  Future<List<AlarmModel>> getActiveAlarms();
  Future<AlarmModel?> getAlarmById(int alarmId);
  Future<void> saveAllAlarms(List<AlarmModel> alarm);
  Future<int> removeAlarmById(int alarmId);
  Future<void> saveUpdatedAlarm(AlarmModel alarm);
  Stream<List<Map<String, dynamic>>> alarmsSlounds();
  Future<void> removeSoundById(int alarmId);
  Future<void> addSound(String soundPath);
}
