import 'package:alarmapp/core/app_theme/app_colors.dart';
import 'package:alarmapp/core/app_theme/app_texts_styles.dart';
import 'package:alarmapp/core/enums/timer_enum.dart';
import 'package:alarmapp/core/utils/functions.dart';
import 'package:alarmapp/data/models/timer_state.dart';
import 'package:alarmapp/providers/timer_notifier.dart';
import 'package:alarmapp/sizer.dart';
import 'package:alarmapp/ui/widgets/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

NotifierProvider<TimerNotifier, TimerState> timerStateProvider =
    NotifierProvider<TimerNotifier, TimerState>(() => TimerNotifier());

class TimerPresetScreeen extends ConsumerStatefulWidget {
  const TimerPresetScreeen({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TimerPreset();
}

class _TimerPreset extends ConsumerState<TimerPresetScreeen>
    with SingleTickerProviderStateMixin {
  static const presetTime = [
    {'duration': Duration(minutes: 1), 'icon': Icons.looks_one},

    {'duration': Duration(minutes: 3), 'icon': Icons.looks_3},
    {'duration': Duration(minutes: 2), 'icon': Icons.looks_two},
    {'duration': Duration(minutes: 5), 'icon': Icons.looks_5},
    {'duration': Duration(minutes: 15), 'icon': Icons.looks},
    {'duration': Duration(minutes: 30), 'icon': Icons.looks_3},
    {'duration': Duration(minutes: 45), 'icon': Icons.looks_4},
    {'duration': Duration(hours: 2), 'icon': Icons.alarm},
    {'duration': Duration(hours: 1), 'icon': Icons.alarm},
  ];

  String _extractDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final hours = duration.inHours.remainder(60);

    return hours >= 1 ? '${hours}h' : '${minutes}m';
  }

  late AnimationController _animationController;

  late Animation<double> scaleAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(microseconds: 800),
    )..repeat(reverse: true);

    scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    super.initState();
  }

  Duration prograassDuration = Duration.zero;
  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerStateProvider);

    double progressValue =
        timerState.currentDuration.inSeconds ==
            timerState.startedDuration.inSeconds
        ? 0.0
        : timerState.currentDuration.inSeconds /
              timerState.startedDuration.inSeconds;

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Timer',
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontSize: 3.sh,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                //
                if (timerState.timerButtonAction == TimerButtonAction.resume)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
          const SizedBox(height: 15),
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                AnimatedScale(
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 300),
                  scale:
                      timerState.timerButtonAction == TimerButtonAction.resume
                      ? scaleAnimation.value
                      : 1.0,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: AppColors.containerBg, blurRadius: 2),
                      ],
                      color: AppColors.containerBg,
                      borderRadius: BorderRadius.circular(28.sh),
                    ),

                    height: 52.sw,

                    width: 52.sw,

                    child: Text(
                      formatTimerDuration(timerState.currentDuration),
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 6.sw,
                      ),
                    ),
                  ),
                ),

                Container(
                  height: 53.sw,

                  width: 53.sw,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26.sh),
                  ),

                  child: CircularProgressIndicator(
                    strokeWidth: 7,
                    color: AppColors.primaryBlue,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue,
                    ),
                    value: progressValue < 0 ? 0.0 : progressValue,
                  ),
                ),
              ],
            ),
          ),

          Container(
            alignment: Alignment.center,

            padding: const EdgeInsets.symmetric(vertical: 12),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                (progressValue < 0 &&
                        timerState.timerButtonAction ==
                            TimerButtonAction.resume)
                    ? CustomElevatedButton(
                        color: AppColors.primaryBlue,
                        icon: Icons.add,
                        labelText: 'Add One minute',
                        onPressed: () {
                          ref.read(timerStateProvider.notifier).addOneMinute();
                        },
                      )
                    : CustomElevatedButton(
                        color: AppColors.primaryBlue,
                        icon:
                            timerState.timerButtonAction ==
                                TimerButtonAction.resume
                            ? Icons.pause
                            : Icons.play_arrow,
                        labelText:
                            timerState.timerButtonAction ==
                                TimerButtonAction.resume
                            ? 'Pause'
                            : 'Start',
                        onPressed: () {
                          timerState.timerButtonAction ==
                                  TimerButtonAction.resume
                              ? ref.read(timerStateProvider.notifier).pause()
                              : ref.read(timerStateProvider.notifier).start();
                        },
                      ),

                CustomElevatedButton(
                  icon: Icons.stop,
                  onPressed: () =>
                      ref.read(timerStateProvider.notifier).reset(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Padding(
                  padding: const EdgeInsets.all(12),

                  child: Text('Quick Presets'),
                ),

                GridView.builder(
                  padding: const EdgeInsets.all(12),

                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 12,
                  ),

                  itemCount: presetTime.length,
                  itemBuilder: (context, index) {
                    final data = presetTime[index];
                    final duration = data['duration'] as Duration;
                    final iconData = data['icon'] as IconData;
                    final selected = timerState.startedDuration == duration;
                    final durationStr = _extractDuration(duration);

                    return Container(
                      decoration: BoxDecoration(
                        gradient: selected
                            ? LinearGradient(
                                begin: AlignmentGeometry.centerLeft,
                                end: AlignmentGeometry.bottomRight,
                                colors: [
                                  AppColors.primaryBlue,
                                  AppColors.primaryBlueLight,
                                ],
                              )
                            : null,

                        color: AppColors.containerBg,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.containerBg.withValues(
                                    alpha: .3,
                                  ),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),

                      child: InkWell(
                        onTap: () {
                          final timerState = ref.read(
                            timerStateProvider.notifier,
                          );
                          timerState.reset();
                          timerState.selectPreset(duration);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(iconData), Text(durationStr)],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}
