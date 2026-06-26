import 'package:alarmapp/core/app_theme/app_colors.dart';
import 'package:alarmapp/core/app_theme/app_theme.dart';
import 'package:alarmapp/core/extensions.dart';

import 'package:alarmapp/core/utils/functions.dart';
import 'package:alarmapp/core/enum/enums.dart';
import 'package:alarmapp/core/constants/constant.dart';
import 'package:alarmapp/sizer.dart';
import 'package:alarmapp/ui/widgets/toast_message.dart';
import 'package:path/path.dart' as path;
import 'package:alarmapp/data/models/alarm_model.dart';
import 'package:alarmapp/providers/alarm_controller.dart';
import 'package:alarmapp/services/time_manager.dart';
import 'package:alarmapp/ui/add_alarm_screen.dart';
import 'package:alarmapp/ui/alarm_sound_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart' as tz;

StateProvider<List<AlarmDays>> repeatDayMark = StateProvider<List<AlarmDays>>(
  (ref) => <AlarmDays>[],
);
StateProvider<String> selectedSoundPathProvider = StateProvider<String>(
  (ref) => AppConstants.defaultSound,
);

StateProvider<TimeOfDay> _timeAlarmUpdate = StateProvider<TimeOfDay>(
  (ref) => TimeOfDay.now(),
);

StateProvider<bool> vibrateUpdate = StateProvider<bool>((ref) => false);

StateProvider<TZDateTime?> customAlarmDateProvider = StateProvider<TZDateTime?>(
  (ref) => null,
);

class AlarmBottomSheet extends ConsumerStatefulWidget {
  const AlarmBottomSheet({super.key, required this.alarm});
  final AlarmModel alarm;

  @override
  ConsumerState<AlarmBottomSheet> createState() => _AlarmBottomSheet();
}

class _AlarmBottomSheet extends ConsumerState<AlarmBottomSheet> {
  late TextEditingController _nameAlarmController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(repeatDayMark.notifier).state = [...widget.alarm.repeatDays];
      ref.read(selectedSoundPathProvider.notifier).state =
          widget.alarm.soundPath;

      if (widget.alarm.repeatDays.isEmpty &&
          TimeManager.isAfterDaysFromToday(widget.alarm.nextTrigger)) {
        ref.read(customAlarmDateProvider.notifier).state =
            widget.alarm.nextTrigger;
      } else {
        ref.read(customAlarmDateProvider.notifier).state = null;
      }
      ref.read(_timeAlarmUpdate.notifier).state = widget.alarm.firedTime;
      ref.read(vibrateUpdate.notifier).state = widget.alarm.vibrate;
    });
    _nameAlarmController = TextEditingController(
      text: widget.alarm.name.isEmpty ? null : widget.alarm.name,
    );
  }

  late FocusNode _focusNode;
  @override
  void dispose() {
    _nameAlarmController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repeatDays = ref.watch(repeatDayMark);
    final customAlarmDate = ref.watch(customAlarmDateProvider);
    final selectSound = ref.watch(selectedSoundPathProvider);

    final timeAlarmUpdate = ref.watch(_timeAlarmUpdate);
    final vibrate = ref.watch(vibrateUpdate);

    double viewInsetsHeight = MediaQuery.of(context).viewInsets.bottom;

    final alarm = widget.alarm;

    return DraggableScrollableSheet(
      initialChildSize: viewInsetsHeight == 0 ? 0.70 : 1.0,
      minChildSize: 0.65,
      maxChildSize: 1.0,

      expand: false,

      builder: (context, scrollController) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: false,

                physics: viewInsetsHeight == 0
                    ? NeverScrollableScrollPhysics()
                    : AlwaysScrollableScrollPhysics(),

                controller: scrollController,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 4.sw, right: 4.sw),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,

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
                                          alarm.firedTime.period.name
                                              .toUpperCase(),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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

                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                            if (alarm.isEnabled) ...[
                                              repeatDays.isNotEmpty
                                                  ? Text(
                                                      repeatDays
                                                          .first
                                                          .shortName,
                                                    )
                                                  : Text(
                                                      customAlarmDate != null
                                                          ? formatDateMD(
                                                              alarm.nextTrigger,
                                                            )
                                                          : alarm
                                                                    .nextTrigger
                                                                    .weekday >
                                                                tz.TZDateTime.now(
                                                                  tz.local,
                                                                ).weekday
                                                          ? 'Tomorrow'
                                                          : 'Today',
                                                    ),
                                            ] else
                                              (Text(' Alarm is off')),
                                            //
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () async {
                                                final firstDate =
                                                    TimeManager.customDateTime(
                                                      day: 1,
                                                    );

                                                final lastDate =
                                                    TimeManager.customDateTime(
                                                      year: firstDate.day + 60,
                                                    );

                                                var customAlarmDate =
                                                    await showDatePicker(
                                                      context: context,
                                                      firstDate: firstDate,
                                                      lastDate: lastDate,
                                                    );

                                                if (customAlarmDate != null) {
                                                  ref
                                                      .read(
                                                        customAlarmDateProvider
                                                            .notifier,
                                                      )
                                                      .state = customAlarmDate
                                                      .toLocalTz;

                                                  ref
                                                          .read(
                                                            repeatDayMark
                                                                .notifier,
                                                          )
                                                          .state =
                                                      [];
                                                }
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
                                          maxLines: viewInsetsHeight == 0
                                              ? null
                                              : 1,
                                          focusNode: _focusNode,

                                          onSubmitted: (value) {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },

                                          onTapAlwaysCalled: true,
                                          onTapOutside: (event) {},

                                          textAlign: TextAlign.end,

                                          decoration: InputDecoration(
                                            hintText: 'Alarm name',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(4),
                                          ),

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
                                        child: Text(
                                          maxLines: 1,
                                          path.basenameWithoutExtension(
                                            selectSound,
                                          ),
                                        ),
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
                                          ref
                                                  .read(vibrateUpdate.notifier)
                                                  .state =
                                              val;
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

                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        style: AppTheme
                                            .theme
                                            .elevatedButtonTheme
                                            .style,
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
                                            customAlarmDate,
                                            vibrate,
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
        );
      },
    );
  }

  // Navigate to select  sound
  Future<void> _selectSound(BuildContext context, String sound) async {
    final selectedSound = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlarmSoundScreen(sound)),
    );

    ref.read(selectedSoundPathProvider.notifier).state =
        selectedSound as String? ?? sound;
  }

  void _scheduleSelectedDay(AlarmDays day, WidgetRef ref) {
    final repeatDays = ref.read(repeatDayMark);
    ref.read(customAlarmDateProvider.notifier).state = null;

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
    TZDateTime? customAlarmDate,
    bool vibrate,
    WidgetRef ref,
    AlarmModel alarm,
    TimeOfDay timeAlarm,
    String sound,
    List<AlarmDays> repeateAlarmDays,
    String alarmName,
    BuildContext context,
  ) async {
    final fireAt = customAlarmDate != null
        ? TZDateTime(
            tz.local,
            customAlarmDate.year,
            customAlarmDate.month,
            customAlarmDate.day,
            timeAlarm.hour,
            timeAlarm.minute,
          )
        : TimeManager.calculateNextTriggerTime(timeAlarm);

    if (!context.mounted) return;

    final alarmTitle =
        '${getAlarmDay(fireAt.weekday).shortName}  ${TimeManager.formatTimeShow(timeAlarm, context)} ${timeAlarm.period.name.toUpperCase()}. Swip to Stop';

    final updatedAlarm = alarm.copyWith(
      vibrate: vibrate,
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
    if (success && updatedAlarm.isEnabled) {
      ToastMessage.showToastNextTriggerTime(fireAt);
    }

    if (!context.mounted) return;

    Navigator.pop(context);
  }
}
