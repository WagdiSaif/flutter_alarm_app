import 'package:alarmapp/core/app_theme/app_colors.dart';
import 'package:alarmapp/core/app_theme/app_theme.dart';
import 'package:alarmapp/core/extensions.dart';

import 'package:alarmapp/core/utils/functions.dart';
import 'package:alarmapp/core/enum/enums.dart';
import 'package:alarmapp/core/constant/constant.dart';
import 'package:alarmapp/sizer.dart';
import 'package:alarmapp/ui/widgets/helper_message.dart';
import 'package:flutter/gestures.dart';
import 'package:path/path.dart' as path;
import 'package:alarmapp/core/data/models/alarm_model.dart';
import 'package:alarmapp/providers/alarm_controller.dart';
import 'package:alarmapp/services/time_manager.dart';
import 'package:alarmapp/ui/add_alarm_screen.dart';
import 'package:alarmapp/ui/alarm_sound_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

StateProvider<List<AlarmDays>> repeatDayMark = StateProvider<List<AlarmDays>>(
  (ref) => <AlarmDays>[],
);
StateProvider<String> selectedSoundPathProvider = StateProvider<String>(
  (ref) => AppConstants.defaultSound,
);
//vibrate

StateProvider<TimeOfDay> _timeAlarmUpdate = StateProvider<TimeOfDay>(
  (ref) => TimeOfDay.now(),
);

StateProvider<bool> vibrateUpdate = StateProvider<bool>((ref) => false);
StateProvider<bool> expandProvider = StateProvider<bool>((ref) => false);

class AlarmBottomSheet extends ConsumerStatefulWidget with RouteAware {
  //State Widget<=======================>>
  const AlarmBottomSheet({super.key, required this.alarm});
  final AlarmModel alarm;

  @override
  ConsumerState<AlarmBottomSheet> createState() => _AlarmBottomSheet();
}

class _AlarmBottomSheet extends ConsumerState<AlarmBottomSheet>
    with TickerProviderStateMixin {
   late RenderBox renderObject;
   
  AnimationController? _animationController;
  late TextEditingController _nameAlarmController;
GlobalKey globalKey=GlobalKey();
 //final   _scrollController=DraggableScrollableController();


 
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(repeatDayMark.notifier).state = [...widget.alarm.repeatDays];
      ref.read(selectedSoundPathProvider.notifier).state =
          widget.alarm.soundPath;
      //vibrateUpdate
      ref.read(_timeAlarmUpdate.notifier).state = widget.alarm.firedTime;
      ref.read(vibrateUpdate.notifier).state = widget.alarm.vibrate;
    });
    _nameAlarmController = TextEditingController(text: widget.alarm.name);
    _animationController = AnimationController(vsync: this);
  
  }
  

  late FocusNode _focusNode;
  @override
  void dispose() {
    _animationController?.dispose();
    _nameAlarmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repeatDays = ref.watch(repeatDayMark);

    final selectSound = ref.watch(selectedSoundPathProvider);
  
    final timeAlarmUpdate = ref.watch(_timeAlarmUpdate);
    final vibrate = ref.watch(vibrateUpdate);

    //vibrateUpdate
    double viewInsetsHeight=MediaQuery.of(context).viewInsets.bottom;


    final alarm = widget.alarm;
   
        return DraggableScrollableSheet(
     
          initialChildSize: viewInsetsHeight==0?0.70:1.0,
          minChildSize: 0.65,
          maxChildSize: 1.0,
         // expand: expand,
        expand: false,
        
          builder: (context, scrollController) {
            
           // scrollController.position;
            return NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                
                return false;
              },
              
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      reverse: false,
                     // padding: EdgeInsets.only(bottom: 300),
                     physics:    viewInsetsHeight==0?NeverScrollableScrollPhysics(): AlwaysScrollableScrollPhysics() ,
                    //physics: RangeMaintainingScrollPhysics(),
                      controller: scrollController,
                      child: Container(key: globalKey,
                      
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(    mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    // Add padding for keyboard
                                    left: 4.sw,
                                    right: 4.sw,
                                    // bottom: keyboardHeight
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                
                                        children: [
                                          Row(
                                            textBaseline: TextBaseline.alphabetic,
                                            crossAxisAlignment: CrossAxisAlignment.baseline,
                                            children: [
                                              Text(
                                                TimeManager.formatTimeShow(
                                                  timeAlarmUpdate,
                                                  context,
                                                ),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              Text(alarm.firedTime.period.name.toUpperCase()),
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              await _updateTimeOfAlarm(
                                                context,
                                                alarm.firedTime,
                                                ref,
                                                alarm,
                                              );
                                            },
                                            icon: Text('Edit'),
                                          ),
                                        ],
                                      ),
                                
                                      //list days
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: AlarmDays.values
                                            .map(
                                              (day) => GestureDetector(
                                                onTap: () {
                                                  _scheduleSelectedDay(day, ref);
 
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  width: (11.sw),
                                                  height: (11.sw),
                                                  // padding: EdgeInsets.only(top: 10, bottom: 10),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    color: repeatDays.contains(day)
                                                        ? AppColors.primaryBlue
                                                        : AppColors.primaryBlueLight,
                                                  ),
                                                  child: Text(
                                                    day.shortName,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                      //Schedule alarm
                                      SizedBox(height: 3.sh),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.containerBg,
                                
                                          // color: AppColor.alarmContainerBgColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Upcoming alarm'),
                                                  Text(
                                                    textAlign: TextAlign.start,
                                                    alarm.isEnabled
                                                        ? repeatDays.isNotEmpty
                                                              ? repeatDays.first.shortName
                                                                    .toString()
                                                              : 'Alarm is tomorrow'
                                                        : 'Alarm is off',
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      showDatePicker(
                                                        context: context,
                                                        firstDate: DateTime.now(),
                                                        lastDate: DateTime.now(),
                                                      );
                                                      //   DatePickerDialog(firstDate: DateTime.now(), lastDate: DateTime.now());
                                                    },
                                                    icon: Row(
                                                      children: [
                                                        Icon(Icons.date_range),
                                                        SizedBox(width: 5),
                                                        Text('Schedule alarm'),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      //alarm name
                                      SizedBox(height: 3.sh),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.containerBg,
                                
                                          // color: AppColor.alarmContainerBgColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                 
                    
                                                  },
                                                  icon: Icon(Icons.edit_note),
                                                ),
                                                Text(' alarm name'),
                                              ],
                                            ),
                                            Expanded(
                                              child: TextField(maxLines: viewInsetsHeight==0?null:1,
                                                focusNode: _focusNode,
                                                keyboardType: TextInputType.name,
                                                onSubmitted: (value) {
                                              
                                                  _focusNode.unfocus();
                          
                                                },
                                                onEditingComplete: () {},
                                                onTapUpOutside: (event) {
                                                
                                                },
                                                onTapAlwaysCalled: true,
                                                onTapOutside: (event) {
                                               
                                                },
                                
                                                textAlign: TextAlign.end,
                                
                                                decoration: InputDecoration(
                                                  hintText: 'Alarm name',
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                onTap: () {
                                      
                                                },
                                
                                                controller: _nameAlarmController,
                                                onChanged: (value) {
                                                  _nameAlarmController.text = value;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                
                                      //sound
                                      SizedBox(height: 0.3.sh),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.containerBg,
                                
                                          // color: AppColor.alarmContainerBgColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () async {
                                                    await _selectSound(context, selectSound);
                                                  },
                                                  icon: Icon(Icons.audiotrack),
                                                ),
                                                Text(' Sound'),
                                              ],
                                            ),
                                            TextButton(
                                              child: Text(maxLines: 1,
                                                path.basenameWithoutExtension(selectSound)),
                                              onPressed: () {},
                                            ),
                                          ],
                                        ),
                                      ),
                                     
                                      SizedBox(height: 3.sh),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.containerBg,
                                
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: Icon(Icons.vibration),
                                                ),
                                                Text('Vibrate'),
                                              ],
                                            ),
                                            Switch(
                                              value: vibrate,
                                              onChanged: (val) {
                                                val = !val;
                                                ref.read(vibrateUpdate.notifier).state = val;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                
                                      SizedBox(height: 6.sh),
                                
                                      //delete ,save alarm
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.containerBg,
                                
                                          // color: AppColor.alarmContainerBgColor,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              style: AppTheme.theme.elevatedButtonTheme.style,
                                              onPressed: () async {
                                                await ref
                                                    .read<AlarmController>(
                                                      alarmControllerProvider,
                                                    )
                                                    .deleteAlarm(alarm);
                                                if (context.mounted) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: Text(' Delete'),
                                            ),
                                
                                            ElevatedButton(
                                              onPressed: () async {
                                                _saveUpdateAlarm(
                                                  ref,
                                                  alarm,
                                                  timeAlarmUpdate,
                                                  selectSound,
                                                  repeatDays,
                                                  _nameAlarmController.text,
                                                  context,
                                                );
                                              },
                                              child: Text(' Save'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
       
    );
  }

  // Navigate to sound selection
  Future<void> _selectSound(BuildContext context, String sound) async {
    final selectedSound = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlarmSoundScreen(sound)),
    );

    ref.read(selectedSoundPathProvider.notifier).state =
        selectedSound as String;
  }

  void _scheduleSelectedDay(AlarmDays day, WidgetRef ref) {
    final repeatDays = ref.read(repeatDayMark);
    if (repeatDays.contains(day)) {
      repeatDays.remove(day);

      ref.read(repeatDayMark.notifier).state = [...repeatDays];
      return;
    }

    ref.read(repeatDayMark.notifier).state = [...repeatDays, day];
  }

  Future<void> _updateTimeOfAlarm(
    BuildContext context,
    TimeOfDay? timeOfDay,
    WidgetRef ref,
    AlarmModel alarm,
  ) async {
    if (!context.mounted) return;
    final selectedAlramTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedAlramTime != null) {
      ref.read(_timeAlarmUpdate.notifier).state = selectedAlramTime;
    }
  }

  Future<void> _saveUpdateAlarm(
    WidgetRef ref,
    AlarmModel alarm,
    TimeOfDay timeAlarm,
    String sound,
    List<AlarmDays> repeateAlarmDays,
    String alarmName,
    BuildContext context,
  ) async {
    final fireAt = TimeManager.calculateNextTriggerTime(timeAlarm);

    if (!context.mounted) return;

    final alarmTitle =
        '${getAlarmDay(fireAt.weekday).shortName}  ${TimeManager.formatTimeShow(timeAlarm, context)} ${timeAlarm.period.name.toUpperCase()}. Swip to Stop';

    final updatedAlarm = alarm.copyWith(
      repeatDays: repeateAlarmDays,

      nextTrigger: fireAt,
      firedTime: timeAlarm,
      soundPath: sound,
      name: alarmName,

      title: alarmTitle,
    );

    final success = await ref
        .read<AlarmController>(alarmControllerProvider)
        .updateAlarm(updatedAlarm);
    if (success) {
      final nowDateTime = tz.TZDateTime.now(tz.local);
      
      //nowDateTime.millisecondsSinceEpoch.toTimeOfDay
      final nextFireAt=fireAt.difference(nowDateTime).inMinutes.abs();

      HelperMessage.showToastSetAlarmMessage(
        'Alarm Set for ${nextFireAt~/60}  hours and ${nextFireAt%60} minutes from now',
      );
    }


    if (!context.mounted) return;

    Navigator.pop(context);
  }
}
