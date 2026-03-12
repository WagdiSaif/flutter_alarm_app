import 'package:flutter/material.dart';

enum AlarmDays {
  monday,//weakday 1
  tuesday,//2
  wednesday,//3
  thursday,
  friday,
  saturday,
  sunday;

    String get shortName {
    switch (this) {
      case AlarmDays.monday:
        return 'Mon';
      case AlarmDays.tuesday:
        return 'Tue';
      case AlarmDays.wednesday:
        return 'Wed';
      case AlarmDays.thursday:
        return 'Thu';
      case AlarmDays.friday:
        return 'Fri';
      case AlarmDays.saturday:
        return 'Sat';
      case AlarmDays.sunday:
        return 'Sun';
    }
  }
}

enum AlarmSound {

  fajar('Azaan_Alarm', 'fajar_azaan_alarm'),
  birds('Birds', 'alarm_sound'),
  alarm('Alarm', 'alarm_sound_2'),
  musical('Musical', 'musical_alarm'),
  defaultSound('Default', 'default');

  final String label;
  final String fileName;

  const AlarmSound(this.label, this.fileName);
}

class AlarmModel {
  final int id;
  final TimeOfDay firedTime;
  final String title;
   bool isEnabled;
  final List<AlarmDays> repeatDays;
  final AlarmSound sound;
  final int snoozeDuration;
  final int? snoozeCount;
  final DateTime? createdDate;
  final DateTime? lastTriggered;
  final String? note;
  final DateTime firedAt;

  AlarmModel({
    required this.id,
    required this.firedTime,
    required this.firedAt,
    this.title = 'Alarm',
    this.isEnabled = true,
    this.repeatDays = const [],
    this.sound = AlarmSound.defaultSound,
    this.snoozeDuration = 5,
    this.snoozeCount,
    this.createdDate,
    this.lastTriggered,
    this.note,
  });

  // Copy with new values
  AlarmModel copyWith({
    int? id,
    TimeOfDay? firedTime,
    String? title,
    bool? isEnabled,
    List<AlarmDays>? repeatDays,
    AlarmSound? sound,
    int? snoozeDuration,
    int? snoozeCount,
    DateTime? createdDate,
    DateTime? lastTriggered,
    String? note,
    DateTime? firedAt,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      firedTime: firedTime ?? this.firedTime,
      title: title ?? this.title,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      sound: sound ?? this.sound,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      createdDate: createdDate ?? this.createdDate,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      note: note ?? this.note,
      firedAt: firedAt ?? this.firedAt,
    );
  }






  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': firedTime.hour,
      'minute': firedTime.minute,
      'title': title,
      'isEnabled': isEnabled,
      'repeatDays': repeatDays.map((d) => d.index).toList(),
      'sound': sound.index,
      'snoozeDuration': snoozeDuration,
      'snoozeCount': snoozeCount,
      'createdDate': createdDate?.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
      'note': note,
      'firedAt': firedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      firedTime: TimeOfDay(
        hour: json['hour'],
        minute: json['minute'],
      ),
      title: json['title'] ?? 'Alarm',
      isEnabled: json['isEnabled'] ?? true,
      repeatDays: (json['repeatDays'] as List? ?? [])
          .map((i) => AlarmDays.values[i])
          .toList(),
      sound: AlarmSound.values[json['sound'] ?? 4],
      snoozeDuration: json['snoozeDuration'] ?? 5,
      snoozeCount: json['snoozeCount'],
      createdDate: json['createdDate'] != null
          ? DateTime.parse(json['createdDate'])
          : null,
      lastTriggered: json['lastTriggered'] != null
          ? DateTime.parse(json['lastTriggered'])
          : null,
      note: json['note'],
      firedAt: DateTime.parse(json['firedAt']),
    );
  }
}