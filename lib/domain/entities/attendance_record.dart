enum AttendanceStatus { present, absent, late, upcoming }

class AttendanceRecordEntity {
  final String id;
  final String courseId;
  final DateTime date;
  final AttendanceStatus status;

  AttendanceRecordEntity({
    required this.id,
    required this.courseId,
    required this.date,
    required this.status,
  });
}
