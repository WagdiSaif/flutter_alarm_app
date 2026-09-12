import 'package:shared_preferences/shared_preferences.dart';

const ringing = 'ringing';
const snooze = 'snooze';

class AlarmSharedPrefs {
  static late SharedPreferences _sharedPreferences;
  static AlarmSharedPrefs? _instance;

  AlarmSharedPrefs._();

  static AlarmSharedPrefs get instance => _instance ?? AlarmSharedPrefs._();

  Future<void> initialize() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await _sharedPreferences.remove(ringing);
    await _sharedPreferences.remove(snooze);
  }

  bool get isRingingState => _sharedPreferences.getInt(ringing) != null;

  bool get isSnoozeState => _sharedPreferences.getInt(snooze) != null;

  Future<void> reloadPreferences() => _sharedPreferences.reload();

  Future<void> setAlarmState(String state, int id) =>
      _sharedPreferences.setInt(state, id);

  int get getSnoozeId => _sharedPreferences.getInt(snooze) ?? 0;

  int get getRingingId => _sharedPreferences.getInt(ringing) ?? 0;

  Future<void> removeRinging() => _sharedPreferences.remove(ringing);

  Future<void> removeSnooze() => _sharedPreferences.remove(snooze);

  Future<void> removeAllState() async {
    await _sharedPreferences.remove(ringing);
    await _sharedPreferences.remove(snooze);
  }
}
