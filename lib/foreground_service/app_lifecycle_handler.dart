import 'dart:developer';

import 'package:alarmapp/core/enums/applifecycle_enum.dart';
import 'package:alarmapp/core/enums/stopwatch_enum.dart';
import 'package:alarmapp/core/enums/timer_enum.dart';
import 'package:alarmapp/data/models/stopwatch_state.dart';
import 'package:alarmapp/foreground_service/platform_initializer.dart';
import 'package:alarmapp/ui/home_screen.dart';
import 'package:alarmapp/ui/stopwatch_screen.dart';
import 'package:alarmapp/ui/timer_preset_screeen.dart';
import 'package:flutter/services.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppLifecycleHandler {
  final Ref _ref;

  AppLifecycleHandler({required this._ref});

  bool _isBackgroundServiceActive = false;

  Future<void> onBackground() async {
    try {
      if (_isBackgroundServiceActive) return;
      _isBackgroundServiceActive = true;

      final isStopwatchRunning = _ref
          .read(stopwatchStateProvider.notifier)
          .isRunning;
      final isTimerRunning = _ref.read(timerStateProvider.notifier).isRunning;

      if ((!isTimerRunning && !isStopwatchRunning)) return;

      final platform = _ref.read(platformInitializerProvider).platformType;

      if (platform == PlatformType.android) {
        await _onAndroidBackground();
      } else if (platform == PlatformType.ios) {
        await _onIosBackground();
      } else {
        throw PlatformException(code: "INVALID_ARGS");
      }
    } on Exception catch (e, stackTrace) {
      log(
        'Fialed To start Background Service $e stack is $stackTrace',
        // error: e,
        // stackTrace: stackTrace,
      );
    }
  }

  Future<void> _onIosBackground() async {
    final stopwatchState = _ref.read(stopwatchStateProvider.notifier);
    final timerState = _ref.read(timerStateProvider.notifier);

    final isStopwatchRunning = stopwatchState.isRunning;
    final isTimerRunning = timerState.isRunning;

    if ((!isTimerRunning && !isStopwatchRunning)) return;
    final foregroundServiceProvider = _ref.read(iosForegroundServiceProvider);
    final timerDuration = timerState.getState.currentDuration;
    Map<String, dynamic> prepareTimerData() {
      //prepare timer data
      return {
        "activeService": ActiveService.timer.name,
        "currentDuration": timerDuration.inSeconds,
        "timerButtonAction": timerState.getState.timerButtonAction.name,
      };
    }

    Map<String, dynamic> prepareStopwatchData() {
      //prepare timer data

      return {
        'currentDuration':
            stopwatchState.getState.currentDuration.inMilliseconds,
        'stopwatchButtonAction':
            stopwatchState.getState.stopwatchButtonAction.name,
        'activeService': ActiveService.stopwatch.name,
        'laps': stopwatchState.getState.laps
            .map((lap) => lap.toJson())
            .toList(),
      };
    }

    if (isTimerRunning && isStopwatchRunning) {
      final timerData = prepareTimerData();

      final stopwacthData = prepareStopwatchData();

      await Future.wait([
        foregroundServiceProvider.startBackgroundService(
          service: ActiveService.timer,
          data: timerData,
        ),
        foregroundServiceProvider.startBackgroundService(
          service: ActiveService.stopwatch,
          data: stopwacthData,
        ),
      ]);
    } else if (isTimerRunning) {
      final timerData = prepareTimerData();

      await foregroundServiceProvider.startBackgroundService(
        service: ActiveService.timer,
        data: timerData,
      );
    } else {
      final stopwacthData = prepareStopwatchData();

      await foregroundServiceProvider.startBackgroundService(
        service: ActiveService.stopwatch,
        data: stopwacthData,
      );
    }

    stopwatchState.reset(); //Reset State after Start Working in Background.

    timerState.reset(); //
  }

  Future<void> _onAndroidBackground() async {
    final stopwatchState = _ref.read(stopwatchStateProvider.notifier);
    final timerState = _ref.read(timerStateProvider.notifier);

    final isStopwatchRunning = stopwatchState.isRunning;
    final isTimerRunning = timerState.isRunning;

    if ((!isTimerRunning && !isStopwatchRunning)) return;
    final stopwatchData = stopwatchState.getState.toJson();
    final timerDuration = timerState.getState.currentDuration;
    final foregroundServiceProvider = _ref.read(
      androidForegroundServiceProvider,
    );
    List<Future<bool>> saveFutures = [];
    final ActiveService tragetService;

    if (isTimerRunning && isStopwatchRunning) {
      saveFutures.add(
        foregroundServiceProvider.saveLastTmerDuration(timerDuration),
      );

      saveFutures.add(
        foregroundServiceProvider.saveStopwatchStateOnExit(stopwatchData),
      );
      await Future.wait([
        foregroundServiceProvider.saveTimerButtonAction(
          timerState.getState.timerButtonAction.name,
        ),
        foregroundServiceProvider.saveStopwatchButtonAction(
          stopwatchState.getState.stopwatchButtonAction.name,
        ),
      ]);
      tragetService = ActiveService.both;
    } else if (isTimerRunning) {
      saveFutures.add(
        foregroundServiceProvider.saveLastTmerDuration(timerDuration),
      );
      await Future.wait([
        foregroundServiceProvider.saveTimerButtonAction(
          timerState.getState.timerButtonAction.name,
        ),
      ]);
      tragetService = ActiveService.timer;
    } else {
      saveFutures.add(
        foregroundServiceProvider.saveStopwatchStateOnExit(stopwatchData),
      );
      await Future.wait([
        foregroundServiceProvider.saveStopwatchButtonAction(
          stopwatchState.getState.stopwatchButtonAction.name,
        ),
      ]);
      tragetService = ActiveService.stopwatch;
    }

    final result = await Future.wait(saveFutures);
    final isSaved = result.every((result) => result == true);
    await foregroundServiceProvider.startBackgroundService(
      service: isSaved ? tragetService : ActiveService.none,
    );
    stopwatchState.reset(); //Reset State after Start Working in Background.

    timerState.reset(); //
  }

  Future<void> onResume() async {
    _isBackgroundServiceActive = false;
    final platform = _ref.read(platformInitializerProvider).platformType;
    try {
      if (platform == PlatformType.android) {
        await _onAndroidResume();
      } else if (platform == PlatformType.ios) {
        await _onIosResume();
      } else {
        throw PlatformException(code: "INVALID_ARGS");
      }
    } on Exception catch (e, stackTrace) {
      log(
        'Fialed To start Background Service',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _onAndroidResume() async {
    final foregroundServiceProvider = _ref.read(
      androidForegroundServiceProvider,
    );
    await foregroundServiceProvider.reloadPreferences();

    final stopwatchState = _ref.read(stopwatchStateProvider.notifier);
    final timerState = _ref.read(timerStateProvider.notifier);
    await foregroundServiceProvider.cancellAllNotifications();

    var [timerRemainingDuration as int?, timerActionName as String?] = [
      foregroundServiceProvider.retrieveLastTimerDuration(),
      foregroundServiceProvider.timerButtonAction(),
    ];

    if (timerRemainingDuration != null) {
      timerState.restart(
        remaining: Duration(seconds: timerRemainingDuration),
        timerButtonAction: TimerButtonAction.byname(timerActionName ?? ''),
      );
    }

    var [stopWatchState as StopwatchState?, actionName as String?] = [
      foregroundServiceProvider.retrieveBackgroundStopwatchState(),
      foregroundServiceProvider.stopwatchButtonAction(),
    ];

    if (stopWatchState != null) {
      stopwatchState.setStopwatchState = stopWatchState;
      stopwatchState.restart(
        stopwatchButtonAction: StopwatchButtonAction.byname(actionName ?? ""),
      );
    }

    await foregroundServiceProvider.removeFullBackgroundService();
  }

  Future<void> _onIosResume() async {
    final foregroundServiceProvider = _ref.read(iosForegroundServiceProvider);
    final stopwatchState = _ref.read(stopwatchStateProvider.notifier);
    final timerState = _ref.read(timerStateProvider.notifier);

    final data = await foregroundServiceProvider.retrieveTimerBackgroundData();

    if (data != null) {
      final timerRemainingDuration = data.currentDuration;
      final timerAction = data.buttonAction;

      timerState.restart(
        remaining: Duration(seconds: timerRemainingDuration),
        timerButtonAction: timerAction,
      );
    }

    final stopWatchState = await foregroundServiceProvider
        .retrieveBackgroundStopwatchState();

    if (stopWatchState != null) {
      stopwatchState.setStopwatchState = stopWatchState;
      stopwatchState.restart(
        stopwatchButtonAction: stopWatchState.stopwatchButtonAction,
      );
    }
    await foregroundServiceProvider.cancellAllNotifications();
    await foregroundServiceProvider.removeFullBackgroundService();
  }
}
