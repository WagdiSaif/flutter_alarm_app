enum TimerButtonAction {
  pause,
  resume,
  addOneMinute,
  reset,
  stop,
  unknown;

  factory TimerButtonAction.byname(String name) {
    return TimerButtonAction.values.firstWhere(
      (result) => result.name.toLowerCase() == name.toLowerCase(),
      orElse: () => TimerButtonAction.unknown,
    );
  }

  String get label {
    return switch (this) {
      TimerButtonAction.pause => 'Pause',
      TimerButtonAction.stop => 'Stop',
      TimerButtonAction.reset => 'Reset',
      TimerButtonAction.resume => 'Resume',
      TimerButtonAction.addOneMinute => 'Add 1 min',
      TimerButtonAction.unknown => 'Unknown',
    };
  }
}
