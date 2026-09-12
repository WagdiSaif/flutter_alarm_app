import 'package:alarmapp/core/app_theme/app_colors.dart';
import 'package:alarmapp/core/app_theme/app_texts_styles.dart';
import 'package:alarmapp/core/enums/stopwatch_enum.dart';
import 'package:alarmapp/core/utils/functions.dart';
import 'package:alarmapp/data/models/stopwatch_state.dart';
import 'package:alarmapp/providers/stopwatch_notifier.dart';
import 'package:alarmapp/sizer.dart';
import 'package:alarmapp/ui/widgets/elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stopwatchStateProvider =
    NotifierProvider<StopwatchNotifier, StopwatchState>(
      () => StopwatchNotifier(),
    );

class StopwatchScreen extends ConsumerStatefulWidget {
  const StopwatchScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StopwatchScreen();
}

class _StopwatchScreen extends ConsumerState<StopwatchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animatedScale;
  late ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animatedScale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stopwatchState = ref.watch(stopwatchStateProvider);

    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(top: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                'StopWatch',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: AnimatedScale(
                  scale:
                      stopwatchState.stopwatchButtonAction ==
                          StopwatchButtonAction.start
                      ? _animatedScale.value
                      : 1.0,
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 100),
                  child: Container(
                    height: 62.sw,
                    width: 62.sw,
                    alignment: Alignment.center,

                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.containerBg, AppColors.cardBg],
                        begin: AlignmentGeometry.topLeft,
                        end: AlignmentGeometry.bottomRight,
                      ),

                      borderRadius: BorderRadius.circular(32.sw),
                    ),

                    child: Text(
                      formatStopwatchDuration(stopwatchState.currentDuration),
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontSize: 8.sw,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (stopwatchState.laps.isNotEmpty)
              SizedBox(
                height: 20.sh,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 5.sh,
                        child: stopwatchState.laps.length >= 4
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,

                                children: [
                                  CustomElevatedButton(
                                    iconColor: AppColors.whiteColor,
                                    color: AppColors.cardBg,
                                    icon: Icons.arrow_left_sharp,
                                    onPressed: () {
                                      _checkAndSnap(scrollRight: false);
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  CustomElevatedButton(
                                    iconColor: AppColors.whiteColor,
                                    color: AppColors.containerBg,
                                    icon: Icons.arrow_right_sharp,
                                    onPressed: () {
                                      _checkAndSnap(scrollRight: true);

                                      // });
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),

                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 4.sw),
                          scrollDirection: Axis.horizontal,

                          itemCount: stopwatchState.laps.length,
                          controller: _scrollController,
                          itemBuilder: (cotext, index) {
                            final lap = stopwatchState.laps[index];
                            if (index == 0) {
                              return Center(
                                child: SizedBox(
                                  height: 11.sh,
                                  width: 27.sw,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.containerBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.textDisabled,
                                      ),
                                    ),

                                    child: Column(
                                      children: [
                                        Text(
                                          (index + 1).toString(),
                                          style: TextStyle(fontSize: 3.5.sw),
                                        ),
                                        Text(
                                          formatStopwatchDuration(
                                            lap.previousLapElapsed,
                                          ),
                                          style: TextStyle(fontSize: 3.2.sw),
                                        ),
                                        Text(
                                          formatStopwatchDuration(
                                            lap.currentLapElapsed,
                                          ),
                                          style: TextStyle(fontSize: 3.2.sw),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Center(
                              child: SizedBox(
                                height: 11.sh,
                                width: 27.sw,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.containerBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.textDisabled,
                                    ),
                                  ),

                                  child: Column(
                                    children: [
                                      Text(
                                        (index + 1).toString(),
                                        style: TextStyle(fontSize: 3.5.sw),
                                      ),
                                      Text(
                                        index + 1 == stopwatchState.laps.length
                                            ? formatStopwatchDuration(
                                                stopwatchState
                                                    .laps
                                                    .last
                                                    .previousLapElapsed,
                                              )
                                            : formatStopwatchDuration(
                                                lap.previousLapElapsed,
                                              ),
                                        style: TextStyle(fontSize: 3.2.sw),
                                      ),
                                      Text(
                                        index + 1 == stopwatchState.laps.length
                                            ? formatStopwatchDuration(
                                                stopwatchState.currentDuration,
                                              )
                                            : formatStopwatchDuration(
                                                lap.currentLapElapsed,
                                              ),
                                        style: TextStyle(fontSize: 3.2.sw),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  CustomElevatedButton(
                    color: AppColors.primaryBlue,
                    icon:
                        stopwatchState.stopwatchButtonAction ==
                            StopwatchButtonAction.start
                        ? Icons.stop
                        : Icons.play_arrow,
                    labelText:
                        stopwatchState.stopwatchButtonAction ==
                            StopwatchButtonAction.start
                        ? 'Stop'
                        : 'Start',
                    onPressed: () {
                      stopwatchState.stopwatchButtonAction ==
                              StopwatchButtonAction.start
                          ? ref.read(stopwatchStateProvider.notifier).stop()
                          : ref.read(stopwatchStateProvider.notifier).start();
                    },
                  ),
                  if (stopwatchState.stopwatchButtonAction ==
                      StopwatchButtonAction.start)
                    CustomElevatedButton(
                      icon: Icons.add,
                      labelText: 'Lap',
                      onPressed: () => {
                        ref.read(stopwatchStateProvider.notifier).addLap(),
                      },
                    ),
                  CustomElevatedButton(
                    icon: Icons.remove,
                    labelText: 'Reset',
                    onPressed: () =>
                        ref.read(stopwatchStateProvider.notifier).reset(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void _checkAndSnap({required bool scrollRight}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    double itemWidth = 31.sw;
    double target = 0.0;

    if (scrollRight) {
      if (position.pixels >= position.maxScrollExtent) {
        return; //we end(backToRight)
      }

      double nextIndex = (position.pixels / itemWidth)
          .ceilToDouble(); //item count

      if (nextIndex * itemWidth <= position.pixels + .5) {
        nextIndex += 1.0;
      }
      target = nextIndex * itemWidth;
    } else {
      if (position.pixels <= position.minScrollExtent) return; //we start
      double prevIndex = (position.pixels / itemWidth)
          .floorToDouble(); //item count

      if (prevIndex * itemWidth >= position.pixels - .5) {
        prevIndex -= 1.0;
      }

      target = prevIndex * itemWidth;
    }
    target = target.clamp(position.minScrollExtent, position.maxScrollExtent);
    position.moveTo(
      target,
      duration: Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}
