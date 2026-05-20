
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:just_audio/just_audio.dart';

class AlarmSoundPlayer extends StateNotifier<(String?, bool)> {
  AlarmSoundPlayer() : super((null, false));

  AudioPlayer? _player;
  Future<void> play(String selectedSound) async {
    try {
    
      await stop();
      _player = AudioPlayer();

      state = (selectedSound, true);
      await Future.delayed(const Duration(milliseconds: 100));
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          androidAudioAttributes: AndroidAudioAttributes(
            usage: AndroidAudioUsage.alarm,
            contentType: AndroidAudioContentType.sonification,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        ),
      );

      await session.setActive(true);

  
      final path = selectedSound;
      final assetPath = path;

      await _player!.setLoopMode(LoopMode.one);
      await _player!.setVolume(1.0);
      await _player!.setAsset(assetPath);

      
      await _player!.play();


    } catch (e, _) {
   
      _player = null;
      state = (null, false);
    }
  }


  Future<void> stop() async {
    try {
      state = (state.$1, false);
      if (_player != null) {
        await _player!.stop();
   
      }

      final session = await AudioSession.instance;
      await session.setActive(false);
      _player = null;

    } catch (e) {
   
     
      _player = null;
    }
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}