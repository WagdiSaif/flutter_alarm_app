import 'dart:developer';

import 'package:alarmapp/core/enums/applifecycle_enum.dart';
import 'package:alarmapp/core/enums/stopwatch_enum.dart';
import 'package:alarmapp/core/enums/timer_enum.dart';
import 'package:alarmapp/core/utils/functions.dart';
import 'package:alarmapp/data/models/stopwatch_state.dart';
import 'package:alarmapp/foreground_service/android_platform/android_foreground_service.dart';
import 'package:alarmapp/foreground_service/android_platform/android_notifications.dart';
import 'package:alarmapp/foreground_service/audio_source.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundServiceHandler extends TaskHandler {
  final AudioHandler audioSource;
  final AndroidForegroundService androidForegroundService;
  final AndroidNotifications notifications;
  ForegroundServiceHandler({
    required this.audioSource,
    required this.androidForegroundService,
    required this.notifications,
  });
  Stopwatch? _stopwatch;
  ActiveService _activeService = ActiveService.none;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    try {
      final service = _activeService = await androidForegroundService
          .determineActiveService();
      String text = androidForegroundService.notificationText(service);

      if (service == ActiveService.stopwatch) {
        final retrievedState = androidForegroundService.retrieveStopwatchSate();
        if (retrievedState == null) return;
        _stopwatch = Stopwatch();
        bool isRepeat = true;
        await androidForegroundService.updateStopwatchBackgroundState(
          retrievedState,
        );

        final actionName = androidForegroundService.stopwatchButtonAction();
        final buttonAction = StopwatchButtonAction.byname(actionName ?? '');

        if (buttonAction == StopwatchButtonAction.pause) {
          _stopwatch?.reset();
          _stopwatch?.stop();

          final buttons = androidForegroundService.createNotificationButton(
            firstButtonText: StopwatchButtonAction.reset.label,
            firstButtonId: StopwatchButtonAction.reset.name,
            secondButtonText: StopwatchButtonAction.start.label,
            secondButtonId: StopwatchButtonAction.start.name,
          );
          isRepeat = false;

          await androidForegroundService.updateForgroundService(
            isRepeat: isRepeat,
            notificationTitle: formatBackgroundDuration(
              retrievedState.currentDuration,
            ),
            buttons: buttons,
            notificationText: 'Paused',

            serviceType: service,
          );
        }
        ///
        else {
          _stopwatch?.reset();
          _stopwatch?.start();

          final buttons = androidForegroundService.createNotificationButton(
            firstButtonText: StopwatchButtonAction.lap.label,
            firstButtonId: StopwatchButtonAction.lap.name,
            secondButtonText: StopwatchButtonAction.pause.label,
            secondButtonId: StopwatchButtonAction.pause.name,
          );
          final lapCount = retrievedState.laps.isNotEmpty
              ? 'Lap ${retrievedState.laps.length - 1}'
              : 'Stopwatch';

          await androidForegroundService.updateForgroundService(
            isRepeat: isRepeat,
            notificationTitle: formatBackgroundDuration(
              retrievedState.currentDuration,
            ),
            buttons: buttons,
            notificationText: lapCount,

            serviceType: service,
          );
        }
      } else {
        if (_activeService == ActiveService.both) {
          final retrievedState = androidForegroundService
              .retrieveStopwatchSate();

          if (retrievedState == null) return;

          await androidForegroundService.updateStopwatchBackgroundState(
            retrievedState,
          );

          _stopwatch = Stopwatch();
          final actionName = androidForegroundService.stopwatchButtonAction();
          final buttonAction = StopwatchButtonAction.byname(actionName ?? '');
          if (buttonAction == StopwatchButtonAction.pause) {
            _stopwatch?.reset();
            _stopwatch?.stop();
          } else {
            _stopwatch?.reset();
            _stopwatch?.start();
          }
        }

        await audioSource.initAudioSource();

        final actionName = androidForegroundService.timerButtonAction();
        final buttonAction = TimerButtonAction.byname(actionName ?? '');
        var buttons = <NotificationButton>[];

        bool isRepeat = true;
        if (buttonAction == TimerButtonAction.pause) {
          buttons = androidForegroundService.createNotificationButton(
            firstButtonText: TimerButtonAction.reset.label,
            firstButtonId: TimerButtonAction.reset.name,
            secondButtonText: TimerButtonAction.resume.label,
            secondButtonId: TimerButtonAction.resume.name,
          );
          isRepeat = _activeService != ActiveService.timer; //Active service is  Stopwatch or Both The isRepeat = true

          text = 'Timer Paused';
        }
        ///
        else {
          buttons = androidForegroundService.createNotificationButton(
            firstButtonText: TimerButtonAction.addOneMinute.label,
            firstButtonId: TimerButtonAction.addOneMinute.name,
            secondButtonText: TimerButtonAction.pause.label,
            secondButtonId: TimerButtonAction.pause.name,
          );
        }
        final duration =
            androidForegroundService.retrieveLastTimerDuration() ?? 0;

        await androidForegroundService.updateForgroundService(
          isRepeat: isRepeat,
          notificationTitle: formatTimerDuration(Duration(seconds: duration)),
          buttons: buttons,
          notificationText: text,
          serviceType: service,
        );
      }
    } catch (e, stackTrace) {
      log(
        'Failed to Start Forground Service $e and Statc $stackTrace',
        // error: e,
        // stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    try {
      //Case 1:Maybe Both services are Runinng or Just Timer.
      if (_activeService == ActiveService.timer ||
          _activeService == ActiveService.both) {
        int? duration = androidForegroundService.retrieveLastTimerDuration();
        if (duration != null) {
          await _updateRepeatingTimer(duration);
        } else {
          _activeService = ActiveService.stopwatch;
        }
      }

      final stopwatchState = androidForegroundService.retrieveStopwatchSate();

      //Case 2:Both Timer and Stopwatch are Running.
      _stopwatch ??= Stopwatch();
      if (_activeService == ActiveService.both) {
        if (stopwatchState != null) {
          final action = androidForegroundService.stopwatchButtonAction();
          final name = StopwatchButtonAction.byname(action ?? '');

          switch (name) {
            case StopwatchButtonAction.pause:
              if ((_stopwatch?.isRunning ?? false)) {
                _stopwatch?.stop();
              }
              await _updateStopwatchState(
                stopwatchState,
                buttonAction: StopwatchButtonAction.pause,
                areBothServicesActive: true,
              );

              break;
            case StopwatchButtonAction.lap:
              await _onAddLapStopwatch();

              await androidForegroundService.removeStopwatchButtonAction();

              break;
            case StopwatchButtonAction.start:
              await Future.wait([
                _onStartStopwatch(),
                androidForegroundService.removeStopwatchButtonAction(),
              ]);

              break;
            case StopwatchButtonAction.reset:
              await _onResetStopwatch();
              break;

            default:
              {
                await _updateStopwatchState(
                  stopwatchState,
                  areBothServicesActive: true,
                );
              }
          }
        } else {
          _activeService = ActiveService.timer;
        }
      }

      //Case 3:Just Sopwatch is Running.
      if (_activeService == ActiveService.stopwatch) {
        if (stopwatchState == null) return;
        await _updateStopwatchState(
          stopwatchState,
          areBothServicesActive: false,
        );
      }
    } catch (e, stackTrace) {
      log('Failed to   Repeat Event error: $e, $stackTrace: ');
    }
  }

  Future<void> _updateStopwatchState(
    //In This State we will work with   Notifications Plugin  not with  Forground Task Plugin
    StopwatchState stopwatchState, {
    StopwatchButtonAction? buttonAction,
    required bool areBothServicesActive,
  }) async {
    final laps = androidForegroundService.retrieveLaps();
    _stopwatch ??= Stopwatch()..start();

    final newState = stopwatchState.copyWith(
      laps: laps,
      currentDuration: Duration(
        milliseconds:
            stopwatchState.currentDuration.inMilliseconds +
            (_stopwatch!.elapsedMilliseconds),
      ),
    );
    await androidForegroundService.updateStopwatchBackgroundState(newState); //Save  Stopwatch New State That updated By Stopwatch()  for use it later in UI

    if (!areBothServicesActive) {
      //Only stopwatch Running , no need to Local notification just use Foreground notification
      final title = formatBackgroundDuration(newState.currentDuration);

      await FlutterForegroundTask.updateService(notificationTitle: title);

      return;
    }

    await notifications.createNotification(
      countLap: laps.length,
      buttonAction: buttonAction,

      title: formatBackgroundDuration(newState.currentDuration),
      body: 'Stopwatch',
    );
  }

  Future<void> _updateRepeatingTimer(int duration) async {
    final actionName = androidForegroundService.timerButtonAction();
    final buttonAction = TimerButtonAction.byname(actionName ?? '');

    if (buttonAction == TimerButtonAction.pause) {
      return;
    }

    final tDuration = Duration(seconds: duration) - Duration(seconds: 1);
    await androidForegroundService.saveLastTmerDuration(tDuration);

    final isLessThanZero = tDuration < Duration.zero;

    if (isLessThanZero && !audioSource.isPlaying) {
      final buttons = androidForegroundService.createNotificationButton(
        firstButtonText: TimerButtonAction.stop.label,
        firstButtonId: TimerButtonAction.stop.name,
        secondButtonText: TimerButtonAction.addOneMinute.label,
        secondButtonId: TimerButtonAction.addOneMinute.name,
      );

      await androidForegroundService.updateForgroundService(
        isRepeat: true,
        notificationTitle: formatTimerDuration(tDuration),
        buttons: buttons,
        serviceType: _activeService,
        notificationText: 'Time\'s up',
      );
      await audioSource.startPlayer();

      return;
    }

    final formatTime = formatTimerDuration(tDuration);

    await FlutterForegroundTask.updateService(notificationTitle: formatTime);
  }

  @override
  Future<void> onNotificationButtonPressed(String id) async {
    try {
      if (_activeService != ActiveService.stopwatch) {
        // Timer or Both are Running. Here  only handle  Timer while Local notification is Triggered the Stopwatch if it is running.
        await _onTimerButtonPressed(id);
      } else {
        //Stopwatch Section

        await _onStopwatchButtonPressed(id);
      }
    } catch (e, stackTrace) {
      log(
        ' [Notification Action] Failed to handle notification button press',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _onStopwatchButtonPressed(String id) async {
    final state = StopwatchButtonAction.byname(id);
    await androidForegroundService.saveStopwatchButtonAction(
      id,
    ); //Save it  for Check When notification Repeat.
    switch (state) {
      case StopwatchButtonAction.reset:
        await _onResetStopwatch();

        break;

      case StopwatchButtonAction.pause:
        _stopwatch?.stop();

        final retrievedState = androidForegroundService
            .retrieveBackgroundStopwatchState();
        if (retrievedState == null) return;
        final buttons = androidForegroundService.createNotificationButton(
          firstButtonText: StopwatchButtonAction.reset.label,
          firstButtonId: StopwatchButtonAction.reset.name,
          secondButtonText: StopwatchButtonAction.start.label,
          secondButtonId: StopwatchButtonAction.start.name,
        );

        await androidForegroundService.updateForgroundService(
          isRepeat: false,
          notificationTitle: formatBackgroundDuration(
            retrievedState.currentDuration,
          ),
          buttons: buttons,
          serviceType: _activeService,
          notificationText: 'Paused',
        );

        break;

      case StopwatchButtonAction.start:
        await _onStartStopwatch();

        break;

      case StopwatchButtonAction.lap:
        await _onAddLapStopwatch();

        break;
      default:
    }
  }

  Future<void> _onTimerButtonPressed(String id) async {
    int durationInsecond =
        androidForegroundService.retrieveLastTimerDuration() as int;
    Duration timerDuration = Duration(seconds: durationInsecond);

    final buttonAction = TimerButtonAction.byname(id);

    switch (buttonAction) {
      case TimerButtonAction.pause:
        final buttons = androidForegroundService.createNotificationButton(
          firstButtonText: TimerButtonAction.reset.label,
          firstButtonId: TimerButtonAction.reset.name,
          secondButtonText: TimerButtonAction.resume.label,
          secondButtonId: TimerButtonAction.resume.name,
        );

        await androidForegroundService.updateForgroundService(
          isRepeat: _activeService != ActiveService.timer,
          notificationTitle: formatTimerDuration(timerDuration),
          buttons: buttons,
          serviceType: _activeService,
          notificationText: 'Timer Paused',
        );

        break;
      case TimerButtonAction.addOneMinute:
        final isLessThanZero = timerDuration.inSeconds < 0;
        final newTimerDuration = timerDuration.inSeconds > 0
            ? timerDuration.inSeconds + 60
            : 60;
        final newDuration = Duration(seconds: newTimerDuration);

        await androidForegroundService.saveLastTmerDuration(newDuration);

        if (isLessThanZero) {
          //
          if (audioSource.isPlaying) {
            await audioSource.stopPlayer();
          }
          final buttons = androidForegroundService.createNotificationButton(
            firstButtonText: TimerButtonAction.addOneMinute.label,
            firstButtonId: TimerButtonAction.addOneMinute.name,
            secondButtonText: TimerButtonAction.pause.label,
            secondButtonId: TimerButtonAction.pause.name,
          );
          await androidForegroundService.updateForgroundService(
            isRepeat: true,
            notificationTitle: formatTimerDuration(newDuration),
            buttons: buttons,
            serviceType: _activeService,
            notificationText: 'Timer',
          );
        }
        break;
      case TimerButtonAction.reset:
      case TimerButtonAction.stop:
        await _onResetTimer();

        break;
      case TimerButtonAction.resume:
        final buttons = androidForegroundService.createNotificationButton(
          firstButtonText: TimerButtonAction.addOneMinute.label,
          firstButtonId: TimerButtonAction.addOneMinute.name,
          secondButtonText: TimerButtonAction.pause.label,
          secondButtonId: TimerButtonAction.pause.name,
        );

        await androidForegroundService.updateForgroundService(
          isRepeat: true,
          notificationTitle: formatTimerDuration(timerDuration),
          buttons: buttons,
          serviceType: _activeService,
          notificationText: 'Timer',
        );

        break;
      default:
    }
    await androidForegroundService.saveTimerButtonAction(
      id,
    ); //Save it to Reuse for Check When notification Repeat.
  }

  Future<void> _onStartStopwatch() async {
    final stopwatchState = androidForegroundService.retrieveStopwatchSate();
    if (stopwatchState == null) return;
    _stopwatch ??= Stopwatch();
    _stopwatch!.start();
    final laps = androidForegroundService.retrieveLaps();
    final newduration = Duration(
      milliseconds:
          stopwatchState.currentDuration.inMilliseconds +
          _stopwatch!.elapsedMilliseconds,
    );
    final data = stopwatchState.copyWith(
      laps: laps,
      currentDuration: newduration,
    );

    await androidForegroundService.updateStopwatchBackgroundState(data);

    if (_activeService == ActiveService.stopwatch) {
      //Just stopwatch  is Running,use forground notification
      final buttons = androidForegroundService.createNotificationButton(
        firstButtonText: StopwatchButtonAction.lap.label,
        firstButtonId: StopwatchButtonAction.lap.name,
        secondButtonText: StopwatchButtonAction.pause.label,
        secondButtonId: StopwatchButtonAction.pause.name,
      );

      await androidForegroundService.updateForgroundService(
        isRepeat: true,
        notificationTitle: formatBackgroundDuration(data.currentDuration),
        buttons: buttons,
        serviceType: _activeService,
        notificationText: laps.isNotEmpty ? 'Lap ${data.laps.length - 1}' : '',
      );

      return;
    }

    //Both Stoptwatch and Timer are Running, assign Data to Local Notification

    await notifications.createNotification(
      countLap: laps.length,
      title: formatBackgroundDuration(data.currentDuration),
      body: 'Stopwatch',
    );
  }

  Future<void> _onAddLapStopwatch() async {
    await androidForegroundService.addLap();

    final data = androidForegroundService.retrieveBackgroundStopwatchState();

    if (data == null) return;

    if (_activeService == ActiveService.stopwatch) {
      //Just stopwatch  is Running,use forground notification
      final buttons = androidForegroundService.createNotificationButton(
        firstButtonText: StopwatchButtonAction.lap.label,
        firstButtonId: StopwatchButtonAction.lap.name,
        secondButtonText: StopwatchButtonAction.pause.label,
        secondButtonId: StopwatchButtonAction.pause.name,
      );
      final title = formatBackgroundDuration(data.currentDuration);

      await androidForegroundService.updateForgroundService(
        isRepeat: true,
        notificationTitle: title,
        buttons: buttons,
        notificationText:
            '${StopwatchButtonAction.lap.label}  ${data.laps.isNotEmpty ? data.laps.length - 1 : ''}',
        serviceType: _activeService,
      );

      return;
    }
    // Stopwatch and Timer   both are running,assign Data To Local Notification .

    await notifications.createNotification(
      countLap: data.laps.length,

      title: formatBackgroundDuration(data.currentDuration),
      body: 'Stopwatch',
    );
  }

  Future<void> _onResetTimer() async {
    if (_activeService == ActiveService.both) {
      _activeService = ActiveService.stopwatch;
      Future.wait([
        AndroidNotifications.cancelAll(),
        androidForegroundService.removeTimerDuration(),
        androidForegroundService.removeTimerButtonAction(),
      ]);

      //Start Switch Showing Notifiction to ForgroundService instead NotificationsService
      final action = androidForegroundService.stopwatchButtonAction();
      final state = StopwatchButtonAction.byname(action ?? '');
      if (state == StopwatchButtonAction.pause) {
        final retrievedState = androidForegroundService
            .retrieveBackgroundStopwatchState();
        if (retrievedState == null) return;

        final buttons = androidForegroundService.createNotificationButton(
          firstButtonText: StopwatchButtonAction.reset.label,
          firstButtonId: StopwatchButtonAction.reset.name,
          secondButtonText: StopwatchButtonAction.start.label,
          secondButtonId: StopwatchButtonAction.start.name,
        );

        await androidForegroundService.updateForgroundService(
          isRepeat: false,
          notificationTitle: formatBackgroundDuration(
            retrievedState.currentDuration,
          ),
          buttons: buttons,
          serviceType: _activeService,
          notificationText: 'Paused',
        );

        return;
      }
      //Stopwatch is Running
      else {
        // _stopwatch = Stopwatch()..start();
        Future.wait([
          AndroidNotifications.cancelAll(),
          androidForegroundService.removeTimerDuration(),
          androidForegroundService.removeTimerButtonAction(),
        ]);
        final stopwatchState = androidForegroundService.retrieveStopwatchSate();

        final laps = androidForegroundService.retrieveLaps();
        var text = laps.isNotEmpty ? "Lap ${laps.length - 1}" : "Stopwatch";
        if (stopwatchState == null) return;
        final newState = stopwatchState.copyWith(
          laps: laps,
          currentDuration: Duration(
            milliseconds:
                stopwatchState.currentDuration.inMilliseconds +
                _stopwatch!.elapsedMilliseconds,
          ),
        );

        final buttons = androidForegroundService.createNotificationButton(
          firstButtonText: StopwatchButtonAction.lap.label,
          firstButtonId: StopwatchButtonAction.lap.name,
          secondButtonText: StopwatchButtonAction.pause.label,
          secondButtonId: StopwatchButtonAction.pause.name,
        );

        await androidForegroundService.updateForgroundService(
          isRepeat: true,
          notificationTitle: formatBackgroundDuration(newState.currentDuration),
          buttons: buttons,
          notificationText: text,
          serviceType: _activeService,
        );
      }
      //Only Timer Running.
    } else {
      await androidForegroundService.removeFullBackgroundService();
    }
  }

  Future<void> _onResetStopwatch() async {
    if (_activeService == ActiveService.both) {
      await Future.wait([
        AndroidNotifications.cancelAll(),
        androidForegroundService.removeStopwatchData(),
        androidForegroundService.removeStopwatchBackgroundState(),
        androidForegroundService.removeStopwatchButtonAction(),
      ]);
      _stopwatch?.stop();
      _stopwatch?.reset();
      await audioSource.dispose();
      _activeService = ActiveService.timer;
    } else {
      await androidForegroundService.removeFullBackgroundService();
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    try {
      _stopwatch?.stop();
      _stopwatch?.reset();
      _stopwatch = null;
      _activeService = ActiveService.none;

      await audioSource.dispose();

      await androidForegroundService.cancellAllNotifications();
    } catch (e, stackTrace) {
      log('Failed to Destroy Task Handler', error: e, stackTrace: stackTrace);
    }
  }
}
