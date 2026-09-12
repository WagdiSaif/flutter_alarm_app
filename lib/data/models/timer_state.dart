import 'package:alarmapp/core/enums/timer_enum.dart';

class TimerState {
  final Duration startedDuration;
  final Duration currentDuration;

  final TimerButtonAction timerButtonAction;

  TimerState({
    required this.timerButtonAction,
    required this.startedDuration,
    required this.currentDuration,
  });

  TimerState copyWith({
    TimerButtonAction? timerButtonAction,
    Duration? startedDuration,
    Duration? currentDuration,
  }) {
    return TimerState(
      timerButtonAction: timerButtonAction ?? this.timerButtonAction,
      startedDuration: startedDuration ?? this.startedDuration,
      currentDuration: currentDuration ?? this.currentDuration,
    );
  }
}
