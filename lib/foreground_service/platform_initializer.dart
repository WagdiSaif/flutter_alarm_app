import 'dart:io';

import 'package:alarmapp/foreground_service/android_platform/android_foreground_service.dart';
import 'package:alarmapp/foreground_service/ios_platform/ios_foreground_service.dart';

enum PlatformType { ios, android }

class PlatformInitializer {
  static PlatformInitializer? _instance;
  PlatformInitializer._internal();
  static PlatformType? _platformType;

  static PlatformInitializer get instance =>
      _instance ??= PlatformInitializer._internal();

  Future<void> initialize() async {
    if (platformType == PlatformType.android) {
      await AndroidForegroundService.initializationService();
    }
    if (platformType == PlatformType.ios) {
      await IosForegroundService.initializationService();
    }
  }

  PlatformType _checkPlatformType() {
    if (Platform.isAndroid) {
      return PlatformType.android;
    } else if (Platform.isIOS) {
      return PlatformType.ios;
    } else {
      throw UnsupportedError('Unsupported Platform Error');
    }
  }

  PlatformType get platformType => _platformType ??= _checkPlatformType();
}
