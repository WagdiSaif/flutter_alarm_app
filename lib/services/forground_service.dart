// import 'dart:convert';

// import 'package:alarmapp/services/alarm_service.dart';
// import 'package:alarmapp/services/alarm_storage.dart';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// import 'package:just_audio/just_audio.dart';

// @pragma('vm:entry-point')
// void startAlarmService() {
//   FlutterForegroundTask.setTaskHandler(AlarmTaskHandler());
// }
// class AlarmTaskHandler extends TaskHandler {
//   late AudioPlayer _player;
//   int? _alarmId;
//   bool _isPlaying = false;
//   bool _isInitialized = false;

//   @override
//   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
//     debugPrint('🎵 AlarmTaskHandler onStart CALLED! Timestamp: $timestamp');
    
//     try {  await  AlarmStorage.init();
//       // ✅ FIX: Use SharedPreferences directly
//       final prefs =AlarmStorage.sharedPreferences;
//       final alarmDataString = prefs.getString('current_alarm');
//       debugPrint('Retrieved alarm data string: $alarmDataString');
      
//       if (alarmDataString != null) {
//         final data = jsonDecode(alarmDataString) as Map<String, dynamic>;
//         _alarmId = data['alarmId'] as int?;
//         final soundPath = data['soundPath'] as String? ?? 'default';
//         final title = data['title'] as String? ?? 'Alarm';
        
//         debugPrint('✅ Using alarm: ID=$_alarmId, sound=$soundPath, title=$title');
        
//         // Configure audio session for alarm
//         final session = await AudioSession.instance;
//         await session.configure(const AudioSessionConfiguration(
//           avAudioSessionCategory: AVAudioSessionCategory.playback,
//           avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
//           avAudioSessionMode: AVAudioSessionMode.defaultMode,
//           androidAudioAttributes: AndroidAudioAttributes(
//             contentType: AndroidAudioContentType.sonification,
//             flags: AndroidAudioFlags.none,
//             usage: AndroidAudioUsage.alarm,
//           ),
//           androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
//         ));

//         // Initialize player
//         _player = AudioPlayer();
        
//         // Set to loop continuously
//         await _player.setLoopMode(LoopMode.one);
//         await _player.setVolume(1.0);
        
//         // Try to load the sound
    
//           // Use the actual soundPath from alarm data
//           String assetPath = 'assets/sounds/$soundPath.mp3';
//           debugPrint('Loading sound: $assetPath');
//           await _player.setAsset(assetPath);
//           await _player.play();
//           _isPlaying = true;
//           debugPrint('🔊 Continuous sound started for alarm $_alarmId');
       
//       } else {
//         debugPrint('❌ No alarm data found in SharedPreferences');
//       }
//     } catch (e, stack) {
//       debugPrint('❌ Error in AlarmTaskHandler.onStart: $e\n$stack');
//     }
//   }

//   @override
//   void onReceiveData(Object data) {
//     debugPrint('Received data: $data');
//     if (data == "stop") {
//       _stopAlarm();
//     }
//   }

//   @override
//   Future<void> onNotificationButtonPressed(String id) async {
//     debugPrint('Button pressed: $id');
    
//     if (id == 'stop') {
//       await _stopAlarm();
//       await FlutterForegroundTask.stopService();
      
//       // Clear the alarm data
//            final prefs =AlarmStorage.sharedPreferences;
//       await prefs.remove('current_alarm');
      
//       if (_alarmId != null) {
//         final service = AlarmNotificationService();
//         await service.disableAlarm(_alarmId!);
//       }
      
//     } else if (id == 'snooze') {
//       await _stopAlarm();
//       await FlutterForegroundTask.stopService();
      
//       // Clear the alarm data
//           final prefs =AlarmStorage.sharedPreferences;
//       await prefs.remove('current_alarm');
      
//       if (_alarmId != null) {
//         final snoozeId = _alarmId! + 10000;
//         AndroidAlarmManager.oneShot(
//           const Duration(minutes: 5),
//           snoozeId,
//           snoozeAlarmCallback,
//           exact: true,
//           wakeup: true,
//           allowWhileIdle: true,
//           params: {'alarmId': _alarmId},
//         );
//       }
//     }
//   }

//   Future<void> _stopAlarm() async {
//     if (_isPlaying) {
//       await _player.stop();
//       await _player.dispose();
//       _isPlaying = false;
//       debugPrint('🛑 Alarm stopped');
//     }
//   }

//   @override
//   Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
//     debugPrint('AlarmTaskHandler destroyed');
//     await _stopAlarm();
//   }

//   @override
//   void onRepeatEvent(DateTime timestamp) {
//     // Not needed
//   }
// }