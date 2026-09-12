import 'package:alarmapp/core/app_theme/app_colors.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:timezone/timezone.dart' as tz;

class ToastMessage {
  static void showNextTriggerTime(tz.TZDateTime nextTrigger) {
    final nowDateTime = tz.TZDateTime.now(tz.local);
    final nextFireInminutes = nextTrigger.difference(nowDateTime).inMinutes;
    final hours = nextFireInminutes ~/ 60;
    final minutes = nextFireInminutes % 60;

    final nextFireAt = hours >= 1
        ? '$hours hours ${minutes >= 1 ? 'and $minutes Minutes ' : ''}'
        : minutes >= 1
        ? '$minutes Minutes'
        : 'less than 1 Mnutes';

    final message = 'Alarm Set for $nextFireAt  from now';
    showMessage(message);
  }

  static void showMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 2,
      backgroundColor: AppColors.primaryBlueLight,
      textColor: AppColors.textPrimary,
      fontSize: 16.0,
    );
  }
}
