import 'package:alarmapp/services/counter_dowan_notification.dart';
import 'package:alarmapp/services/time_manager.dart';
import 'package:flutter/material.dart';

class ScreenNotifications  extends StatefulWidget{



  const ScreenNotifications({super.key});
  @override
  State<StatefulWidget> createState() =>_ScreenNotifications();



}

class _ScreenNotifications extends State<ScreenNotifications>{




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
return Scaffold(
appBar: AppBar(),
  body: Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center,
      children: [


        ElevatedButton(onPressed:() {
          CounterDowanNotification().createNotification(id: 22, scheduledDate: TimeManager.nowDateTime.add(Duration(minutes: 1)));
          
        }, child: Text('Create Notifiction'))
      ],
    ),
  ),
);
  }
}