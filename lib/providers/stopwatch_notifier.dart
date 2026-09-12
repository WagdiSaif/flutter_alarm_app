import 'dart:async';

import 'package:alarmapp/core/enums/stopwatch_enum.dart';
import 'package:alarmapp/data/models/laps.dart';
import 'package:alarmapp/data/models/stopwatch_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StopwatchNotifier extends Notifier<StopwatchState> {
  late Stopwatch _stopwatch;
  Timer? _timer;
  @override
  StopwatchState build() {
    _stopwatch = Stopwatch();
    ref.onDispose(() {
      _timer?.cancel();
    });

    return StopwatchState(
      laps: <Laps>[],
      currentDuration: Duration(),
      stopwatchButtonAction: StopwatchButtonAction.unknown,
    );
  }

  int? previousDuration;
  void start() {
    _stopwatch.start();
    _timer?.cancel();
    state = state.copyWith(stopwatchButtonAction: StopwatchButtonAction.start);
    previousDuration = previousDuration ?? state.currentDuration.inMilliseconds;

    _timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      final newDuration = Duration(
        milliseconds:
            (_stopwatch.elapsedMilliseconds + (previousDuration ?? 0)),
      );
      state = state.copyWith(currentDuration: newDuration);
      if (state.laps.isNotEmpty) {
        _updateLastLap();
      }
    });
  }

  void restart({StopwatchButtonAction? stopwatchButtonAction}) {
    state = state.copyWith(stopwatchButtonAction: stopwatchButtonAction);

    if (state.stopwatchButtonAction != StopwatchButtonAction.pause) {
      start();
    }
  }

  void _updateLastLap() {
    final laps = List<Laps>.from(state.laps);
    final lastRemovedLap = laps.removeLast();
    final now = state.currentDuration.inMilliseconds;

    final currentElapsed = laps.last.currentLapElapsed;

    final updatedLap = lastRemovedLap.copyWith(
      previousLapElapsed: Duration(
        milliseconds: now - currentElapsed.inMilliseconds,
      ),
      currentLapElapsed: Duration(milliseconds: now),
    );
    state = state.copyWith(laps: [...laps, updatedLap]);
  }

  void addLap() {
    final now = state.currentDuration.inMilliseconds;
    if (state.laps.isEmpty) {
      final lapStartDuration = Duration(milliseconds: now);
      state = state.copyWith(
        laps: [
          ...state.laps,
          Laps(
            currentLapElapsed: lapStartDuration,
            previousLapElapsed: lapStartDuration,
          ),
        ],
      );
    }

    final lastLap = state.laps.last;
    final newLap = Laps(
      previousLapElapsed:
          Duration(milliseconds: now) - lastLap.currentLapElapsed,
      currentLapElapsed: Duration(milliseconds: now),
    );
    state = state.copyWith(laps: [...state.laps, newLap]);
  }

  void reset() {
    state = state.copyWith(
      stopwatchButtonAction: StopwatchButtonAction.reset,

      currentDuration: Duration(),
      laps: [],
    );
    previousDuration = null;
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
  }

  bool get isRunning =>
      state.stopwatchButtonAction == StopwatchButtonAction.pause ||
      state.stopwatchButtonAction == StopwatchButtonAction.start;

  StopwatchState get getState => state;
  set setStopwatchState(StopwatchState watchState) => state = watchState;

  set backgroundLastState(StopwatchState watchState) {}

  void stop() {
    _timer?.cancel();
    state = state.copyWith(stopwatchButtonAction: StopwatchButtonAction.pause);

    _stopwatch.stop();
  }
}
