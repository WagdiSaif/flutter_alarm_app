import 'dart:async';
import 'package:alarmapp/data/models/timer_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier()
    : super(
        TimerState(
          selectedDuration: const Duration(minutes: 5),
          remaining: Duration.zero,
          isRunning: false,
        ),
      );

  Timer? _timer;

  void start() {
    if (state.remaining == Duration.zero) {
      state = state.copyWith(remaining: state.selectedDuration);
    }

    state = state.copyWith(isRunning: true);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remaining.inSeconds > 0) {
        state = state.copyWith(
          remaining: state.remaining - const Duration(seconds: 1),
        );
      } else {
        _finish();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(remaining: Duration.zero, isRunning: false);
  }

  void selectPreset(Duration duration) {
    _timer?.cancel();
    state = state.copyWith(
      selectedDuration: duration,
      remaining: duration,
      isRunning: false,
    );
  }

  void _finish() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
