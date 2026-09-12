import 'dart:async';

import 'package:alarmapp/core/app_theme/app_colors.dart';

import 'package:alarmapp/core/app_theme/app_texts_styles.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:alarmapp/foreground_service/android_platform/android_foreground_service.dart';
import 'package:alarmapp/foreground_service/app_lifecycle_handler.dart';
import 'package:alarmapp/foreground_service/ios_platform/ios_foreground_service.dart';
import 'package:alarmapp/foreground_service/platform_initializer.dart';
import 'package:alarmapp/main.dart';

import 'package:alarmapp/services/alarm_shared_preference.dart';
import 'package:alarmapp/services/permission_helper.dart';

import 'package:alarmapp/ui/stopwatch_screen.dart';
import 'package:alarmapp/ui/timer_preset_screeen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add_alarm_screen.dart';

final platformInitializerProvider = Provider<PlatformInitializer>(
  (ref) => PlatformInitializer.instance,
);
final iosForegroundServiceProvider = Provider<IosForegroundService>(
  (ref) => IosForegroundService(),
);
final androidForegroundServiceProvider = Provider<AndroidForegroundService>(
  (ref) => AndroidForegroundService(),
);
final appLifecycleHandlerProvider = Provider<AppLifecycleHandler>((ref) {
  return AppLifecycleHandler(ref: ref);
});

final pageIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  AppLifecycleListener? _appLifecycleListener;
  final List<BottomNavigationBarItem> _bottomNavigationItems = [
    BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Alarm"),
    BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Timer"),

    BottomNavigationBarItem(icon: Icon(Icons.stop_circle), label: "StopWatch"),
  ];

  final _pages = [AddAlarmScreen(), TimerPresetScreeen(), StopwatchScreen()];

  StreamSubscription<AlarmSet>? _alarmSub;
  void onAlarmRinging(AlarmSettings alarm, BuildContext context) {
    final firedAt = alarm.dateTime.toLocal();
    final firedATime = TimeOfDay(hour: firedAt.hour, minute: firedAt.minute);

    _showAlarmScreen(
      alarm.id,
      alarm.notificationSettings.title,
      firedATime,
      alarm.notificationSettings.body,
      context,
    );
  }

  Future<void> _showAlarmScreen(
    int id,
    String title,
    TimeOfDay firedTime,
    String name,
    BuildContext context,
  ) async {
    bool canNavigate = await ref
        .read(alarmControllerProvider)
        .canNavigateToRingingScreen(id);
    if (!canNavigate) return;
    final alarmSharedPrefs = AlarmSharedPrefs.instance;
    await alarmSharedPrefs.setAlarmState(ringing, id);

    if (!context.mounted) return;

    navigatorKey.currentState
        ?.pushNamed(
          '/ringingScreen',
          arguments: <String, dynamic>{
            "firedTime": firedTime,
            "alarmId": id,
            "title": title,
            "name": name,
          },
        )
        .then((_) async {
          // no snooze but ringing
          if (!alarmSharedPrefs.isSnoozeState ||
              alarmSharedPrefs.isRingingState) {
            await alarmSharedPrefs.removeAllState();
          }
        });
  }

  @override
  void initState() {
    super.initState();
    _alarmSub = Alarm.ringing.listen((event) {
      if (event.alarms.isEmpty) return;

      onAlarmRinging(event.alarms.first, context);
    });
    _appLifecycleListener = AppLifecycleListener(
      onStateChange: (value) async {
        switch (value) {
          case AppLifecycleState.hidden:
          case AppLifecycleState.paused:
            await ref.read(appLifecycleHandlerProvider).onBackground();

            break;
          case AppLifecycleState.resumed:
            await ref.read(appLifecycleHandlerProvider).onResume();
            break;
          case AppLifecycleState.inactive:
            final double currentWindowHeight = View.of(context)
                .physicalConstraints
                .maxHeight;
            final double deviceDisplayHeight = View.of(context)
                .display
                .size
                .height;
            if (currentWindowHeight < deviceDisplayHeight * .9) {
              await ref.read(appLifecycleHandlerProvider).onBackground();
            }
            break;
          default:
            break;
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PermissionHelpers().requestNotificationPermission();

      await ref.read(appLifecycleHandlerProvider).onResume();

      await ref.read(alarmControllerProvider).rescheduleAlarms();
    });
  }

  @override
  void dispose() {
    _alarmSub?.cancel();
    _appLifecycleListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(pageIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        showSelectedLabels: true,
        onTap: (index) => ref.read(pageIndexProvider.notifier).state = index,
        items: _bottomNavigationItems,
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textDisabled,
        showUnselectedLabels: true,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.labelMedium,
        unselectedLabelStyle: AppTextStyles.labelMedium,
      ),
    );
  }
}
