import 'package:alarm/alarm.dart';

import 'package:alarmapp/services/alarm_shared_preference.dart';
import 'package:alarmapp/core/app_theme/app_theme.dart';

import 'package:alarmapp/sizer.dart';
import 'package:alarmapp/services/time_manager.dart';

import 'package:alarmapp/ui/alarm_ringing_screen.dart';

import 'package:alarmapp/ui/home_screen.dart';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Alarm.init();
  await AlarmSharedPrefs.initialize();
  await TimeManager.initTimeZone();

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: <String, WidgetBuilder>{
        '/': (context) => SizerUitles(builder: (context) => HomeScreen()),
        '/ringingScreen': (context) => RingingAlarmScreen(),
      },

      debugShowCheckedModeBanner: false,
      title: 'Alarm App ',
      theme: AppTheme.theme,
   
      initialRoute: '/',
    );
  }
}
