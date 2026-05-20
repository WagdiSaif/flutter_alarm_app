import 'dart:async';
import 'dart:io';
import 'package:alarmapp/core/app_theme/app_colors.dart';
import 'package:alarmapp/core/data/database/app_database.dart';
import 'package:alarmapp/core/app_theme/app_theme.dart';
import 'package:alarmapp/core/utils/functions.dart';
import 'package:alarmapp/core/data/repositories/alarm_repository.dart';
import 'package:alarmapp/core/data/repositories/imprepository/imp_alarm_repository.dart';
import 'package:alarmapp/helper/helper_message.dart';
import 'package:alarmapp/core/models/alarm_model.dart';

import 'package:alarmapp/providers/alarm_controller.dart';
import 'package:alarmapp/services/time_manager.dart';
import 'package:alarmapp/services/alarm_permission.dart';
import 'package:alarmapp/services/alarm_scheduler.dart';
import 'package:alarmapp/services/alarm_service.dart';

import 'package:alarmapp/ui/alarm_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

final databaseProvider = Provider<AlarmDatabase>((ref) {
  final db = AlarmDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});
final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  final db = ref.watch(databaseProvider);

  return ImpAlarmRepository(db);
});
final serviceProvider = Provider<AlarmService>((ref) {
  final repository = ref.watch(alarmRepositoryProvider);
  return AlarmService(repository);
});
final schedulerProvider = Provider<AlarmScheduler>((ref) {
  return AlarmScheduler();
});
final alarmControllerProvider = Provider<AlarmController>((ref) {
  final service = ref.watch(serviceProvider);
  final scheduler = ref.watch(schedulerProvider);

  return AlarmController(service, scheduler);
});
final alarmProvider = StreamProvider.autoDispose<List<AlarmModel>>((ref) {
  final alarms = ref.watch(alarmControllerProvider);
  return alarms.alarmStream();
});

class AddAlarmScreen extends ConsumerStatefulWidget {
  const AddAlarmScreen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddAlarmScreen();
}

class _AddAlarmScreen extends ConsumerState<AddAlarmScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double height = 0.0;
  double width = 0.0;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    final alarmsData = ref.watch(alarmProvider);

    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: height * 0.07,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
         
                Text('Alarm', style: Theme.of(context).textTheme.headlineLarge),
                PopupMenuButton(
                  
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text('data')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: Stack(
                        children: [
                          alarmsData.when(
                            data: (alarms) {
                              if (alarms.isEmpty) {
                                return _buildEmptyAlarms();
                              }
                              return SingleChildScrollView(
                                padding: EdgeInsets.only(bottom: 15),
                                child: Column(
                                  children: alarms
                                      .map(
                                        (alarm) => Dismissible(
                                          confirmDismiss: (direction) async {
                                            //  await  direction.
                                            return true;
                                          },
                                          onDismissed: (direction) {
                                            debugPrint("Hello dismissble");
                                          },
                                          key: GlobalKey(
                                            debugLabel: alarm.alarmId
                                                .toString(),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(9.0),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxHeight: height * .17,
                                                minHeight: height * .15,
                                              ),
                                            
                                              padding: EdgeInsets.all(7),

                                              decoration: BoxDecoration(
                                                color: alarm.isEnabled
                                                    ? AppColors.containerBg
                                                    : AppColors
                                                          .containerBgPale95,

                                          
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),

                                              child: InkWell(
                                                onTap: () async {
                                                  showModalBottomSheet(
                                                    showDragHandle: true,
                                                    isScrollControlled: true,
                                                    context: context,
                                                    builder: (context) =>
                                                        AlarmBottomSheet(
                                                          alarm: alarm,
                                                        ),
                                                  );
                                                },
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _checkNextTriggerDay(
                                                        alarm,
                                                      ),
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.titleLarge,
                                                    ),

                                                    Text(
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      alarm.name,
                                                    ),

                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Row(
                                                          textBaseline:
                                                              TextBaseline
                                                                  .alphabetic,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .baseline,
                                                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              TimeManager.formatTimeShow(
                                                                alarm.firedTime,
                                                                context,
                                                              ),
                                                              style:
                                                                  Theme.of(
                                                                        context,
                                                                      )
                                                                      .textTheme
                                                                      .titleLarge,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    left: 0,
                                                                  ),
                                                              child: Text(
                                                                alarm
                                                                    .firedTime
                                                                    .period
                                                                    .name
                                                                    .toUpperCase(),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Switch(
                                                          value:
                                                              alarm.isEnabled,
                                                          onChanged: (_) async {
                                                            await ref
                                                                .read<
                                                                  AlarmController
                                                                >(
                                                                  alarmControllerProvider,
                                                                )
                                                                .toggleAlarm(
                                                                  alarm,
                                                                );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              );
                            },
                            error: (error, _) => Text('Error:'),
                            loading: () => _buildEmptyAlarms(),
                          ),

                          Positioned(
                            bottom: 1,
                            left: width * 0.04,
                            // right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              // alignment: Alignment.bottomCenter,
                              margin: const EdgeInsets.only(bottom: 3),
                              height: 70,
                              width: 70,

                              child: Center(
                                child: IconButton(
                                  onPressed: () async {
                                    await pickTimeAndCreateAlarm(context, ref);
                                  },
                                  icon: const Icon(Icons.add, size: 20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildEmptyAlarms() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alarm),
          Text('No Alarms', style: Theme.of(context).textTheme.headlineLarge),
        ],
      ),
    );
  }
  //DateTime.now();

  String _checkNextTriggerDay(AlarmModel alarm) {
    final now = tz.TZDateTime.now(tz.local);
    if (alarm.isEnabled && alarm.alarmDaysModel.isEmpty) {
      if (now.isAfter(alarm.nextTrigger)) {
        return 'Tomorrow';
      }
      return 'Today';
    } else if (alarm.isEnabled && alarm.alarmDaysModel.isNotEmpty) {
      final weakDayAlarms = alarm.alarmDaysModel
          .map((day) => '${day.repeatedDays?.shortName} ')
          .toList();

      return weakDayAlarms.join();
    } else {
      return "Not scheduled";
    }
  }

  Future<void> pickTimeAndCreateAlarm(
    BuildContext context,

    WidgetRef ref,
  ) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      final fireAt = TimeManager.calculateNextTriggerTime(selectedTime);
      if (!context.mounted) return;
      final alarmNote =
          '${getAlarmDay(fireAt.weekday).shortName}  ${TimeManager.formatTimeShow(selectedTime, context)} ${selectedTime.period.name.toUpperCase()}. Swip to Stop';
      bool allowed = false;

      allowed = await _requestPermissions(context);
      debugPrint("Permissions allowed: $allowed");

      if (allowed) {
        debugPrint('alarms.nextTrigg selected is $fireAt');
        final isAdded = await ref
            .read<AlarmController>(alarmControllerProvider)
            .addAlarm(
              selectedTime: selectedTime,
              title: alarmNote,
              fireAt: fireAt,
            );
        if (isAdded) {
          final nowDateTime = tz.TZDateTime.now(tz.local);
          final hours = fireAt.difference(nowDateTime).inHours;
          final messageHuors = hours > 0 ? '${hours}hours and' : null;

          HelperMessage.showToastSetAlarmMessage(
            'Alarm Set for ${messageHuors ?? ''} ${fireAt.difference(nowDateTime).inMinutes} minutes from now',
          );
        }
        debugPrint(
          'current DateTime.NotificationService().addAlarm():$isAdded',
        );
      }
    }
  }

  Future<bool> _requestPermissions(BuildContext context) async {
    final hasExact = await Permission.scheduleExactAlarm.isGranted;
    final hasNotif = await Permission.notification.isGranted;

    if (hasExact && hasNotif) {
      return true;
    }

    if (!context.mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Permissions Required"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "This app needs the following permissions to work properly:",
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.notifications, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "• Notifications - to alert you when alarm rings",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.alarm, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text("• Exact alarms - to ring at precise time"),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return false;
    }

    // Request permissions

    // final notif = await AlarmPermission.requestNotificationPermission();

    // debugPrint('📢 Requesting exact alarm permission...');
    // final exact = await AlarmPermission.ensureExactAlarmPermission();
    // debugPrint('Exact alarm permission result: $exact');

    // Check final status

    bool finalNotif = await Permission.notification.isGranted;
    final finalExact = await Permission.scheduleExactAlarm.isGranted;

    debugPrint('Final permissions - Notif: $finalNotif, Exact: $finalExact');
    if (Platform.isAndroid) {
      if (!finalNotif || !finalExact) {
        // Some permissions were denied
        if (context.mounted) {
          AlarmPermission.showPermissionHelpDialog(context);
        }
      }
      return finalNotif && finalExact;
    } else {
      if (!finalNotif) {
        // Some permissions were denied
        //  await AlarmPermission.checkBatteryOptimizationDisabled();
        if (!context.mounted) return false;
        finalNotif = await AlarmPermission.requestNotificationPermission();
        debugPrint(
          'Final requestNotificationPermission - Notif: $finalNotif, Exact:',
        );
      }
      return finalNotif;
    }
  }
}
