
import 'package:alarmapp/helper/sizer.dart';
import 'package:alarmapp/core/app_theme/app_texts_styles.dart';
import 'package:alarmapp/core/models/timer_state.dart';
import 'package:alarmapp/services/timer_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alarmapp/core/app_theme/app_colors.dart';



final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});

class TimerPresetScreen extends ConsumerStatefulWidget {
  const TimerPresetScreen({super.key});

  @override
  ConsumerState<TimerPresetScreen> createState() => _TimerPresetScreenState();
}

class _TimerPresetScreenState extends ConsumerState<TimerPresetScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }
    final presets = [
      {'label': '1m', 'duration': const Duration(minutes: 1), 'icon': Icons.looks_one, 'color': AppColors.success},
      {'label': '3m', 'duration': const Duration(minutes: 3), 'icon': Icons.looks_3, 'color': Colors.teal.shade400},
      {'label': '5m', 'duration': const Duration(minutes: 5), 'icon': Icons.looks_5, 'color': AppColors.primaryBlue},
      {'label': '10m', 'duration': const Duration(minutes: 10), 'icon': Icons.looks_one, 'color': AppColors.primaryBlueLight},
      {'label': '15m', 'duration': const Duration(minutes: 15), 'icon': Icons.looks_one, 'color': Colors.indigo.shade400},
      {'label': '30m', 'duration': const Duration(minutes: 30), 'icon': Icons.looks_3, 'color': Colors.purple.shade400},
      {'label': '45m', 'duration': const Duration(minutes: 45), 'icon': Icons.looks_4, 'color': Colors.pink.shade400},
      {'label': '1h', 'duration': const Duration(hours: 1), 'icon': Icons.timer, 'color': AppColors.warning},
      {'label': '2h', 'duration': const Duration(hours: 2), 'icon': Icons.timer, 'color': AppColors.error},
    ];
  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${twoDigits(h)}:${twoDigits(m)}:${twoDigits(s)}';
    }
    return '${twoDigits(m)}:${twoDigits(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);


    final displayDuration = timerState.remaining == Duration.zero
        ? timerState.selectedDuration
        : timerState.remaining;
    
    final isLowTime = timerState.isRunning && timerState.remaining.inSeconds < 10;
    final progress = timerState.selectedDuration.inSeconds > 0
        ? (timerState.remaining.inSeconds / timerState.selectedDuration.inSeconds)
        : 1.0;



    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Timer',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (timerState.isRunning)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Running',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // Timer Display with Progress Ring
            Expanded(
              flex: 2,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background Circle
                    Container(
                      width: 80.sw,
                      height: 80.sh,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceDark,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                    
                    // Progress Ring (using LinearProgressIndicator wrapped in Circular)
                    SizedBox(
                      width: 60.sw,
                      height: 60.sh,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.containerBg,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLowTime ? AppColors.error : AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    
                    // Timer Text with Animation
                    AnimatedScale(
                      scale: timerState.isRunning ? _scaleAnimation.value : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatDuration(displayDuration),
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: isLowTime ? AppColors.error : AppColors.textPrimary,
                              letterSpacing: 2,
                            ),
                          ),
                          if (timerState.isRunning && !isLowTime)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              width: 40,
                              height: 2,
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary.withValues(alpha:0.3),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Control Buttons
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!timerState.isRunning)
                    _buildControlButton(
                      icon: Icons.play_arrow,
                      label: 'Start',
                      color: AppColors.success,
                      onPressed:  ref.read(timerProvider.notifier).start,
                      isPrimary: true,
                    ),
                  if (timerState.isRunning)
                    _buildControlButton(
                      icon: Icons.pause,
                      label: 'Pause',
                      color: AppColors.warning,
                      onPressed:  ref.read(timerProvider.notifier).pause,
                      isPrimary: true,
                    ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: Icons.stop,
                    label: 'Reset',
                    color: AppColors.error,
                    onPressed:  ref.read(timerProvider.notifier).reset,
                    isPrimary: false,
                  ),
                ],
              ),
            ),
            
            // Presets Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 12),
                    child: Text(
                      'Quick Presets',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: presets.length,
                    itemBuilder: (context, index) {
                      final preset = presets[index];
                      final isSelected = timerState.selectedDuration == preset['duration'];
                      final presetColor = preset['color'] as Color;
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    presetColor,
                                    presetColor.withValues(alpha: .7),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: AppColors.textDisabled.withValues(alpha: .2),
                                  width: 1,
                                ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: presetColor.withValues(alpha: .3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>  ref.read(timerProvider.notifier).selectPreset(preset['duration'] as Duration),
                            borderRadius: BorderRadius.circular(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  preset['icon'] as IconData,
                                  color: isSelected ? AppColors.textPrimary : presetColor,
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  preset['label'].toString(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceDark,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onPressed,
                icon: Icon(icon, color: color, size: 32),
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(),
              ),
            ),
    );
  }
}