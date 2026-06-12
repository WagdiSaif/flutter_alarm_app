import 'dart:async';

import 'package:alarmapp/core/app_theme/app_colors.dart';
import 'package:alarmapp/core/app_theme/app_texts_styles.dart';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final stopwatchTimeProvider = StateProvider<Duration>((ref) => Duration.zero);
final stopwatchIsRunningProvider = StateProvider<bool>((ref) => false);
final stopwatchLapsProvider = StateProvider<List<Duration>>((ref) => []);

class StopwatchScreen extends ConsumerStatefulWidget {
  const StopwatchScreen({super.key});

  @override
  ConsumerState<StopwatchScreen> createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends ConsumerState<StopwatchScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
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

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }


  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    final milliseconds = (duration.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    if (duration.inHours > 0) {
      final hours = twoDigits(duration.inHours);
      return '$hours:$minutes:$seconds.$milliseconds';
    }
    return '$minutes:$seconds.$milliseconds';
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = ref.watch(stopwatchIsRunningProvider);
    final time = ref.watch(stopwatchTimeProvider);
    final laps = ref.watch(stopwatchLapsProvider);

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
                    'Stopwatch',
                    style: AppTextStyles.headlineLarge.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (laps.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        ref.read(stopwatchLapsProvider.notifier).state = [];
                      },
                      child: Text(
                        'Clear',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Timer Display
            Expanded(
              flex: 2,
              child: Center(
                child: AnimatedScale(
                  scale: isRunning ? _scaleAnimation.value : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceDark,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: .2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        formatDuration(time),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Control Buttons
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isRunning)
                    _buildControlButton(
                      icon: Icons.play_arrow,
                      label: 'Start',
                      color: AppColors.success,
                      onPressed: () {
                        ref.read(stopwatchIsRunningProvider.notifier).state = true;
                        _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
                          if (ref.read(stopwatchIsRunningProvider)) {
                            final current = ref.read(stopwatchTimeProvider);
                            ref.read(stopwatchTimeProvider.notifier).state = current + const Duration(milliseconds: 10);
                          }
                        });
                      },
                      isPrimary: true,
                    ),
                  if (isRunning)
                    _buildControlButton(
                      icon: Icons.pause,
                      label: 'Pause',
                      color: AppColors.warning,
                      onPressed: () {
                        ref.read(stopwatchIsRunningProvider.notifier).state = false;
                        _timer?.cancel();
                      },
                      isPrimary: true,
                    ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: Icons.stop,
                    label: 'Reset',
                    color: AppColors.error,
                    onPressed: () {
                      _timer?.cancel();
                      ref.read(stopwatchIsRunningProvider.notifier).state = false;
                      ref.read(stopwatchTimeProvider.notifier).state = Duration.zero;
                      ref.read(stopwatchLapsProvider.notifier).state = [];
                    },
                    isPrimary: false,
                  ),
                  const SizedBox(width: 20),
                  if (isRunning)
                    _buildControlButton(
                      icon: Icons.flag,
                      label: 'Lap',
                      color: AppColors.primaryBlue,
                      onPressed: () {
                        final current = ref.read(stopwatchTimeProvider);
                        final lapsList = ref.read(stopwatchLapsProvider);
                        ref.read(stopwatchLapsProvider.notifier).state = [...lapsList, current];
                      },
                      isPrimary: false,
                    ),
                ],
              ),
            ),
            
            // Laps Section
            if (laps.isNotEmpty)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'Laps',
                          style: AppTextStyles.titleLarge.copyWith(fontSize: 16),
                        ),
                      ),
                      const Divider(color: AppColors.textDisabled),
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          itemCount: laps.length,
                          itemBuilder: (context, index) {
                            final lap = laps[laps.length - 1 - index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Lap ${index + 1}',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  Text(
                                    formatDuration(lap),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
    return isPrimary
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
              icon: Icon(icon, color: color, size: 28),
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(),
            ),
          );
  }
}