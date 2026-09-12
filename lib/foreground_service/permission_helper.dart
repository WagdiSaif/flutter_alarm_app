import 'dart:developer';

import 'package:battery_optimization_helper/battery_optimization_helper.dart';

class PermissionHelper {
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
}
