import 'package:alarmapp/core/enums/stopwatch_enum.dart';
import 'package:alarmapp/foreground_service/android_platform/android_foreground_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AndroidNotifications {
  static final _notificationsPlugin = AndroidFlutterLocalNotificationsPlugin();
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> cancelById(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  static final initializationSettings = AndroidInitializationSettings(
    'ic_bg_service_notification',
  );

  Future<void> initialize() async {
    await _notificationsPlugin.initialize(
      onDidReceiveBackgroundNotificationResponse: onNotificationButtonPressed,
      onDidReceiveNotificationResponse: onNotificationButtonPressed,
      settings: initializationSettings,
    );
  }

  Future<void> createNotification({
    StopwatchButtonAction? buttonAction,
    int id = 500,

    String? title,
    String? body,
    String? payload,
    required int countLap,
  }) async {
    final newBody = countLap > 1 ? 'Lap ${countLap - 1}' : body;
    await _notificationsPlugin.show(
      body: newBody,
      title: title,
      id: id,

      notificationDetails: AndroidNotificationDetails(
        groupKey: 'android_notifi_group',
        "notification_id_notif_w",
        "notification_channel__w",
        icon: 'ic_bg_service_notification',
        importance: Importance.min,
        priority: Priority.min,

        channelAction: AndroidNotificationChannelAction.createIfNotExists,

        actions: _createButtonActions(buttonAction: buttonAction),
      ),
    );
  }

  List<AndroidNotificationAction> _createButtonActions({
    StopwatchButtonAction? buttonAction,
  }) {
    if (buttonAction == StopwatchButtonAction.pause) {
      return [
        AndroidNotificationAction(
          StopwatchButtonAction.reset.name,
          StopwatchButtonAction.reset.label,
        ),
        AndroidNotificationAction(
          StopwatchButtonAction.start.name,
          StopwatchButtonAction.start.label,
        ),
      ];
    }
    return [
      AndroidNotificationAction(
        StopwatchButtonAction.lap.name,
        StopwatchButtonAction.lap.label,
      ),
      AndroidNotificationAction(
        StopwatchButtonAction.pause.name,
        StopwatchButtonAction.pause.label,
      ),
    ];
  }
}
