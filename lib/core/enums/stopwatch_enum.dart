enum StopwatchButtonAction {
  pause,
  start,
  lap,
  reset,
  unknown;

  factory StopwatchButtonAction.byname(String name) {
    return StopwatchButtonAction.values.firstWhere(
      (result) => result.name.toLowerCase() == name.toLowerCase(),
      orElse: () => StopwatchButtonAction.unknown,
    );
  }
  String get label {
    return switch (this) {
      StopwatchButtonAction.pause => 'Pause',
      StopwatchButtonAction.start => 'Start',
      StopwatchButtonAction.lap => 'Lap',
      StopwatchButtonAction.reset => 'Reset',
      StopwatchButtonAction.unknown => 'Unknown',
    };
  }
}
