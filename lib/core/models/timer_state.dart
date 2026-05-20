class TimerState {
  final Duration selectedDuration;
  final Duration remaining;
  final bool isRunning;

  TimerState({
    required this.selectedDuration,
    required this.remaining,
    required this.isRunning,
  });

  TimerState copyWith({
    Duration? selectedDuration,
    Duration? remaining,
    bool? isRunning,
  }) {
    return TimerState(
      selectedDuration: selectedDuration ?? this.selectedDuration,
      remaining: remaining ?? this.remaining,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}