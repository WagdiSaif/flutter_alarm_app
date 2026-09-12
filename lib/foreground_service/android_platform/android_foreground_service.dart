import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:alarmapp/core/enums/applifecycle_enum.dart';

import 'package:alarmapp/data/models/laps.dart';
import 'package:alarmapp/data/models/stopwatch_state.dart';
import 'package:alarmapp/foreground_service/android_platform/android_notifications.dart';
import 'package:alarmapp/foreground_service/android_platform/foreground_service_handler.dart';
import 'package:alarmapp/foreground_service/audio_source.dart';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> startForgroundService() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final notificationsService = AndroidNotifications();
  await notificationsService.initialize();
  await AndroidForegroundService.initSharedPrefers();
  FlutterForegroundTask.setTaskHandler(
    ForegroundServiceHandler(
      notifications: notificationsService,
      audioSource: AudioHandler(audioPlayer: AudioPlayer()),
      androidForegroundService: AndroidForegroundService(),
    ),
  );
}

@pragma('vm:entry-point') //Android Localnotifcation entry point
Future<void> onNotificationButtonPressed(
  NotificationResponse notificationResponse,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await AndroidForegroundService.initSharedPrefers();

  final forgroundService = AndroidForegroundService();

  try {
    await forgroundService.saveStopwatchButtonAction(
      notificationResponse.actionId ?? '',
    );
  } catch (e) {
    log('Failed  to Handle Notification $e');
  }
}

const timerDataKey = 'timer_data';
const timerButtonActionKey = 'timer_button_action';
const stopwatchButtonActionKey = 'stopwatch_button_action';
const stopwatchDataKey = 'stopwatch_data';
const stopwatchUpdatedDataKey = 'stopwatch_background_data';

class AndroidForegroundService {
  static late SharedPreferences sharedPreferences;

  static final _androidNotificationOptions = AndroidNotificationOptions(
    channelImportance: NotificationChannelImportance.MIN,
    priority: NotificationPriority.MIN,
    channelId: 'forground_channel_new',
    channelName: 'forground_channel_name_new',
    playSound: false,
    showWhen: true,

    enableVibration: true,
    channelDescription:
        'This notification appears when the foreground service is running.',
    onlyAlertOnce: true,
  );

  static ForegroundTaskOptions _foregroundTaskOptions([bool isRepeat = true]) =>
      ForegroundTaskOptions(
        
        eventAction: isRepeat
            ? ForegroundTaskEventAction.repeat(1000) //repeat per second
            : ForegroundTaskEventAction.nothing(),
autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
        allowAutoRestart: true,
      );

  static Future<void> initializationService() async {
    await FlutterForegroundTask.stopService();
    FlutterForegroundTask.initCommunicationPort();

    FlutterForegroundTask.init(
      
      androidNotificationOptions: _androidNotificationOptions,
      iosNotificationOptions: IOSNotificationOptions(
        playSound: false,
        showNotification: false,
        
      ),
      foregroundTaskOptions: _foregroundTaskOptions(),
    );

    await initSharedPrefers();
  }

  static Future<void> initSharedPrefers() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> reloadPreferences() => sharedPreferences.reload();

  Future<void> startBackgroundService({
    required ActiveService service,
    Map<String, dynamic>? data,
  }) async {
    await FlutterForegroundTask.stopService();
    if (service == ActiveService.none) return;
    final text = notificationText(service);

    await FlutterForegroundTask.startService(
      serviceId: 90,
      notificationTitle: '',
serviceTypes: [ForegroundServiceTypes.dataSync,ForegroundServiceTypes.mediaPlayback],
      notificationText: text,
      callback: startForgroundService,
    );
  }

  Future<void> updateForgroundService({
    required bool isRepeat,
    required String notificationTitle,
    required List<NotificationButton> buttons,
    required String notificationText,
    required ActiveService serviceType,
  }) async {
    await FlutterForegroundTask.updateService(
      foregroundTaskOptions: _foregroundTaskOptions(isRepeat),
      notificationTitle: notificationTitle,
      notificationText: notificationText,

      notificationButtons: buttons,
    );
  }

  List<NotificationButton> createNotificationButton({
    required String firstButtonText,
    required String firstButtonId,
    required String secondButtonText,
    required String secondButtonId,
  }) {
    return [
      NotificationButton(
        id: firstButtonId,
        text: firstButtonText,
        textColor: Colors.black,
      ),

      NotificationButton(
        id: secondButtonId,
        text: secondButtonText,
        textColor: Colors.black,
      ),
    ];
  }

  int? retrieveLastTimerDuration() {
    int? durationInsecond = sharedPreferences.getInt(timerDataKey);

    if (durationInsecond != null) {
      return durationInsecond;
    }
    return null;
  }

  Future<void> removeTimerDuration() => sharedPreferences.remove(timerDataKey);

  Future<void> removeStopwatchData() =>
      sharedPreferences.remove(stopwatchDataKey);
  //  FlutterForegroundTask.removeData(key: stopwatchDataKey);

  StopwatchState? retrieveStopwatchSate() {
    final data = sharedPreferences.getString(stopwatchDataKey);
    if (data != null) {
      final decodedState = (jsonDecode(data) as Map).cast<String, dynamic>();

      final state = StopwatchState.fromJson(decodedState);
      return state;
    }

    return null;
  }

  Future<void> saveStopwatchButtonAction(String actionName) async {
    await sharedPreferences.setString(stopwatchButtonActionKey, actionName);
   
  }

  String? stopwatchButtonAction() =>
      sharedPreferences.getString(stopwatchButtonActionKey);

  Future<void> removeStopwatchButtonAction() =>
      sharedPreferences.remove(stopwatchButtonActionKey);

  //timer button Action

  Future<void> saveTimerButtonAction(String actionName) async {
    await sharedPreferences.setString(timerButtonActionKey, actionName);

  }

  Future<bool> get isRunning => FlutterForegroundTask.isRunningService;

  String? timerButtonAction() =>
      sharedPreferences.getString(timerButtonActionKey);
 

  Future<void> removeTimerButtonAction() =>
      sharedPreferences.remove(timerButtonActionKey);


  List<Laps> retrieveLaps() {
    final data = retrieveBackgroundStopwatchState();
    if (data == null) return [];
    return data.laps;
  }

  Future<void> addLap() async {


    final foregroundState = retrieveStopwatchSate();
    final backgroundState = retrieveBackgroundStopwatchState();
    if (backgroundState == null || foregroundState == null) return;

    var laps = backgroundState.laps;
    final realElapsedMilliseconds =
        backgroundState.currentDuration.inMilliseconds +
        foregroundState.currentDuration.inMilliseconds;

    if (laps.isEmpty) {
      final lapStartDuration = Duration(milliseconds: realElapsedMilliseconds);
      laps.add(
        Laps(
          currentLapElapsed: lapStartDuration,
          previousLapElapsed: lapStartDuration,
        ),
      );
    }

    final lastLap = laps.last;
    final newLap = Laps(
      previousLapElapsed: Duration(
        milliseconds:
            realElapsedMilliseconds - lastLap.currentLapElapsed.inMilliseconds,
      ),

      currentLapElapsed: Duration(milliseconds: realElapsedMilliseconds),
    );
    laps = [...laps, newLap];
    final newState = backgroundState.copyWith(
      laps: laps,
      currentDuration: Duration(milliseconds: realElapsedMilliseconds),
    );

    await updateStopwatchBackgroundState(newState);
  }

  Future<bool> saveStopwatchStateOnExit(Map<String, dynamic> data) async {
    try {
      final dataEncode = jsonEncode(data);
      return await sharedPreferences.setString(stopwatchDataKey, dataEncode);


    } catch (e) {
      log('Failed to Save Lap Data', error: e);
      return false;
    }
  }

  Future<void> updateStopwatchBackgroundState(StopwatchState state) async {
    try {
      var currentState = state;
      if (currentState.laps.isNotEmpty) {
        final laps = List<Laps>.from(currentState.laps);
        final lastRemovedLap = laps.removeLast();
        final now = currentState.currentDuration.inMilliseconds;

        final previousTotal = laps.last.currentLapElapsed;

        final updatedLap = lastRemovedLap.copyWith(
          previousLapElapsed: Duration(
            milliseconds: now - previousTotal.inMilliseconds,
          ),
          currentLapElapsed: Duration(milliseconds: now),
        );
        currentState = currentState.copyWith(laps: [...laps, updatedLap]);
      }

      final json = currentState.toJson();
      final dataEncode = jsonEncode(json);
      await sharedPreferences.setString(stopwatchUpdatedDataKey, dataEncode);

      
    } catch (e) {
      log('Failed to Save Background Data', error: e);
    }
  }

  StopwatchState? retrieveBackgroundStopwatchState() {
    final data = sharedPreferences.getString(stopwatchUpdatedDataKey);
  
    if (data != null) {
      final decodedState = (jsonDecode(data) as Map).cast<String, dynamic>();

      final result = StopwatchState.fromJson(decodedState);
      return result;
    }

    return null;
  }

  Future<bool> saveLastTmerDuration(Duration duration) =>
      sharedPreferences.setInt(timerDataKey, duration.inSeconds);

  Future<void> cancellAllNotifications() async {
    await FlutterForegroundTask.getAllData();
    FlutterForegroundTask.restartService();

    await FlutterForegroundTask.stopService();
    await AndroidNotifications.cancelAll();
  }

  Future<void> removeStopwatchBackgroundState() =>
      sharedPreferences.remove(stopwatchUpdatedDataKey);

  Future<void> removeFullBackgroundService() async {
    try {
      await Future.wait([
        FlutterForegroundTask.stopService(),
        AndroidNotifications.cancelAll(),

        removeStopwatchData(),
        removeStopwatchButtonAction(),
        removeStopwatchBackgroundState(),
        removeTimerButtonAction(),
        removeTimerDuration(),
      ]);
    } catch (e, stackTrace) {
      log(
        'Failed to Stop Forground Service ',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<ActiveService> determineActiveService() async {
    final stopwatchState = retrieveStopwatchSate();
    final timerDuration = retrieveLastTimerDuration();

    if (stopwatchState != null && timerDuration != null) {
      return ActiveService.both;
    }
    if (timerDuration != null) {
      return ActiveService.timer;
    }
    if (stopwatchState != null) {
      return ActiveService.stopwatch;
    }
    return ActiveService.none;
  }

  Future<void> clearAllData() async {
    try {
      await Future.wait([
        removeTimerDuration(),
        removeTimerButtonAction(),
        removeStopwatchData(),
        removeStopwatchButtonAction(),
        removeStopwatchBackgroundState(),
      ]);
    } catch (e) {
      log('Failed  to Clear ALL Data  $e');
    }
  }

  String notificationText(ActiveService service) {
    return switch (service) {
      ActiveService.stopwatch => 'Stopwatch',
      ActiveService.timer => 'Timer',
      _ => '',
    };
  }
}
