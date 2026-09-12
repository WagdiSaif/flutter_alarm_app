import 'package:json_annotation/json_annotation.dart';

import 'stopwatch_state.dart';

part 'laps.g.dart';

@JsonSerializable(converters: [DurationInMilisecondConverter()])
class Laps {
  final Duration previousLapElapsed;
  final Duration currentLapElapsed;
  factory Laps.fromJson(Map<String, dynamic> json) => _$LapsFromJson(json);
  Map<String, dynamic> toJson() => _$LapsToJson(this);

  Laps({required this.previousLapElapsed, required this.currentLapElapsed});
  Laps copyWith({Duration? previousLapElapsed, Duration? currentLapElapsed}) {
    return Laps(
      previousLapElapsed: previousLapElapsed ?? this.previousLapElapsed,
      currentLapElapsed: currentLapElapsed ?? this.currentLapElapsed,
    );
  }
}
