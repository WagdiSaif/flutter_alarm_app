import 'dart:developer';

import 'package:battery_optimization_helper/battery_optimization_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelpers {
  static Future<void> requestBatteryOptimization() async {
    try {
      bool isEnabled =
          await BatteryOptimizationHelper.isBatteryOptimizationEnabled();

      if (!isEnabled) return;

      final outcome =
          await BatteryOptimizationHelper.ensureOptimizationDisabledDetailed(
            openSettingsIfDirectRequestNotPossible: true,
          );

      if (outcome.isOptimizationDisabled ||
          outcome.status == OptimizationOutcomeStatus.disabledAfterPrompt ||
          outcome.status == OptimizationOutcomeStatus.alreadyDisabled) {
        return;
      }
      if (outcome.status == OptimizationOutcomeStatus.settingsOpened) {
        return;
      }
      final openedOEM = await BatteryOptimizationHelper.openAutoStartSettings();

      if (openedOEM) {
        return;
      }
      isEnabled =
          await BatteryOptimizationHelper.isBatteryOptimizationEnabled();

      if (!isEnabled) return;
      await BatteryOptimizationHelper.openBatteryOptimizationSettings();
    } catch (e) {
      log('Failed to add Battery Optimization $e');
    }
  }

  Future<bool> requestNotificationPermission() async {
    final requestResults = await [
      Permission.scheduleExactAlarm,
      Permission.notification,
      Permission.systemAlertWindow,
      
    ].request();

    final isAllow = requestResults.values.every(
      (permission) => permission.isGranted,
    );

    if (isAllow) {
      await requestBatteryOptimization();
      return true;
    }
    if (requestResults.values.any(
      (permission) => permission.isPermanentlyDenied,
    )) {
      await openAppSettings();
    }

    return false;
  }
}
