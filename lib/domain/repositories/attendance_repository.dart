import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  List<AttendanceRecordEntity> getRecords();
  List<AttendanceRecordEntity> getRecordsForCourse(String courseId);
  void markAttendance(AttendanceRecordEntity record);
  double getAttendancePercentage();
  Stream<List<AttendanceRecordEntity>> watchRecords();
}
