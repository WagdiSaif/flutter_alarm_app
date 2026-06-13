import 'package:alarmapp/core/enum/enums.dart';

class AlarmDaysModel {
  final int? alarmId;
  final int? excutionId;
  final AlarmDays? repeatedDays;

  AlarmDaysModel({this.alarmId, this.excutionId, this.repeatedDays});
  factory AlarmDaysModel.toJson(Map<String, dynamic> json) {
    return AlarmDaysModel(
      alarmId: json['alarmId'] as int,
      excutionId: json['excutionId'] as int,
      repeatedDays: json['repeatDays'] as AlarmDays,
    );
  }

  AlarmDaysModel copyWith({
    int? alarmId,
    int? excutionId,
    AlarmDays? repeatedDays,
  }) {
    return AlarmDaysModel(
      alarmId: alarmId ?? this.alarmId,
      excutionId: alarmId ?? this.excutionId,
      repeatedDays: repeatedDays ?? this.repeatedDays,
    );
  }
}
