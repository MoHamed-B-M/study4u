import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/course_repo_impl.dart';
import '../../data/repositories/task_repo_impl.dart';
import '../../data/repositories/attendance_repo_impl.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/cgpa_calculator.dart';
import '../../domain/usecases/attendance_analytics.dart';
import '../../domain/usecases/schedule_optimizer.dart';

final courseRepositoryProvider = Provider((ref) => CourseRepositoryImpl());
final taskRepositoryProvider = Provider((ref) => TaskRepositoryImpl());
final attendanceRepositoryProvider = Provider((ref) => AttendanceRepositoryImpl());
final cgpaCalculatorProvider = Provider((ref) => CgpaCalculatorUseCase());
final attendanceAnalyticsProvider = Provider((ref) => AttendanceAnalyticsUseCase());
final scheduleOptimizerProvider = Provider((ref) => ScheduleOptimizerUseCase());

final courseListProvider = Provider<List<CourseEntity>>((ref) {
  final repo = ref.watch(courseRepositoryProvider);
  return repo.getCourses();
});

final taskListProvider = Provider<List<TaskEntity>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getTasks();
});

final pendingTaskCountProvider = Provider<int>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.where((t) => !t.isCompleted).length;
});

final attendanceRecordsProvider = Provider<List<AttendanceRecordEntity>>((ref) {
  final repo = ref.watch(attendanceRepositoryProvider);
  return repo.getRecords();
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

final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
});
