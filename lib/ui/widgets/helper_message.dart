import 'package:alarmapp/core/app_theme/app_colors.dart';


import 'package:fluttertoast/fluttertoast.dart';

class HelperMessage {
  static Future<void> showToastSetAlarmMessage( String message) async {
 Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: AppColors.primaryBlueLight,
        textColor: AppColors.textPrimary,
        fontSize: 16.0
    );
  }
}
