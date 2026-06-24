import 'package:alarmapp/core/enum/enums.dart';
import 'package:alarmapp/core/constants/constant.dart';
import 'package:alarmapp/data/models/alarm_days_model.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class AlarmModel {
  final int alarmId;

  final String name;
  final List<AlarmDays> repeatDays;
  final String soundPath;

  final bool isEnabled;

  final tz.TZDateTime nextTrigger;

  final tz.TZDateTime createdDate;
  final List<AlarmDaysModel> alarmDaysModel;
  final String title;

  final bool vibrate;

  final TimeOfDay firedTime;

  AlarmModel({
    this.repeatDays = const [],
    required this.firedTime,
    this.alarmDaysModel = const [],

    required this.alarmId,
    required this.nextTrigger,
    this.soundPath = AppConstants.defaultSound,

    this.vibrate = false,
    this.name = '',
    this.isEnabled = true,
    required this.createdDate,

    this.title = '',
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      repeatDays: json['repeatDays'] as List<AlarmDays>,
      firedTime: json['firedTime'] as TimeOfDay,
      alarmDaysModel: (json['alarmDaysModel'] as List).cast<AlarmDaysModel>(),
      alarmId: json['alarmId'] as int,
      isEnabled: json['isEnabled'] as bool,

      nextTrigger: tz.TZDateTime.parse(tz.local, json['nextTrigger']),

      createdDate: tz.TZDateTime.parse(tz.local, json['createdDate']),
      soundPath: json['soundPath'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
    );
  }

  AlarmModel copyWith({
    List<AlarmDays>? repeatDays,
    int? alarmId,
    List<AlarmDaysModel>? alarmDaysModel,

    String? name,
    bool? isEnabled,
    List<int>? repeatDaysIndices,
    String? soundPath,

    tz.TZDateTime? createdDate,
    tz.TZDateTime? nextTrigger,
    String? title,

    bool? vibrate,
    TimeOfDay? firedTime,
  }) {
    return AlarmModel(
      repeatDays: repeatDays ?? this.repeatDays,
      firedTime: firedTime ?? this.firedTime,
      alarmDaysModel: alarmDaysModel ?? this.alarmDaysModel,
      alarmId: alarmId ?? this.alarmId,
      vibrate: vibrate ?? this.vibrate,

      name: name ?? this.name,
      isEnabled: isEnabled ?? this.isEnabled,

      soundPath: soundPath ?? this.soundPath,

      createdDate: createdDate ?? this.createdDate,
      nextTrigger: nextTrigger ?? this.nextTrigger,
      title: title ?? this.title,
    );
  }
}
