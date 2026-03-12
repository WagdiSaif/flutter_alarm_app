import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:alarmapp/core/app_color.dart';
import 'package:alarmapp/helper/sizer.dart';
import 'package:alarmapp/home.dart';
import 'package:alarmapp/services/alarm_service.dart';
import 'package:alarmapp/services/alarm_storage.dart';

import 'package:alarmapp/ui/homescreen.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();

    await AlarmStorage.init();
  // Initialize communication port (required)
  FlutterForegroundTask.initCommunicationPort();
  

  
  // Initialize foreground task
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


 await AlarmNotificationService.initializeForeground();
 // Restore alarms if app was closed
  final service = AlarmNotificationService();
  // await service.restoreAlarms();
  // final prefs = AlarmStorage.sharedPreferences;
  // final pendingAlarmString = prefs.getString('pending_alarm');

  runApp(ProviderScope(child:const MyApp()));
}

/// Called when background isolate sends data



class MyApp extends StatelessWidget {
  
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',


      theme: AppTheme.theme,
      home: SizerUitles(builder: (context) => Homescreen(),)
    );
  }
}


