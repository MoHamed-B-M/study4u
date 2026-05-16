import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/course_repo_impl.dart';
import '../../data/repositories/task_repo_impl.dart';
import '../../data/repositories/attendance_repo_impl.dart';
import '../../data/repositories/material_repo_impl.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/course_material.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/cgpa_calculator.dart';
import '../../domain/usecases/attendance_analytics.dart';
import '../../domain/usecases/schedule_optimizer.dart';

final courseRepositoryProvider = Provider((ref) => CourseRepositoryImpl());
final taskRepositoryProvider = Provider((ref) => TaskRepositoryImpl());
final attendanceRepositoryProvider = Provider((ref) => AttendanceRepositoryImpl());
final materialRepositoryProvider = Provider((ref) => MaterialRepositoryImpl());
final cgpaCalculatorProvider = Provider((ref) => CgpaCalculatorUseCase());
final attendanceAnalyticsProvider = Provider((ref) => AttendanceAnalyticsUseCase());
final scheduleOptimizerProvider = Provider((ref) => ScheduleOptimizerUseCase());

final dataRefreshProvider = StateProvider<int>((ref) => 0);

final courseListProvider = Provider<List<CourseEntity>>((ref) {
  ref.watch(dataRefreshProvider);
  return ref.watch(courseRepositoryProvider).getCourses();
});

final taskListProvider = Provider<List<TaskEntity>>((ref) {
  ref.watch(dataRefreshProvider);
  return ref.watch(taskRepositoryProvider).getTasks();
});

final pendingTaskCountProvider = Provider<int>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.where((t) => !t.isCompleted).length;
});

final attendanceRecordsProvider = Provider<List<AttendanceRecordEntity>>((ref) {
  ref.watch(dataRefreshProvider);
  return ref.watch(attendanceRepositoryProvider).getRecords();
});

final attendanceAnalyticsResultProvider = Provider<AttendanceAnalyticsResult>((ref) {
  final records = ref.watch(attendanceRecordsProvider);
  final usecase = ref.watch(attendanceAnalyticsProvider);
  return usecase.execute(records);
});

final cgpaResultProvider = Provider<CgpaResult>((ref) {
  final courses = ref.watch(courseListProvider);
  final usecase = ref.watch(cgpaCalculatorProvider);
  return usecase.execute(courses);
});

final upNextProvider = Provider<UpNextResult>((ref) {
  final courses = ref.watch(courseListProvider);
  final usecase = ref.watch(scheduleOptimizerProvider);
  return usecase.execute(courses);
});

final courseDetailProvider = Provider.family<CourseEntity?, String>((ref, id) {
  final courses = ref.watch(courseListProvider);
  try {
    return courses.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

final courseMaterialsProvider = Provider.family<List<CourseMaterialEntity>, String>((ref, courseId) {
  ref.watch(dataRefreshProvider);
  return ref.watch(materialRepositoryProvider).getMaterials(courseId);
});

final courseTasksProvider = Provider.family<List<TaskEntity>, String>((ref, courseId) {
  ref.watch(dataRefreshProvider);
  final all = ref.watch(taskRepositoryProvider).getTasksForCourse(courseId);
  return all.where((t) => t.type == TaskType.task).toList();
});

final courseNotesProvider = Provider.family<List<TaskEntity>, String>((ref, courseId) {
  ref.watch(dataRefreshProvider);
  final all = ref.watch(taskRepositoryProvider).getTasksForCourse(courseId);
  return all.where((t) => t.type == TaskType.note).toList();
});

final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
});
