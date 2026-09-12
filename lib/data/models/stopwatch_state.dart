import 'package:alarmapp/core/enums/stopwatch_enum.dart';
import 'package:alarmapp/data/models/laps.dart';
import 'package:json_annotation/json_annotation.dart';

part 'stopwatch_state.g.dart';

@JsonSerializable(converters: [DurationInMilisecondConverter()])
class StopwatchState {
  final List<Laps> laps;

  final Duration currentDuration;
  final StopwatchButtonAction stopwatchButtonAction;

  StopwatchState({
    required this.stopwatchButtonAction,
    required this.laps,
    required this.currentDuration,
  });
  StopwatchState copyWith({
    List<Laps>? laps,
    Duration? currentDuration,

    StopwatchButtonAction? stopwatchButtonAction,
  }) {
    return StopwatchState(
      stopwatchButtonAction:
          stopwatchButtonAction ?? this.stopwatchButtonAction,
      laps: laps ?? this.laps,
      currentDuration: currentDuration ?? this.currentDuration,
    );
  }

  factory StopwatchState.fromJson(Map<String, dynamic> json) =>
      _$StopwatchStateFromJson(json);

  Map<String, dynamic> toJson() => _$StopwatchStateToJson(this);
}

class DurationInMilisecondConverter implements JsonConverter<Duration, int> {
  const DurationInMilisecondConverter();
  @override
  Duration fromJson(int json) {
    return Duration(milliseconds: json);
  }

  @override
  int toJson(Duration object) {
    return object.inMilliseconds;
  }
}
