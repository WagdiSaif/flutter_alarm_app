import 'dart:async';

import 'package:alarmapp/core/enums/timer_enum.dart';
import 'package:alarmapp/data/models/timer_state.dart';
import 'package:alarmapp/foreground_service/audio_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final audioHandlerProvider = FutureProvider<AudioHandler>((ref) async {
  final handler = AudioHandler(audioPlayer: AudioPlayer());
  await handler.initAudioSource();
  ref.onDispose(() {
    handler.dispose();
  });
  return handler;
});

class TimerNotifier extends Notifier<TimerState> {
  @override
  TimerState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    return TimerState(
      timerButtonAction: TimerButtonAction.unknown,
      startedDuration: Duration(minutes: 1),
      currentDuration: Duration(minutes: 1),
    );
  }

  Timer? _timer;

  void selectPreset(Duration startDuration) {
    state = state.copyWith(
      timerButtonAction: TimerButtonAction.reset,
      startedDuration: startDuration,
      currentDuration: startDuration,
    );
  }

  Duration get remainingDuration => state.currentDuration;
  void start() {
    _timer?.cancel();

    final audioAsync = ref.read(audioHandlerProvider);
    final handler = audioAsync.value;

    state = state.copyWith(timerButtonAction: TimerButtonAction.resume);
    _timer = Timer.periodic(Duration(seconds: 1), (_) async {
      if (state.currentDuration <= Duration.zero) {
        if (!(handler?.isPlaying ?? false)) {
          await handler?.startPlayer();
        }
      }
      state = state.copyWith(
        currentDuration: state.currentDuration - Duration(seconds: 1),
      );
    });
  }

  void restart({Duration? remaining, TimerButtonAction? timerButtonAction}) {
    state = state.copyWith(
      timerButtonAction: timerButtonAction,

      currentDuration: remaining,
    );

    if (state.timerButtonAction != TimerButtonAction.pause) {
      start();
    }
  }

  bool get isRunning =>
      state.timerButtonAction == TimerButtonAction.resume ||
      state.timerButtonAction == TimerButtonAction.pause;
  TimerState get getState => state;
  set setTimerState(TimerState watchState) => state = watchState;

  void pause() {
    _timer?.cancel();
    state = state.copyWith(timerButtonAction: TimerButtonAction.pause);
  }

  void addOneMinute() async {
    final audioAsync = ref.read(audioHandlerProvider);
    final handler = audioAsync.value;
    if ((handler?.isPlaying ?? false)) {
      await handler?.stopPlayer();
    }
    state = state.copyWith(
      timerButtonAction: TimerButtonAction.addOneMinute,
      startedDuration: Duration(minutes: 1),
      currentDuration: Duration(minutes: 1),
    );
  }

  void reset() async {
    _timer?.cancel();
    final audioAsync = ref.read(audioHandlerProvider);
    final handler = audioAsync.value;
    if ((handler?.isPlaying ?? false)) {
      await handler?.stopPlayer();
    }
    state = state.copyWith(
      timerButtonAction: TimerButtonAction.reset,

      currentDuration: state.startedDuration,
    );
  }
}
