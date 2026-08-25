import 'dart:io';

import '../../data/platform/widget_bridge.dart';
import '../../data/repositories/course_repo_impl.dart';
import '../../data/repositories/pomodoro_repo_impl.dart';
import '../../data/repositories/task_repo_impl.dart';
import '../../domain/usecases/cgpa_calculator.dart';

/// Gathers a study snapshot from the local repositories and pushes it to the
/// Android home-screen widget. Called on app start, on resume, and whenever
/// data changes (via [dataRefreshProvider]).
class HomeWidgetService {
  HomeWidgetService._();

  static const _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static Future<void> pushUpdate() async {
    if (!Platform.isAndroid) return;
    try {
      final courses = CourseRepositoryImpl().getCourses();
      final tasks = TaskRepositoryImpl().getTasks();
      final sessions = PomodoroRepositoryImpl().getSessions();

      // Classes scheduled for today (courses without schedule show every day).
      final today = _dayNames[DateTime.now().weekday - 1];
      final todaysCourses = courses
          .where((c) => c.weekDays.isEmpty || c.weekDays.contains(today))
          .toList()
        ..sort((a, b) =>
            _timeToMinutes(a.startTime).compareTo(_timeToMinutes(b.startTime)));

      final pendingTasks = tasks.where((t) => !t.isCompleted).length;

      final now = DateTime.now();
      final focusMinutes = sessions
          .where((s) =>
              s.completed &&
              s.timestamp.year == now.year &&
              s.timestamp.month == now.month &&
              s.timestamp.day == now.day)
          .fold<int>(0, (sum, s) => sum + (s.durationSeconds ~/ 60));

      final cgpa = CgpaCalculatorUseCase().execute(courses);

      await WidgetBridge.updateWidget({
        'cgpa': cgpa.cgpa.toStringAsFixed(2),
        'letter': cgpa.letterGrade,
        'pendingTasks': pendingTasks,
        'focusMinutes': focusMinutes,
        'classes': [
          for (final c in todaysCourses)
            {
              'name': c.name,
              'room': c.room,
              'startTime': c.startTime,
              'endTime': c.endTime,
              'startMin': _timeToMinutes(c.startTime),
              'endMin': _timeToMinutes(c.endTime),
            },
        ],
      });
    } catch (_) {
      // Widget updates must never crash the app.
    }
  }

  /// Parses "h:mm AM/PM" strings into minutes since midnight.
  static int _timeToMinutes(String time) {
    final parts = time.split(RegExp(r'[: ]'));
    if (parts.length < 3) return 0;
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    final isPm = parts[2].toUpperCase() == 'PM';
    final h =
        isPm && hours != 12 ? hours + 12 : (!isPm && hours == 12 ? 0 : hours);
    return h * 60 + minutes;
  }
}
