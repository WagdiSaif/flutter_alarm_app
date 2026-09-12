// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laps.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Laps _$LapsFromJson(Map<String, dynamic> json) => Laps(
  previousLapElapsed: const DurationInMilisecondConverter().fromJson(
    (json['previousLapElapsed'] as num).toInt(),
  ),
  currentLapElapsed: const DurationInMilisecondConverter().fromJson(
    (json['currentLapElapsed'] as num).toInt(),
  ),
);

Map<String, dynamic> _$LapsToJson(Laps instance) => <String, dynamic>{
  'previousLapElapsed': const DurationInMilisecondConverter().toJson(
    instance.previousLapElapsed,
  ),
  'currentLapElapsed': const DurationInMilisecondConverter().toJson(
    instance.currentLapElapsed,
  ),
};
