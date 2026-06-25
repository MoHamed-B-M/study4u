import 'dart:async';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/local_storage.dart';
import '../../../shared/models/models.dart' as shared_models;

class AttendanceRepositoryImpl implements AttendanceRepository {
  @override
  List<AttendanceRecordEntity> getRecords() {
    return LocalStorage.attendanceBox.values.map(_toEntity).toList();
  }

  @override
  List<AttendanceRecordEntity> getRecordsForCourse(String courseId) {
    return LocalStorage.attendanceBox.values
        .where((r) => r.courseId == courseId)
        .map(_toEntity)
        .toList();
  }

  @override
  void markAttendance(AttendanceRecordEntity entity) {
    final model = shared_models.AttendanceRecord(
      id: entity.id,
      courseId: entity.courseId,
      date: entity.date,
      status: _toModelStatus(entity.status),
    );
    LocalStorage.attendanceBox.put(entity.id, model);
  }

  @override
  double getAttendancePercentage() {
    final records = getRecords();
    if (records.isEmpty) return 0;
    final attended = records
        .where((r) =>
            r.status == AttendanceStatus.present ||
            r.status == AttendanceStatus.late)
        .length;
    return (attended / records.length) * 100;
  }

  @override
  Stream<List<AttendanceRecordEntity>> watchRecords() {
    return LocalStorage.attendanceBox.watch().map((_) => getRecords());
  }

  AttendanceRecordEntity _toEntity(shared_models.AttendanceRecord m) {
    return AttendanceRecordEntity(
      id: m.id,
      courseId: m.courseId,
      date: m.date,
      status: _toDomainStatus(m.status),
    );
  }

  AttendanceStatus _toDomainStatus(shared_models.AttendanceStatus s) {
    switch (s) {
      case shared_models.AttendanceStatus.present: return AttendanceStatus.present;
      case shared_models.AttendanceStatus.absent: return AttendanceStatus.absent;
      case shared_models.AttendanceStatus.late: return AttendanceStatus.late;
      case shared_models.AttendanceStatus.upcoming: return AttendanceStatus.upcoming;
    }
  }

  shared_models.AttendanceStatus _toModelStatus(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present: return shared_models.AttendanceStatus.present;
      case AttendanceStatus.absent: return shared_models.AttendanceStatus.absent;
      case AttendanceStatus.late: return shared_models.AttendanceStatus.late;
      case AttendanceStatus.upcoming: return shared_models.AttendanceStatus.upcoming;
    }
  }
}
