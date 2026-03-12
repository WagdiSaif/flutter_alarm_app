


import 'dart:convert';
import 'dart:ui';

import 'package:alarmapp/model/alarm_model.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart' show FlutterForegroundTask, TaskHandler, TaskStarter, NotificationButton, AndroidNotificationOptions, NotificationPriority, ForegroundTaskOptions, ForegroundTaskEventAction;
import 'package:flutter_foreground_task/models/notification_options.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';

import 'package:permission_handler/permission_handler.dart';


import 'package:alarmapp/helper/constants.dart';

import 'package:alarmapp/services/alarm_storage.dart';
@pragma('vm:entry-point')
void startAlarmService() {
  FlutterForegroundTask.setTaskHandler(AlarmTaskHandler());
}

@pragma('vm:entry-point')
Future<void> executeAlarmInBackground(
  int id,
  Map<String, dynamic> params,
) async {
  try {
    // Initialize Flutter bindings for background isolate
    WidgetsFlutterBinding.ensureInitialized();
     DartPluginRegistrant.ensureInitialized();
  await  AlarmStorage.init();
 
   FlutterForegroundTask.initCommunicationPort();
    
    final service = AlarmNotificationService();
    await service.initializeBackground();

    final title = params['title'] as String? ?? 'Alarm';
    final body = params['body'] as String? ?? 'Time to wake up!';
    final alarmTimeMs = params['alarmTime'] as int? ?? DateTime.now().millisecondsSinceEpoch;
    final soundPath = params['sound'] as String? ?? 'default';

    final firedAt = DateTime.fromMillisecondsSinceEpoch(alarmTimeMs);

    // Show notification
    // await service.showAlarmNotification(
    //   id,
    //   title,
    //   body,
    //   firedAt,
    //   soundPath,
    // );
    // // ⚠️ Check if service is already running and stop it
    // if (await FlutterForegroundTask.isRunningService) {
    //   await FlutterForegroundTask.stopService();
    //   await Future.delayed(const Duration(milliseconds: 500)); // Give it time to stop
    // }
  
    
await _initBackgroundTask(id,title,body,soundPath,alarmTimeMs);

  debugPrint('✅ AlarmManager callback completed for ID=$id');


    // Handle repeating alarms
    final alarm = await AlarmStorage.findAlarmById(id);
    if (alarm != null && alarm.repeatDays.isNotEmpty) {
      final nextTrigger = _calculateNextRepeat(firedAt, alarm.repeatDays, alarm.firedTime);

      final updatedAlarm = alarm.copyWith(
        firedAt: nextTrigger,
        lastTriggered: DateTime.now(),
      );

      // Update in storage
      await AlarmStorage.updateAlarm(updatedAlarm);

      // Schedule next occurrence
      await service.scheduleNotification(updatedAlarm);
    }
  } catch (e, stack) {
    // Log error but don't crash background isolate
    debugPrint('Background alarm error: $e\n$stack');
  }
}

@pragma('vm:entry-point')
Future<void> snoozeAlarmCallback(
  int id,  Map<String, dynamic> params
) async {
  WidgetsFlutterBinding.ensureInitialized();
     DartPluginRegistrant.ensureInitialized();
  await  AlarmStorage.init();
//alarmId
  final service = AlarmNotificationService();
  await service.initializeBackground();
  final orignalId=params['alarmId'] as int;
 final alarm = await AlarmStorage.findAlarmById(orignalId);
  final title = alarm?.title??'Time to wake up';
  final body =   alarm?.note??'';
  final sound =  alarm?.sound.fileName??'default';


await _initBackgroundTask(id,title,body,sound, DateTime.now().millisecondsSinceEpoch);;
}
// Top-level function outside of any class
@pragma('vm:entry-point')
Future<void> backgroundNotificationResponse(NotificationResponse response) async {
  try {
    final alarmId = int.parse(response.payload ?? '-1');

    if (response.actionId == 'stop_action') {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
      debugPrint('Background stop action for alarm $alarmId');
      await AlarmNotificationService._notifications.cancel(id: alarmId);
    } else if (response.actionId == 'snooze_action') {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
      debugPrint('Background snooze action for alarm $alarmId');
      await AlarmNotificationService._notifications.cancel(id: alarmId);
      AlarmNotificationService._handleSnooze(alarmId);
    }
  } catch (e, stack) {
    debugPrint('❌ Error in backgroundNotificationResponse: $e\n$stack');
  }
}
Future<void> _initBackgroundTask(int id,String title,String body,String soundPath,int alarmTimeMs)async{
    // final prefs =  AlarmStorage.sharedPreferences;
    // await prefs.setStringList(AppConstants.alarmsKey,[ jsonEncode({
    //   'alarmId': id,
    //   'soundPath': soundPath,
    //   'title': title,
    //   'body': body,
    //   'firedAt':alarmTimeMs,
    //   'isActive':true
    // })]);
     // 2️⃣ Save pending alarm for app launch when terminated

    // Verify data was saved
   //1773082686
   
   FlutterForegroundTask.init(
    iosNotificationOptions: IOSNotificationOptions(),
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'alarm_service',
      channelName: 'Alarm Service',
      channelDescription: 'Plays alarm sound continuously',
     
      priority: NotificationPriority.HIGH,
      onlyAlertOnce: true,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.nothing(), // No repeating events needed
      autoRunOnBoot: true,
      autoRunOnMyPackageReplaced: true,
      allowWakeLock: true, // Keep device awake for alarm
    ),
  );
  // FlutterForegroundTask.sendDataToMain('START_ALARM_SERVICE');
  if (await FlutterForegroundTask.isRunningService) {
  await FlutterForegroundTask.stopService();
}

await FlutterForegroundTask.startService(
  serviceId: id,
  notificationTitle: title,
  notificationText: body,
  callback: startAlarmService,
  notificationButtons: const [
    NotificationButton(id: 'stop', text: 'STOP'),
    NotificationButton(id: 'snooze', text: 'SNOOZE'),
  ],
);
  
}
/// Calculate next repeat date
DateTime _calculateNextRepeat(
  DateTime from,
  List<AlarmDays> repeatDays,
  TimeOfDay alarmTime,
) {
  // Check today first if time hasn't passed
  final today = DateTime(
    from.year,
    from.month,
    from.day,
    alarmTime.hour,
    alarmTime.minute,
  );

  if (repeatDays.contains(_getAlarmDay(from.weekday)) && today.isAfter(from)) {
    return today;
  }

  // Check next 7 days
  for (int i = 1; i <= 7; i++) {
    final candidate = from.add(Duration(days: i));
    final weekdayIndex = candidate.weekday - 1; // Mon = 0

    if (repeatDays.any((d) => d.index == weekdayIndex)) {
      return DateTime(
        candidate.year,
        candidate.month,
        candidate.day,
        alarmTime.hour,
        alarmTime.minute,
      );
    }
  }

  // Fallback: next day same time
  return DateTime(
    from.year,
    from.month,
    from.day + 1,
    alarmTime.hour,
    alarmTime.minute,
  );
}

/// Convert weekday to AlarmDays
AlarmDays _getAlarmDay(int weekday) {
  return AlarmDays.values[weekday - 1];
}





final class AlarmNotificationService {
  static  AlarmNotificationService? _instance;
  factory AlarmNotificationService() =>
      _instance ??= AlarmNotificationService._();

  AlarmNotificationService._();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static final AndroidNotificationChannel _alarmChannel = AndroidNotificationChannel(
    AppConstants.notificationChannelId,// 'alarm_channel';
    AppConstants.notificationChannelName,//'Alarm Notifications'
    description: 'Alarm notifications with controls',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    
  );

  /// ---------- INITIALIZATION ----------

  static Future<void> initializeForeground() async {
    await AndroidAlarmManager.initialize();
    
    await _initNotifications();
   
  }


  Future<void> initializeBackground() async {
    await _initNotifications();
  }
  //for Alarm survives phone reboot// some devices still require manual restore we Call this in main().
  Future<void> restoreAlarms() async {
  final alarms = await AlarmStorage.loadAllAlarms();

  for (final alarm in alarms) {
    if (alarm.isEnabled) {
      await scheduleNotification(alarm);
    }
  }
}

  static Future<void> _initNotifications() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: backgroundNotificationResponse,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_alarmChannel);
  }

  /// ---------- PERMISSIONS ----------
  Future<bool> requestNotificationPermission() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return result ?? false;
  }

  // Call this method ONLY when scheduling an alarm
  Future<bool> ensureExactAlarmPermission() async {
    if (await Permission.scheduleExactAlarm.isGranted) return true;

    // Only show dialog if we're actually scheduling
    final status = await Permission.scheduleExactAlarm.request();
    return status.isGranted;
  }

  // Optional: Check status without requesting
  Future<bool> hasExactAlarmPermission() async {
    return await Permission.scheduleExactAlarm.isGranted;
  }

  /// ---------- NOTIFICATION HANDLERS ----------

static Future<void> _onNotificationResponse(NotificationResponse response) async {
  final alarmId = int.parse(response.payload ?? '-1');
  
  if (response.actionId == 'stop_action') {
    // Send stop command to task
      debugPrint('sendDataToTask stop sound: ');
   
    await _notifications.cancel(id: alarmId);
     if (await FlutterForegroundTask.isRunningService) {
  await FlutterForegroundTask.stopService();
}
    
  } else if (response.actionId == 'snooze_action') {
    // Send stop command to task
    if (await FlutterForegroundTask.isRunningService) {
  await FlutterForegroundTask.stopService();
}
    await _notifications.cancel(id: alarmId);
    _handleSnooze(alarmId);
  }
}



  static Future<void> _handleSnooze(int alarmId) async {
   await _notifications.cancel(id: alarmId);
   final snoozeId = alarmId+10;
  // [alarmId];// w will need it for search alrams details in callback
AndroidAlarmManager.oneShot(Duration(minutes: 5), snoozeId, snoozeAlarmCallback, exact: true,
  wakeup: true,
  allowWhileIdle: true,
params: {'alarmId':alarmId});

  }

  /// ---------- SCHEDULING ----------

  Future<void> scheduleNotification(AlarmModel alarm) async {
    if (!alarm.isEnabled) return;

    // Request permission ONLY when scheduling
    if (!await ensureExactAlarmPermission()) {
      throw Exception('Exact alarm permission denied - cannot schedule alarm');
    }

    final triggerUtc = alarm.firedAt.toUtc();

    await AndroidAlarmManager.cancel(alarm.id);

    final success = await AndroidAlarmManager.oneShotAt(
      triggerUtc,
      alarm.id,
      executeAlarmInBackground,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
      allowWhileIdle: true,
      params: {
        'alarmTime': triggerUtc.millisecondsSinceEpoch,
        'title': alarm.title,
        'body': alarm.note ?? 'Time to wake up!',
        'sound': alarm.sound.fileName,
      },
    );

    if (!success) {
      debugPrint('Failed to schedule alarm ${alarm.id}');
    }
  }

  /// ---------- SHOW NOTIFICATION ----------

  Future<void> showAlarmNotification(
    int id,
    String title,
    String body,
    DateTime time,
    String soundPath,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      _alarmChannel.id,
      _alarmChannel.name,
      channelDescription: _alarmChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      ongoing: true,
      autoCancel: false,
      playSound: false,
  //       channelId,
  // channelName,


 

  // audioAttributesUsage: AudioAttributesUsage.alarm,
      // sound: RawResourceAndroidNotificationSound(soundPath),
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      actions: const [
        AndroidNotificationAction(
          'stop_action',
          'STOP',
          cancelNotification: true,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          'snooze_action',
          'SNOOZE 5min',
          cancelNotification: false,
          showsUserInterface: true,
        ),
      ],
    );

    await _notifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails),
      payload: id.toString(),
    );
  }
  Future<void> disableAlarm(int alarmId) async {
  await AndroidAlarmManager.cancel(alarmId);
  await _notifications.cancel(id: alarmId);

  final alarm = await AlarmStorage.findAlarmById(alarmId);

  if (alarm != null) {
    alarm.isEnabled=false;
    await AlarmStorage.updateAlarm(alarm);
  }
}
}
class AlarmTaskHandler extends TaskHandler {
  AudioPlayer? _player; // Nullable now
  int? _alarmId;


@override
Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
  debugPrint('🎵 AlarmTaskHandler onStart CALLED! Timestamp: $timestamp');

  try {
    await AlarmStorage.init();
    final prefs = AlarmStorage.sharedPreferences;
    final alarmDataString = prefs.getStringList(AppConstants.alarmsKey)?? [];


    if (alarmDataString.isEmpty) {
      debugPrint('❌ No alarm data found. Exiting onStart.');
      return;
    }
 

    final data = jsonDecode(alarmDataString.last) as Map<String, dynamic>;
    final isActive = data['isEnabled'] as bool? ?? true; // default true
    debugPrint('Retrieved alarm data final R string: $data');
    if (!isActive) {
      debugPrint('Alarm was previously stopped. Not playing again.');
      return; // STOP here, do not auto-play
    }
         final service = AlarmNotificationService();
    await service.initializeBackground();
   
  _alarmId = data['id'] is int
    ? data['id']
    : int.tryParse(data['id'].toString()) ?? 0;

final soundIndex = data['sound'] is int
    ? data['sound']
    : int.tryParse(data['sound'].toString()) ?? 0;
    final soundPath=AlarmSound.values[soundIndex].fileName;
    final title = data['title'] as String? ?? 'Alarm';
      final body = data['body'] as String? ?? 'body';
      final firedTime =DateTime.tryParse(data['firedAt'])?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;
    final firedAt = DateTime.fromMillisecondsSinceEpoch(firedTime);
    debugPrint('✅ Using alarm: ID=$_alarmId, sound=$soundPath, title=$title');

    // Stop any existing player
    await _stopAlarm(_alarmId);
  await service.showAlarmNotification(
      _alarmId!,
      title,
      body,
      firedAt,
      soundPath,
    );
    // Configure audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.sonification,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.alarm,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ));

    // Initialize player and play alarm
   
    _player = AudioPlayer();
    await _player!.setLoopMode(LoopMode.one);
    await _player!.setVolume(1.0);
    final assetPath = '${AppConstants.alarmAudioPath}/$soundPath.mp3';
    debugPrint('Loading sound: $assetPath');
    await _player!.setAsset(assetPath);
    await _player!.play();
   
    debugPrint('🔊 Continuous sound started for alarm $_alarmId');

  } catch (e, stack) {
    debugPrint('❌ Error in AlarmTaskHandler.onStart: $e\n$stack');
  }
}
  @override
  void onReceiveData(Object data) async {
    debugPrint('Received data: $data');
    if (data == "stop") {
      await _stopAlarm();
    }
  }

  @override
  Future<void> onNotificationButtonPressed(String id) async {
    debugPrint('Button pressed: $id');

    if (id == 'stop') {
      await _stopAlarm();
      await FlutterForegroundTask.stopService();

      // final prefs = AlarmStorage.sharedPreferences;
      // await prefs.remove(AppConstants.alarmsKey);

      if (_alarmId != null) {
        final service = AlarmNotificationService();
        await service.disableAlarm(_alarmId!);
      }
    } else if (id == 'snooze') {
      await _stopAlarm();
      await FlutterForegroundTask.stopService();

      // final prefs = AlarmStorage.sharedPreferences;
      // await prefs.remove(AppConstants.alarmsKey);

      if (_alarmId != null) {
        final snoozeId = _alarmId! + 10000;
        AndroidAlarmManager.oneShot(
          const Duration(minutes: 5),
          snoozeId,
          snoozeAlarmCallback,
          exact: true,
          wakeup: true,
          allowWhileIdle: true,
          params: {'alarmId': _alarmId},
        );
      }
    }
  }

Future<void> _stopAlarm([int? id]) async {
  try {
    if (_player != null) {
      if (_player!.playing) {
        debugPrint('🛑 Stopping alarm...');
        await _player!.stop();
      }
      await _player!.dispose();
      _player = null;
  

      // Persist that alarm is no longer active
      //final prefs = AlarmStorage.sharedPreferences;
      if(id!=null){
     final lastAlram=await AlarmStorage.findAlarmById(id);
      // final alarmDataString = prefs.getStringList(AppConstants.alarmsKey)?? [];
      if (lastAlram!=null) {
        // final data = jsonDecode(alarmDataString.last) as Map<String, dynamic>;
       lastAlram.isEnabled = false;
     await  AlarmStorage.updateAlarm(lastAlram);}
        // await prefs.setStringList(AppConstants.alarmsKey,[ jsonEncode(data)]);
      }

      debugPrint('🛑 Alarm stopped successfully');
    } else {
      debugPrint('No player to stop');
    }
  } catch (e) {
    debugPrint('Error stopping alarm: $e');
  }
}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    debugPrint('AlarmTaskHandler destroyed');
    await _stopAlarm();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Not needed for alarm
  }
}