import 'dart:developer';

import 'package:alarmapp/core/app_theme/app_texts_styles.dart';
import 'package:alarmapp/core/constant/constant.dart';
import 'package:alarmapp/core/app_theme/app_colors.dart';
import 'package:alarmapp/ui/add_alarm_screen.dart';
import 'package:path/path.dart' as path;

import 'package:alarmapp/providers/alarm_sound_player.dart';
import 'package:alarmapp/sizer.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final filePathProvider = StateProvider<String?>((ref) => null);
final soundsStreamProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(alarmControllerProvider).streamSounds,
);

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

  String? fileName;

  Future<void> _loadSoundFromDevice() async {
    try {
      final pickFile = await FilePicker.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (pickFile != null) {
        final filePth = pickFile.files.single;

        ref.read(filePathProvider.notifier).state = filePth.path;
        if (filePth.path != null) {
          await ref.read(alarmControllerProvider).addSound(filePth.path!);
        }
      }
    } catch (e,stack) {
      log(e.toString(),stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSound = ref.watch(selectedSoundPathProvider);
    final (currentSoundPlayer, isPlayingSound) = ref.watch(
      alarmSoundPlayerProvider,
    );
    final streamSounds = ref.watch(soundsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Alarm Sound'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            // Stop any playing sound and close without saving
            await ref.read(alarmSoundPlayerProvider.notifier).stop();
            if (context.mounted) {
              Navigator.pop(context, selectedSound);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(alarmSoundPlayerProvider.notifier).stop();
              if (context.mounted) {
                Navigator.pop(context, selectedSound);
              }
            },
            child: const Text("Done"),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [

            InkWell(
              onTap: () async {
                await _loadSoundFromDevice();
              },
              child: Container(
                height: 8.sh,
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(),
                  color: AppColors.surfaceDark,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      height: 7.sh,
                      width: 7.sh,

                      child: Icon(Icons.add, size: 32),
                    ),
                    SizedBox(width: 20),

                    Text(
                      'Add New',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //user Sound
            _buildSoundsSource(source: 'Your Sounds'),
            ...streamSounds.when(
              data: (data) => data.map((sound) {
                final soundEntry = {
                  path.basenameWithoutExtension(sound['path']): sound['path'],
                }.entries.single;
                bool isSelectedPlayer =
                    currentSoundPlayer != null &&
                    currentSoundPlayer == soundEntry.value;

                return _buildSoundBody(
                  isSelectedPlayer,
                  isPlayingSound,
                  soundEntry,
                  selectedSound,
                  soundId: sound['id'],
                );
              }).toList(),
              loading: () => [SizedBox()],
              error: (error, stackTrace) => [SizedBox()],
            ),

            //device sound
        
            _buildSoundsSource(source: 'Device Sounds'),
            ...AppConstants.alarmSoundsPaths.entries.map((alarmSound) {
              bool isSelectedPlayer =
                  currentSoundPlayer != null &&
                  currentSoundPlayer == alarmSound.value;

              return _buildSoundBody(
                isSelectedPlayer,
                isPlayingSound,
                alarmSound,
                selectedSound,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundBody(
    bool isSelectedPlayer,
    bool isPlayingSound,
    MapEntry<String, dynamic> alarmSound,
    String selectedSound, {
    int? soundId,
  }) {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.containerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelectedPlayer
              ? AppColors.primaryBlue
              : AppColors.containerBgPale95,
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
                  ? AppColors.success
                  : AppColors.primaryBlue,
            ),
            onPressed: () async {
              final player = ref.read(alarmSoundPlayerProvider.notifier);

              ref.read(selectedSoundPathProvider.notifier).state =
                  alarmSound.value;
              if (isPlayingSound) {
                await player.stop();
              } else {
                if (soundId != null) {
                  await player.playDeviceSound(alarmSound.value);
                } else {
                  await player.playAssetSound(alarmSound.value);
                }
              }
            },
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  alarmSound.key,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  alarmSound.key,
                  style: TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ),
          ),

          RadioGroup<String>(
            onChanged: (value) {
              if (value != null) {
                ref.read(selectedSoundPathProvider.notifier).state = value;
              }
            },
            groupValue: selectedSound,
            child: Radio<String>(
              toggleable: true,
              enabled: true,
              fillColor: WidgetStatePropertyAll(AppColors.primaryBlueLight),

              value: alarmSound.key,
            ),
          ),
          soundId != null
              ? PopupMenuButton(
                  position: PopupMenuPosition.under,
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(16),
                  ),

                  tooltip: 'Remove Sound',

                  borderRadius: BorderRadius.circular(16),

                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () async {
                        await ref
                            .read(alarmControllerProvider)
                            .deleteSound(soundId);
                      },

                      child: Text('Remove'),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildSoundsSource({required String source}) {
    return Container(
      height: 8.sh,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(),
        color: AppColors.cardBg,
      ),
      child: Row(children: [Text(source, style: AppTextStyles.headlineSmall)]),
    );
  }
}
