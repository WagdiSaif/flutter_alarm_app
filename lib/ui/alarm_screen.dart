import 'package:alarmapp/core/app_color.dart';
import 'package:alarmapp/model/alarm_model.dart';
import 'package:alarmapp/providers/notification_settings.dart';
import 'package:alarmapp/services/alarm_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

StateProvider<TimeOfDay?> initTimeOfDay = StateProvider<TimeOfDay?>(
  (ref) => TimeOfDay.now(),
);

class AlarmScreen extends ConsumerWidget {
   AlarmScreen({super.key});
double height=0.0;
double width=0.0;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAlarms = ref.watch(alarmControllerProvider);
    final timeOfDay = ref.watch(initTimeOfDay);
     height = MediaQuery.of(context).size.height;
     width = MediaQuery.of(context).size.width;
    return SafeArea(
      
      child: Column(
        children: [
          Container(padding: EdgeInsets.symmetric(horizontal: 10),
            height: height*0.07,
          width: double.infinity,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [//here is appbar
            Text('Alarm',style: Theme.of(context).textTheme.headlineLarge,),
      PopupMenuButton(
        //color: AppColors.error,
        itemBuilder: (context)=>[PopupMenuItem(child: Text('data'))]),
      
          ],),),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: listAlarms
                                .map(
                                  (alarm) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      
                                      height: 100,
                                      padding: EdgeInsets.all(7),
                              
                                      decoration: BoxDecoration(
                                        color: AppColors.containerBg,
                                        // color: AppColor.alarmContainerBgColor,
                              
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                              
                                      child: InkWell(
                                        onTap: () async {
                                          final prefs =
                                              AlarmStorage.sharedPreferences;
                                          //  await ref.read(alarmControllerProvider.notifier).deleteAllAlarm();
                                          //     final alrm =await AlarmStorage.loadAllAlarms();
                                          // if(alrm.isNotEmpty){
                                          //    debugPrint('currentDateTime.toString(): ${alrm.first.firedAt}');
                                          // }
                                          //      debugPrint('no alram.toString(): ${0}');
                              
                                          //                                  showDialog(context: context, builder: (context){
                                          // return _buildAlramDialogSettings(context);
                                          //                                  });
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) =>
                                                _buildAlramDialogSettings(
                                                  context,
                                                  alarm,ref
                                                ),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                alarm.repeatDays.isEmpty?Text(
                                                      'Not Scheduled',
                                                      style: Theme.of(context).textTheme.titleLarge
                                                    ):Row(
                                                      children: alarm.repeatDays.map((dayScheduled)=>Text(dayScheduled.shortName.toString())).toList(),
                                                    ),
                                                    //alarm.repeatDays
                                                Row(
                                                  textBaseline:
                                                      TextBaseline.alphabetic,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.baseline,
                                                  children: [
                                                    Text(
                                                      '${alarm.firedTime.hour}:${alarm.firedTime.minute}',
                                                      style: Theme.of(context).textTheme.titleLarge
                                                    ),
                                                    Text(
                                                      alarm.firedTime.period.name,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Switch(
                                              value: false,
                                              onChanged: (change) {},
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                              
                            // In your home screen or debug menu
                              
                            // [for(int i=0;i<8;i++)
                            // Text('${listAlarms.length}')
                            // ]
                          ),
                        ),
                              
                        Positioned(
                          bottom: 1,
                          left: 0,
                          // right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color:  AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            // alignment: Alignment.bottomCenter,
                            margin: const EdgeInsets.only(bottom: 3),
                            height: 70,
                            width: 70,
                            
                            child: Center(
                              child: IconButton(
                                onPressed: () async {
                                  await selectTimeOfAlarm(
                                    context,
                                    timeOfDay,
                                    ref,
                                  );
                                },
                                icon: const Icon(Icons.add, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> selectTimeOfAlarm(
    BuildContext context,
    TimeOfDay? timeOfDay,
    WidgetRef ref,
  ) async {
    final prefs = AlarmStorage.sharedPreferences;
    //     final alrm =await AlarmStorage.loadAllAlarms();
    // if(alrm.isNotEmpty){
    //    debugPrint('currentDateTime.toString(): ${alrm.first.firedAt}');
    // }
    //  await ref.read(alarmControllerProvider.notifier).deleteAllAlarm();
    if (!context.mounted) return;
    final selectedAlramTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    final nowDateTime = DateTime.now();
    DateTime? alramDateTime;
    if (selectedAlramTime != null) {
      alramDateTime = DateTime(
        nowDateTime.year,
        nowDateTime.month,
        nowDateTime.day,
        selectedAlramTime.hour,
        selectedAlramTime.minute,
      );
      final alarm = AlarmModel(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
        firedTime: selectedAlramTime,
        firedAt: alramDateTime, // If time passed, schedule tomorrow
        title: 'Morning Alarm',
        note: 'Time to wake up and exercise!',
        isEnabled: true,
        repeatDays: [], // No repeat = one-time
        sound: AlarmSound.birds,
        snoozeDuration: 5,
        createdDate: nowDateTime,
      );
      final isadd = await ref
          .read<AlarmController>(alarmControllerProvider.notifier)
          .addAlarm(alarm: alarm);

      debugPrint('current DateTime.NotificationService().addAlarm():${isadd}');
    }

    final realtime = DateTime.now().toUtc();

    //   debugPrint( 'current DateTime.now().toString():${alramDateTime!.toUtc().toString()}');
    debugPrint('currentDateTime.toString(): ${realtime}');

    //   ref.read(initTimeOfDay.notifier).state=selectedAlramTime;
  }

  Widget _buildAlramDialogSettings(
    BuildContext context,
    AlarmModel alarm,
    WidgetRef ref,
  ) {
    return BottomSheet(
      // backgroundColor: AppColor.scaffoldBgcolor,
      onClosing: () {},
      builder: (BuildContext context) {
        return Padding(
          padding:  EdgeInsets.symmetric(vertical: 10, horizontal: width*0.03),
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Row(
                        textBaseline: TextBaseline.alphabetic,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: [
                          Text(
                            '${alarm.firedTime.hour}:${alarm.firedTime.minute}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(alarm.firedTime.period.name),
                        ],
                      ),
                      IconButton(onPressed: () {}, icon: Text('Edit')),
                    ],
                  ),

                  //list days
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: AlarmDays.values.map((day)=>
                  Container(
                    width: (width*0.12),
                    padding: EdgeInsets.only(top: 10,bottom: 10),
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                     color:AppColors.primaryBlue
                  ),
                    child: Text(day.shortName,textAlign: TextAlign.center,),)).toList(),),
//Schedule alarm
SizedBox(height: 8,),
                    Container(
                     
                       decoration: BoxDecoration(
                                          color: AppColors.containerBg,
                                          // color: AppColor.alarmContainerBgColor,
                                
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        Column(
                          children: [
                            Text('Upcoming alarm'),
                            Text(alarm.isEnabled?alarm.repeatDays.isNotEmpty? alarm.repeatDays.first.shortName.toString():'Alarm is tomorrow':'Alarm is off')
                          ],
                        ),
                        Row(children: [
                          IconButton(onPressed: (){
                      
                          }, icon: Icon(Icons.date_range)),
                          Text('Schedule alarm')
                        ],)
                      ],),
                    )

                    //alarm name
,SizedBox(height: 8,),
                    Container(
                     
                       decoration: BoxDecoration(
                                          color: AppColors.containerBg,
                                          // color: AppColor.alarmContainerBgColor,
                                
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                                    Row(children: [
                          IconButton(onPressed: (){
                      
                          }, icon: Icon(Icons.edit_note)),
                          Text(' alarm name')
                        ],)
                      ,Expanded(child: TextField())  ],
                      ),
                    ),

                    //sound
                    SizedBox(height: 8,),
                    Container(
                     
                       decoration: BoxDecoration(
                                          color: AppColors.containerBg,
                                          // color: AppColor.alarmContainerBgColor,
                                
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                                    Row(children: [
                          IconButton(onPressed: (){
                      
                          }, icon: Icon(Icons.audiotrack)),
                          Text(' Sound')
                        ],)
                      ,TextButton(
                        child: Text('Default Sound'),
                        onPressed: () {
                        
                      },)  ],
                      ),
                    ),
                      //vibrate
                    SizedBox(height: 8,),
                    Container(
                     
                       decoration: BoxDecoration(
                                          color: AppColors.containerBg,
                                          // color: AppColor.alarmContainerBgColor,
                                
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                                    Row(children: [
                          IconButton(onPressed: (){
                      
                          }, icon: Icon(Icons.vibration)),
                          Text(' Vibrate')
                        ],)
                      ,Switch(
                        value: true,
                        onChanged: (vc) {
                        
                      },)  ],
                      ),
                    )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
