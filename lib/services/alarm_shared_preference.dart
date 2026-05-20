import 'package:shared_preferences/shared_preferences.dart';

const ringing = 'ringing';
const snooze = 'snooze';

class AlarmSharedPrefs {
  static late SharedPreferences _sharedPreferences;
  static Future<void> initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();

    await removeAllState();
  }
  static bool get isRingingState {
    return _sharedPreferences.getInt(ringing) != null;
  }
  static bool get isSnoozeState {
    return _sharedPreferences.getInt(snooze) != null;
  }

  static Future<void> preferencesReload() async {
    await _sharedPreferences.reload();
  }

  static Future<void> setAlarmState(String state, int id) async {
    await _sharedPreferences.setInt(state, id);
  }

  static int get getSnoozeId {
    return _sharedPreferences.getInt(snooze) ?? 0;
  }

  static int get getRingingId {
    return _sharedPreferences.getInt(ringing) ?? 0;
  }

  static Future<void> removeRinging() async {
    await _sharedPreferences.remove(ringing);
  }

  static Future<void> removeSnooze() async {
    await _sharedPreferences.remove(snooze);
  }
   static Future<void> removeAllState() async {
    await _sharedPreferences.clear();
  }
}
