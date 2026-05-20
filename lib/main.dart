
import 'package:alarm/alarm.dart';
import 'package:alarmapp/services/alarm_shared_preference.dart';
import 'package:alarmapp/core/app_theme/app_theme.dart';
import 'package:alarmapp/helper/constants.dart';
import 'package:alarmapp/helper/sizer.dart';
import 'package:alarmapp/services/time_manager.dart';

import 'package:alarmapp/ui/alarm_rining_screen.dart';

import 'package:alarmapp/ui/home_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final container = ProviderContainer();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Alarm.init();
await AlarmSharedPrefs.initialize();
await TimeManager.initTimeZone();

 //await Alarm.set(alarmSettings: AlarmSettings(assetAudioPath: AppConstants.defaultSound, id: 233, dateTime: DateTime.now().subtract(Duration(hours: 3),), volumeSettings: VolumeSettings.fade(fadeDuration: Duration(microseconds: 22)), notificationSettings: NotificationSettings(title: DateTime.now().subtract(Duration(hours: 3)).toString(), body: DateTime.now().subtract(Duration(hours: 3)).toString()),));
  runApp( ProviderScope( child: MyApp()));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      routes:<String,WidgetBuilder> {
        '/': (context) => SizerUitles(builder: (context) => HomeScreen()),
        '/ringingScreen': (context) => RingingAlarmScreen(),
      },

      debugShowCheckedModeBanner: false,
      title: 'Alarm App ',
      theme: AppTheme.theme,
      navigatorKey: navigatorKey,
      initialRoute: '/',
    );
  }
}
