class PomodoroSessionEntity {
  final String id;
  final String? courseId;
  final int durationSeconds;
  final DateTime timestamp;
  final bool completed;

  PomodoroSessionEntity({
    required this.id,
    this.courseId,
    required this.durationSeconds,
    required this.timestamp,
    this.completed = true,
  });
}
