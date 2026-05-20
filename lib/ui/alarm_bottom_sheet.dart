import 'package:alarmapp/core/app_theme/app_colors.dart';


import 'package:alarmapp/core/utils/functions.dart';
import 'package:alarmapp/core/enum/enums.dart';
import 'package:alarmapp/helper/constants.dart';
import 'package:alarmapp/helper/helper_message.dart';

import 'package:alarmapp/core/models/alarm_model.dart';
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
StateProvider<double> _initialChildSize = StateProvider<double>((ref) => 0.50);
StateProvider<TimeOfDay> _timeAlarmUpdate = StateProvider<TimeOfDay>(
  (ref) => TimeOfDay.now(),
);

StateProvider<bool> vibrateUpdate = StateProvider<bool>((ref) => false);

class AlarmBottomSheet extends ConsumerStatefulWidget with RouteAware {
  //State Widget<=======================>>
  const AlarmBottomSheet({super.key, required this.alarm});
  final AlarmModel alarm;

  @override
  ConsumerState<AlarmBottomSheet> createState() => _AlarmBottomSheet();
}

class _AlarmBottomSheet extends ConsumerState<AlarmBottomSheet>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  late TextEditingController _nameAlarmController;
  double height = 0.0;
  double width = 0.0;

  // final _scrollController = DraggableScrollableController();
  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _animationController?.dispose();
    _nameAlarmController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    final repeatDays = ref.watch(repeatDayMark);

    final selectSound = ref.watch(selectedSoundPathProvider);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final timeAlarmUpdate = ref.watch(_timeAlarmUpdate);
    final vibrate = ref.watch(vibrateUpdate);
    //vibrateUpdate
    //selectedSoundPathProvider

    final alarm = widget.alarm;

    return DraggableScrollableSheet(
      // snap: true,
      //snap: true,
      initialChildSize: 0.65,
      minChildSize: 0.65,
      // maxChildSize: 1.0,
      expand: false,

      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // reverse: true,
                  //    dragStartBehavior: DragStartBehavior.down,
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    bottom: keyboardHeight, // Add padding for keyboard
                    left: width * 0.04,
                    right: width * 0.04,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          // Add padding for keyboard
                          left: width * 0.04,
                          right: width * 0.04,
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  children: [
                                    Text(
                                      TimeManager.formatTimeShow(
                                        timeAlarmUpdate,
                                        context,
                                      ),
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      alarm.firedTime.period.name.toUpperCase(),
                                    ),
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
                                        //debugPrint(' ref.watch(repeatDayMark);${repeatDays}');
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: (width * 0.11),
                                        height: (width * 0.10),
                                        // padding: EdgeInsets.only(top: 10, bottom: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color:
                                            repeatDays.contains(day)
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
                            SizedBox(height: height * 0.03),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.containerBg,

                                // color: AppColor.alarmContainerBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                            SizedBox(height: height * 0.02),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.containerBg,

                                // color: AppColor.alarmContainerBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.edit_note),
                                      ),
                                      Text(' alarm name'),
                                    ],
                                  ),
                                  Expanded(
                                    child: TextField(
                                      onSubmitted: (value) {
                                        ref
                                                .read(
                                                  _initialChildSize.notifier,
                                                )
                                                .state =
                                            0.55;
                                      },
                                      onEditingComplete: () {
                                        ref
                                                .read(
                                                  _initialChildSize.notifier,
                                                )
                                                .state =
                                            0.55;
                                      },
                                      onTapOutside: (event) {},
                                      textAlign: TextAlign.end,

                                      decoration: InputDecoration(
                                        hintText: 'Alarm name',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      onTap: () {
                                        // Scroll to TextField when tapped
                                        ref
                                                .read(
                                                  _initialChildSize.notifier,
                                                )
                                                .state =
                                            1.0;
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
                            SizedBox(height: height * 0.003),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.containerBg,

                                // color: AppColor.alarmContainerBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          await _selectSound(
                                            context,
                                            selectSound,
                                          );
                                        },
                                        icon: Icon(Icons.audiotrack),
                                      ),
                                      Text(' Sound'),
                                    ],
                                  ),
                                  TextButton(
                                    child: Text(selectSound.split('/').last),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            //vibrate
                            SizedBox(height: height * 0.003),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.containerBg,

                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      ref.read(vibrateUpdate.notifier).state =
                                          val;
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: height * 0.06),

                            //delete ,save alarm
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.containerBg,

                                // color: AppColor.alarmContainerBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
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
        if(success){
            final nowDateTime =tz.TZDateTime.now(tz.local);
          HelperMessage.showToastSetAlarmMessage('Alarm Set for ${fireAt.difference(nowDateTime).inHours}  hours and ${fireAt.difference(nowDateTime).inMinutes} minutes from now');
        }
    debugPrint('Time alarm updated is $success');
    if (!context.mounted) return;

    Navigator.pop(context);
  }
}
