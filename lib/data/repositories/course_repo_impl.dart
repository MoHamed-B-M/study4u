import 'dart:async';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/local_storage.dart';
import '../../shared/models/models.dart' as shared_models;

class CourseRepositoryImpl implements CourseRepository {
  @override
  List<CourseEntity> getCourses() {
    return LocalStorage.coursesBox.values.map(_toEntity).toList();
  }

  @override
  CourseEntity? getCourse(String id) {
    final course = LocalStorage.coursesBox.get(id);
    return course != null ? _toEntity(course) : null;
  }

  @override
  void addCourse(CourseEntity entity) {
    final model = _fromEntity(entity);
    LocalStorage.coursesBox.put(model.id, model);
  }

  @override
  void updateCourse(CourseEntity entity) {
    final model = _fromEntity(entity);
    LocalStorage.coursesBox.put(model.id, model);
  }

  @override
  void deleteCourse(String id) {
    LocalStorage.coursesBox.delete(id);
  }

  @override
  Stream<List<CourseEntity>> watchCourses() {
    return LocalStorage.coursesBox.watch().map((_) => getCourses());
  }

  List<String> _parseWeekDays(String json) {
    try {
      final trimmed = json.trim();
      if (trimmed.isEmpty || trimmed == '[]') return [];
      // Handles "[Mon, Tue]" or JSON array format
      final cleaned = trimmed.replaceAll('[', '').replaceAll(']', '').trim();
      if (cleaned.isEmpty) return [];
      return cleaned
          .split(',')
          .map((e) => e.trim().replaceAll('"', '').replaceAll("'", ''))
          .where((e) => e.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  CourseEntity _toEntity(shared_models.Course m) {
    return CourseEntity(
      id: m.id,
      code: m.code,
      name: m.name,
      room: m.room,
      professor: m.professor,
      startTime: m.startTime,
      endTime: m.endTime,
      colorValue: m.colorValue,
      targetGrade: m.targetGrade,
      currentGrade: m.currentGrade,
      creditHours: m.creditHours,
      scheduleJson: m.scheduleJson,
      weekDays: _parseWeekDays(m.scheduleJson),
    );
  }

  shared_models.Course _fromEntity(CourseEntity e) {
    return shared_models.Course(
      id: e.id,
      code: e.code,
      name: e.name,
      room: e.room,
      professor: e.professor,
      startTime: e.startTime,
      endTime: e.endTime,
      colorValue: e.colorValue,
      targetGrade: e.targetGrade,
      currentGrade: e.currentGrade,
      creditHours: e.creditHours,
      scheduleJson: e.scheduleJson,
    );
  }
}
