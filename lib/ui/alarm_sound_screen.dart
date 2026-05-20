
import 'package:alarmapp/core/app_theme/app_theme.dart';
import 'package:alarmapp/helper/constants.dart';
import 'package:alarmapp/core/app_theme/app_colors.dart';



import 'package:alarmapp/services/alarm_sound_player.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final selectedSoundPathProvider = StateProvider<String>(
  (ref) => AppConstants.defaultSound,
);

final alarmSoundPlayerProvider =
    StateNotifierProvider<AlarmSoundPlayer, (String?, bool)>(
      (ref) => AlarmSoundPlayer(),
    );

class AlarmSoundScreen extends ConsumerStatefulWidget {
  final String alarmSound;
  const AlarmSoundScreen(this.alarmSound, {super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AlarmSoundScreen();
}

class _AlarmSoundScreen extends ConsumerState<AlarmSoundScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedSoundPathProvider.notifier).state = widget.alarmSound;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedSound = ref.watch(selectedSoundPathProvider);
    final (currentSoundPlayer, isPlayingSound) = ref.watch(
      alarmSoundPlayerProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Alarm Sound'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Stop any playing sound and close without saving
            ref.read(alarmSoundPlayerProvider.notifier).stop();
            Navigator.pop(context, selectedSound);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {

              ref.read(alarmSoundPlayerProvider.notifier).stop();
              Navigator.pop(context, selectedSound);
            },
            child: const Text("Done"),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children:AppConstants.alarmSoundsPaths.entries.map((alarmSound) {
            bool isSelectedPlayer =
                currentSoundPlayer != null &&
                currentSoundPlayer == alarmSound.value;

            return Container(
              padding: const EdgeInsets.all(6),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.containerBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedSound == alarmSound.value
                      ? Colors.blue
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  /// Play / Stop button
                  IconButton(
                    iconSize: 32,
                    icon: Icon(
                      isSelectedPlayer && isPlayingSound
                          ? Icons.stop_circle
                          : Icons.play_circle_fill,
                      color: isSelectedPlayer && isPlayingSound
                          ? Colors.green
                          : Colors.blue,
                    ),
                    onPressed: () async {
                      final player = ref.read(
                        alarmSoundPlayerProvider.notifier,
                      );

                      ref.read(selectedSoundPathProvider.notifier).state =
                          alarmSound.value;
                      if (isPlayingSound) {
                        await player.stop();
                      } else {
                        await player.play(alarmSound.value);
                      }
                    },
                  ),
                  const SizedBox(width: 12),

          
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alarmSound.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          alarmSound.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  RadioGroup<String>(
                    onChanged: (value) {
         
                        ref.read(selectedSoundPathProvider.notifier).state =
                            value!;
         
                    },
                    groupValue: selectedSound,
                    child: Radio<String>(
                      toggleable: true,
                      enabled: true,
                      fillColor: WidgetStatePropertyAll(
                        AppColors.primaryBlueLight,
                      ),

                      value: alarmSound.key,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}


