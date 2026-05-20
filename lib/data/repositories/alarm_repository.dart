import 'package:alarmapp/models/alarm_model.dart';

abstract class AlarmRepository {
  Future<void> saveAlarm(AlarmModel alarm);
  Stream<List<AlarmModel>> alarmsStream();
  Future<List<AlarmModel>> fetchAllAlarms();
  Future<List<AlarmModel>> getActiveAlarms();
  Future<AlarmModel?> getAlarmById(int alarmId);
  Future<void> saveAllAlarms(List<AlarmModel> alarm);
  Future<int> removeAlarmById(int alarmId);
  Future<void> updateAlarm(AlarmModel alarm);
}
