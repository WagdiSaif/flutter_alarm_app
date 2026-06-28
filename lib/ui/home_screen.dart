import 'dart:async';
import 'package:alarmapp/core/app_theme/app_colors.dart';

import 'package:alarmapp/core/app_theme/app_texts_styles.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:alarmapp/services/alarm_shared_preference.dart';

import 'package:alarmapp/ui/stopwatch_screen.dart';
import 'package:alarmapp/ui/timer_preset_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add_alarm_screen.dart';

final pageIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<BottomNavigationBarItem> _bottomNavigationItems = [
    BottomNavigationBarItem(icon: Icon(Icons.alarm), label: "Alarm"),
    BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Timer"),

    BottomNavigationBarItem(icon: Icon(Icons.stop_circle), label: "StopWatch"),
  ];

  final List<Widget> _pages = [
    const AddAlarmScreen(),
    const TimerPresetScreen(),

    const StopwatchScreen(),
  ];

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
    await AlarmSharedPrefs.setAlarmState(ringing, id);

    if (!context.mounted) return;

    Navigator.of(context)
        .pushNamed(
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
          if (!AlarmSharedPrefs.isSnoozeState ||
              AlarmSharedPrefs.isRingingState) {
            await AlarmSharedPrefs.removeAllState();
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(alarmControllerProvider).rescheduleAlarms();
    });
  }

  @override
  void dispose() {
    _alarmSub?.cancel();
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
