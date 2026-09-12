import 'dart:developer';

import 'package:audio_session/audio_session.dart';

import 'package:just_audio/just_audio.dart';

class AudioHandler {
  final AudioPlayer _audioPlayer;

  AudioSession? _audioSession;

  AudioHandler({required this._audioPlayer});

  Future<void> initAudioSource() async {
    try {
      _audioSession = await AudioSession.instance;
      _audioSession!.configure(
        AudioSessionConfiguration(
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.mixWithOthers,
          avAudioSessionCategory: AVAudioSessionCategory.playback,

          androidAudioAttributes: AndroidAudioAttributes(
            usage: AndroidAudioUsage.media,
            contentType: AndroidAudioContentType.sonification,
          ),
          androidWillPauseWhenDucked: false,
        ),
      );
      await _audioSession!.setActive(true);
      await _audioPlayer.setVolume(0.7);
      await _audioPlayer.setAsset('assets/sounds/default.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
    } catch (e, stackTrace) {
      log(
        'Failed to Initialize Audio Service',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  bool get isPlaying => _audioPlayer.playing;
  Future<void> startPlayer() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      log('Audio Player Failed $e');
    }
  }

  Future<void> stopPlayer() async {
    await _audioPlayer.stop();
  }

  Future<void> dispose() async {
    try {
      _audioSession?.setActive(false);
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
    } catch (e) {
      log('Failed to stop an Player $e');
    }
  }
}
