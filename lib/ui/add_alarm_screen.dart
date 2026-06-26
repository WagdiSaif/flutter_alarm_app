import 'dart:async';
import 'dart:io';
import 'package:alarmapp/core/app_theme/app_colors.dart';
import 'package:alarmapp/data/database/app_database.dart';

import 'package:alarmapp/core/utils/functions.dart';
import 'package:alarmapp/data/repositories/alarm_repository.dart';
import 'package:alarmapp/data/repositories/impl/impl_alarm_repository.dart';
import 'package:alarmapp/sizer.dart';
import 'package:alarmapp/ui/widgets/permissoin_dialog.dart';
import 'package:alarmapp/ui/widgets/toast_message.dart';
import 'package:alarmapp/data/models/alarm_model.dart';

import 'package:alarmapp/providers/alarm_controller.dart';
import 'package:alarmapp/services/time_manager.dart';
import 'package:alarmapp/services/alarm_permission.dart';
import 'package:alarmapp/services/alarm_scheduler.dart';
import 'package:alarmapp/services/alarm_service.dart';

import 'package:alarmapp/ui/widgets/alarm_bottom_sheet.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:permission_handler/permission_handler.dart';

final databaseProvider = Provider<AlarmDatabase>((ref) {
  final db = AlarmDatabase();
  ref.onDispose(() {
    db.close();
  });
  return db;
});
final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  final db = ref.watch(databaseProvider);

  return ImplAlarmRepository(db);
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

  return alarms.alarmStream;
});
StateProvider<bool> isShowBottomSheetProvider = StateProvider<bool>(
  (ref) => false,
);

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

  @override
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            height: kToolbarHeight + 5,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Alarms',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text('Settings')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final alarmsData = ref.watch(alarmProvider);

                    return alarmsData.when(
                      data: (alarms) {
                        if (alarms.isEmpty) {
                          return _buildEmptyState();
                        }
                        return SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: 19.sw),
                          child: Column(
                            children: alarms.map((alarm) {
                              return Padding(
                                padding: const EdgeInsets.all(9.0),
                                child: Dismissible(
                                  background: Container(
                                    height: 15.sh,

                                    width: 70.sw,
                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.delete, size: 20),
                                        Icon(Icons.delete, size: 20),
                                      ],
                                    ),
                                  ),

                            
                                  onDismissed: (direction) async {
                                    final isDeleted = await ref
                                        .read<AlarmController>(
                                          alarmControllerProvider,
                                        )
                                        .deleteAlarm(alarm);
                                    if (isDeleted) {
                                      ToastMessage.showToastMessage(
                                        'Alarm deleted',
                                      );
                                    }
                                  },
                                  key: ValueKey(alarm.alarmId.toString()),
                                  child: Container(
                                    constraints: BoxConstraints(
                                      maxHeight: 18.sh,
                                      minHeight: 15.sh,
                                    ),

                                    padding: EdgeInsets.all(7),

                                    decoration: BoxDecoration(
                                      color: alarm.isEnabled
                                          ? AppColors.containerBg
                                          : AppColors.surfaceDark,

                                      borderRadius: BorderRadius.circular(12),
                                    ),

                                    child: InkWell(
                                      onTap: () async {
                                        showModalBottomSheet(
                                          useSafeArea: false,
                                          showDragHandle: true,
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (context) {
                                            return AlarmBottomSheet(
                                              alarm: alarm,
                                            );
                                          },
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _checkNextTriggerDay(alarm),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                          ),

                                          Text(
                                            //Alarm Name------------=
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            alarm.name.isEmpty
                                                ? 'Alarm'
                                                : alarm.name,
                                          ),

                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  textBaseline:
                                                      TextBaseline.alphabetic,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .baseline,

                                                  children: [
                                                    Text(
                                                      TimeManager.formatTimeShow(
                                                        alarm.firedTime,
                                                        context,
                                                      ),
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.titleLarge,
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
                                                  value: alarm.isEnabled,
                                                  onChanged: (_) async {
                                                    await ref
                                                        .read<AlarmController>(
                                                          alarmControllerProvider,
                                                        )
                                                        .toggleAlarm(alarm);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                      error: (error, _) => Text('Error:'),
                      loading: () => _buildEmptyState(),
                    );
                  },
                ),

                Positioned(
                  bottom: 1,
                  right: 4.sw,
                  // right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    // alignment: Alignment.bottomCenter,
                    margin: const EdgeInsets.only(bottom: 5),
                    height: 16.sw,
                    width: 16.sw,

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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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

  String _checkNextTriggerDay(AlarmModel alarm) {
    if (alarm.isEnabled && alarm.alarmDaysModel.isEmpty) {
      if (TimeManager.isAfterDaysFromToday(alarm.nextTrigger, day: 1)) {
        return formatDateMD(alarm.nextTrigger).toString();
      }
      if (TimeManager.isAfterDaysFromToday(alarm.nextTrigger, day: 0)) {
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
          '${getAlarmDay(fireAt.weekday).shortName}  ${TimeManager.formatTimeShow(selectedTime, context)} ${selectedTime.period.name.toUpperCase()}. Click to Stop';

      bool allowed = await _requestPermissions(context);

      if (allowed) {
        final isAdded = await ref
            .read<AlarmController>(alarmControllerProvider)
            .addAlarm(
              selectedTime: selectedTime,
              title: alarmNote,
              fireAt: fireAt,
            );
        if (isAdded) {
          ToastMessage.showToastNextTriggerTime(fireAt);
        }
      }
    }
  }

  Future<bool> _requestPermissions(BuildContext context) async {
    if (Platform.isIOS) {
      return _requestIOSPermissions(context);
    }

    final initialExact = await Permission.scheduleExactAlarm.isGranted;
    final initailNotif = await Permission.notification.isGranted;

    if (initialExact && initailNotif) {
      return true;
    }

    if (!context.mounted) return false;
    final result = await PermissoinDialog.showPermissionDialog(context);

    if (result != true) {
      return false;
    }

    if (!context.mounted) return false;
    final finalNotif = await AlarmPermission.requestNotificationPermission();
    final finalExact = await Permission.scheduleExactAlarm.isGranted;
    bool hasBatteyOptimization =
        await Permission.ignoreBatteryOptimizations.isGranted;
    if (!hasBatteyOptimization) {
      hasBatteyOptimization =
          await AlarmPermission.checkBatteryOptimizationDisabled();
    }

    return finalNotif && finalExact && hasBatteyOptimization;
  }

  Future<bool> _requestIOSPermissions(BuildContext context) async {
    PermissionStatus status = await Permission.notification.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      final result = await PermissoinDialog.showPermissionDialog(context);

      if (result != true) return false;
      if (!context.mounted) return false;
      await PermissoinDialog.showPermissionOpenSettingsDialog(context);
      status = await Permission.notification.status;

      if (status.isGranted) {
        return status.isGranted;
      }
      return false;
    }

    if (status.isDenied ||
        status.isLimited ||
        status.isRestricted ||
        status.isProvisional) {
      status = await Permission.notification.request();
    }

    return status.isGranted;
  }
}
