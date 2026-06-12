
import 'package:alarmapp/core/app_theme/app_theme.dart';
import 'package:alarmapp/core/extensions.dart';
import 'package:alarmapp/sizer.dart';
import 'package:alarmapp/services/time_manager.dart';
import 'package:alarmapp/core/app_theme/app_colors.dart';

import 'package:alarmapp/core/app_theme/app_texts_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add_alarm_screen.dart';

class RingingAlarmScreen extends ConsumerWidget {
  const RingingAlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data =
        ModalRoute.settingsOf(context)?.arguments as Map<String, dynamic>? ??
        {};
    final alarmId = data['alarmId'] as int?;
    final name = data['name'] as String? ?? '';
    final title = data['title'] as String? ?? '';
    final firedTime = data['firedTime'] as TimeOfDay?;

    return Scaffold(
      backgroundColor: AppTheme.theme.primaryColorDark,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alarm, size: 10.sh, color: AppColors.redColor),
            const SizedBox(height: 40),
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
            Text(
              name,
              style: AppTextStyles.bodySmall,
            
            ),

            const SizedBox(height: 40),
            Text(
              TimeManager.formatTimeShow(firedTime ?? TimeOfDay.now(), context),
              style: AppTextStyles.headlineLarge,
           
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  label: 'SNOOZE',
                  icon: Icons.snooze,
                  color: AppColors.primaryBlue,
                  onPressed: () async {
                    await ref
                        .read(schedulerProvider)
                        .snoozeAlarm(alarmId!, DateTime.now().toLocalTz);

                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                _buildActionButton(
                  label: 'STOP',
                  icon: Icons.stop,
                  color: AppColors.redColor,
                  onPressed: () async {
                    if (alarmId == null) return;

                    await ref.read(schedulerProvider).stopAlarm(alarmId);

                    await ref.read(alarmControllerProvider).rescheduleActiveAlarms();
                  

                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: appTheme.elevatedButtonTheme.style!.copyWith(
        backgroundColor: WidgetStatePropertyAll(color),
      ),
    );
  }
}
