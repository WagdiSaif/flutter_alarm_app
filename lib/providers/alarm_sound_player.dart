import 'dart:developer';

import 'package:audio_session/audio_session.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:just_audio/just_audio.dart';

class AlarmSoundPlayer extends AutoDisposeNotifier<(String?, bool)> {
  @override
  (String?, bool) build() {
    _player = AudioPlayer();

    ref.onDispose(() async {
      try {
        state = (state.$1, false);
        final session = await AudioSession.instance;
        await session.setActive(false);
      } catch (e) {
        log(e.toString());
      }
      _player?.dispose();
    });
    return (null, false);
  }

  AudioPlayer? _player;

  Future<void> playSound(
    String selectedSound, {
    required bool isAssetPath,
  }) async {
    try {
      await stop();
      _player ??= AudioPlayer();
      state = (selectedSound, true);

      final path = selectedSound;

      await _player?.setLoopMode(LoopMode.all);
      await _player?.setVolume(1.0);
      if (isAssetPath) {
        await _player?.setAsset(path);
      } else {
        await _player?.setFilePath(path);
      }

      await _player?.play();
    } catch (e) {
      _player = null;
      state = (null, false);
    }
  }

  Future<void> initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        androidAudioAttributes: AndroidAudioAttributes(
          usage: AndroidAudioUsage.media,
          contentType: AndroidAudioContentType.music,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
      ),
    );

    await session.setActive(true);
  }

  Future<void> stop() async {
    try {
      state = (state.$1, false);
      if (_player != null) {
        await _player!.stop();
      }
    } catch (_) {
      _player = null;
    }
  }
}
