import '../entities/course.dart';

class UpNextResult {
  final CourseEntity? course;
  final bool hasNext;

  const UpNextResult({this.course, required this.hasNext});
}

class ScheduleOptimizerUseCase {
  UpNextResult execute(List<CourseEntity> courses) {
    if (courses.isEmpty) return const UpNextResult(hasNext: false);

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    CourseEntity? nextCourse;
    for (final course in courses) {
      final start = course.startTime;
      if (_timeToMinutes(start) > _timeToMinutes(currentTime)) {
        if (nextCourse == null ||
            _timeToMinutes(start) < _timeToMinutes(nextCourse.startTime)) {
          nextCourse = course;
        }
      }
    }

    nextCourse ??= courses.first;
    return UpNextResult(course: nextCourse, hasNext: true);
  }

  int _timeToMinutes(String time) {
    final parts = time.split(RegExp(r'[: ]'));
    if (parts.length < 3) return 0;
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final isPM = parts[2].toUpperCase() == 'PM';
    final h = isPM && hours != 12 ? hours + 12 : (!isPM && hours == 12 ? 0 : hours);
    return h * 60 + minutes;
  }
}
