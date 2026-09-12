// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stopwatch_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StopwatchState _$StopwatchStateFromJson(Map<String, dynamic> json) =>
    StopwatchState(
      stopwatchButtonAction: $enumDecode(
        _$StopwatchButtonActionEnumMap,
        json['stopwatchButtonAction'],
      ),
      laps: (json['laps'] as List<dynamic>)
          .map((e) => Laps.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentDuration: const DurationInMilisecondConverter().fromJson(
        (json['currentDuration'] as num).toInt(),
      ),
    );

Map<String, dynamic> _$StopwatchStateToJson(StopwatchState instance) =>
    <String, dynamic>{
      'laps': instance.laps,
      'currentDuration': const DurationInMilisecondConverter().toJson(
        instance.currentDuration,
      ),
      'stopwatchButtonAction':
          _$StopwatchButtonActionEnumMap[instance.stopwatchButtonAction]!,
    };

const _$StopwatchButtonActionEnumMap = {
  StopwatchButtonAction.pause: 'pause',
  StopwatchButtonAction.start: 'start',
  StopwatchButtonAction.lap: 'lap',
  StopwatchButtonAction.reset: 'reset',
  StopwatchButtonAction.unknown: 'unknown',
};
