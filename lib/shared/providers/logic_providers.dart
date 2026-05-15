import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'package:uuid/uuid.dart';

// Providers for Hive Boxes
final coursesBoxProvider = Provider<Box<Course>>((ref) => Hive.box<Course>('courses'));
final tasksBoxProvider = Provider<Box<StudyTask>>((ref) => Hive.box<StudyTask>('tasks'));
final attendanceBoxProvider = Provider<Box<AttendanceRecord>>((ref) => Hive.box<AttendanceRecord>('attendance'));

// Course List Notifier
class CourseListNotifier extends StateNotifier<List<Course>> {
  final Box<Course> _box;
  CourseListNotifier(this._box) : super(_box.values.toList());

  void addCourse(Course course) {
    _box.put(course.id, course);
    state = _box.values.toList();
  }

  void deleteCourse(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }
}

final courseListProvider = StateNotifierProvider<CourseListNotifier, List<Course>>((ref) {
  return CourseListNotifier(ref.watch(coursesBoxProvider));
});

// Task Manager Notifier
class TaskManagerNotifier extends StateNotifier<List<StudyTask>> {
  final Box<StudyTask> _box;
  TaskManagerNotifier(this._box) : super(_box.values.toList());

  void addTask(String title, DateTime dueDate, TaskUrgency urgency) {
    final task = StudyTask(
      id: const Uuid().v4(),
      title: title,
      dueDate: dueDate,
      urgency: urgency,
    );
    _box.put(task.id, task);
    state = _box.values.toList();
  }

  void toggleTask(String id) {
    final task = _box.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.save();
      state = _box.values.toList();
    }
  }

  void deleteTask(String id) {
    _box.delete(id);
    state = _box.values.toList();
  }
}

final taskManagerProvider = StateNotifierProvider<TaskManagerNotifier, List<StudyTask>>((ref) {
  return TaskManagerNotifier(ref.watch(tasksBoxProvider));
});

// Attendance Tracker Notifier
class AttendanceTrackerNotifier extends StateNotifier<List<AttendanceRecord>> {
  final Box<AttendanceRecord> _box;
  AttendanceTrackerNotifier(this._box) : super(_box.values.toList());

  void markAttendance(String courseId, DateTime date, AttendanceStatus status) {
    final id = '${courseId}_${date.year}${date.month}${date.day}';
    final record = AttendanceRecord(
      id: id,
      courseId: courseId,
      date: date,
      status: status,
    );
    _box.put(id, record);
    state = _box.values.toList();
  }
  
  double getAttendancePercentage() {
    if (state.isEmpty) return 0;
    final presentCount = state.where((r) => r.status == AttendanceStatus.present || r.status == AttendanceStatus.late).length;
    return (presentCount / state.length) * 100;
  }
}

final attendanceTrackerProvider = StateNotifierProvider<AttendanceTrackerNotifier, List<AttendanceRecord>>((ref) {
  return AttendanceTrackerNotifier(ref.watch(attendanceBoxProvider));
});
