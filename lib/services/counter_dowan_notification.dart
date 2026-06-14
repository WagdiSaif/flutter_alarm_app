import 'dart:async';

import 'package:alarmapp/services/time_manager.dart';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/timezone.dart' as tz;
@pragma('vm:entry-point')
void handleNotifictionAction( ){

FlutterForegroundTask.updateService();
}
class CounterDowanNotification {
  // static final _androidInitializationSettings = InitializationSettings(
  //   android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  // );

final _androidNotificationOptions=AndroidNotificationOptions(channelId: "channelId", channelName: "channelName");
final _iosNotificationOptions=IOSNotificationOptions();
  //AndroidNotificationChannel androidNotificationChannel=AndroidNotificationChannel(id, name)
final _foregroundTaskOptions=ForegroundTaskOptions(eventAction: ForegroundTaskEventAction.nothing());
   Future<void> initializLocalNotification() async {
FlutterForegroundTask.initCommunicationPort();
    FlutterForegroundTask.init(androidNotificationOptions: _androidNotificationOptions, iosNotificationOptions: _iosNotificationOptions, foregroundTaskOptions: _foregroundTaskOptions);


  }
  TZDateTime scheduledDateTimer=TZDateTime.now(tz.local);
   Future<void> createNotification({
    required int id,
    String? title,
    String? body,
    required TZDateTime scheduledDate,
  }) async {
FlutterForegroundTask.startService(notificationTitle: "notificationTitle", notificationText: "notificationText",callback:handleNotifictionAction );


    //   debugPrint("ok added");
    // });
    //_notifictionPlugin.(id: id, repeatInterval: repeatInterval, notificationDetails: notificationDetails, androidScheduleMode: androidScheduleMode)
    //await androidNotification.show(id: id,notificationDetails: androidNotificationDetails,);
  }
 Timer? _timer;
int showTimer({ required TZDateTime scheduledDate}){
  
scheduledDateTimer=scheduledDateTimer.subtract(Duration(seconds: 1));
int counter=scheduledDateTimer.second;
_timer?.cancel();
  _timer=Timer.periodic(Duration(seconds: 1), (c){


scheduledDateTimer=scheduledDateTimer.subtract(Duration(seconds: 1));
 counter=scheduledDateTimer.second;
 if(scheduledDateTimer==TimeManager.nowDateTime){
  c.cancel();
 }

  });

return counter;
}
  static Future<void> requestPermission() async {
    
  }
}
