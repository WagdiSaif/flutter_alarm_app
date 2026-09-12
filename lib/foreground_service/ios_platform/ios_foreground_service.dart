import 'dart:developer';

import 'package:alarmapp/core/enums/applifecycle_enum.dart';
import 'package:alarmapp/core/enums/stopwatch_enum.dart';
import 'package:alarmapp/core/enums/timer_enum.dart';
import 'package:alarmapp/data/models/laps.dart';
import 'package:alarmapp/data/models/stopwatch_state.dart';

import 'package:flutter/services.dart';
import 'package:live_activities/live_activities.dart';

class IosForegroundService {
  static final LiveActivities _liveActivitie = LiveActivities();
  static const appGroupID = 'group.com.wagdi.alarmapp';
  static const channelName = "com.wagdi.alarmapp/live_activity";
  static const methodChannel = MethodChannel(channelName);
  String? currentActivity;

  static Future<void> initializationService() async {
    try {
      await _liveActivitie.init(appGroupId: appGroupID);

      final isSupported = await _liveActivitie.areActivitiesSupported();
    } catch (e, stackTrace) {
      log('Failed to initialization ios ', error: e, stackTrace: stackTrace);
    }
  }
  //All Background service  starts  here.

  Future<void> startBackgroundService({
    required ActiveService service,
    required Map<String, dynamic> data,
  }) async {
    if (service == ActiveService.none) return;
    try {
      final result = await methodChannel.invokeMethod('createActivity', data);
      log('result1 channel is $result');
    } catch (e, stackTrace) {
      log(' Error: $e :StackTrace $stackTrace');
    }
  }

  Future<StopwatchState?> retrieveBackgroundStopwatchState() async {
    try {
      final retrievedData = await methodChannel.invokeMethod(
        "retrieveStopwatchData",
      );

      final data = (retrievedData as Map?)?.cast<String, dynamic>();

      if (data == null || data.isEmpty) {
        return null;
      }
      final actionName = data["buttonAction"] as String? ?? '';
      final action = StopwatchButtonAction.byname(actionName);

      final elapsedDuration = data["elapsedDuration"] as int? ?? 0;

      var stopwatchState = StopwatchState(
        stopwatchButtonAction: action,
        laps: [],
        currentDuration: Duration(milliseconds: elapsedDuration),
      );
      final laps = data["laps"] as List?;

      if (laps != null && laps.isNotEmpty) {
        final allLaps = laps.map((lap) {
          final map = (lap as Map).cast<String, dynamic>();
          return Laps.fromJson(map);
        }).toList();
        stopwatchState = stopwatchState.copyWith(laps: allLaps);
      }

      return stopwatchState;
    } catch (e) {
      log("Fialed to Retriev Stopwatch Data$e");
      return null;
    }
  }

  Future<({int currentDuration, TimerButtonAction buttonAction})?>
  retrieveTimerBackgroundData() async {
    try {
      final retrievedData = await methodChannel.invokeMethod(
        "retrieveTimerData",
      );

      final data = (retrievedData as Map?)?.cast<String, dynamic>();

      if (data == null || data.isEmpty) {
        return null;
      }

      final currentDuration = data["currentDuration"] as int? ?? 0;

      final buttonAction = TimerButtonAction.byname(
        data["buttonAction"] as String? ?? '',
      );
      return (buttonAction: buttonAction, currentDuration: currentDuration);
    } catch (e) {
      log("Fialed to Retriev Timer Remianing second$e");
      return null;
    }
  }

  Future<void> removeFullBackgroundService() async {
    try {
      await methodChannel.invokeMethod("cleanUpServicesSData");
    } catch (e) {
      log("Failed to cleanUp Timer Storage");
    }
  }

  Future<void> cancellAllNotifications() async {
    try {
      await methodChannel.invokeMethod("cancellAllNotifications");
    } catch (e) {
      log("Failed to Cancel All Notification :$e");
    }
  }
}
