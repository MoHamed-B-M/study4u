import '../../core/constants/app_constants.dart';
import '../entities/attendance_record.dart';

class AttendanceAnalyticsResult {
  final double percentage;
  final int present;
  final int absent;
  final int late;
  final int total;
  final bool isBelowThreshold;

  const AttendanceAnalyticsResult({
    required this.percentage,
    required this.present,
    required this.absent,
    required this.late,
    required this.total,
    required this.isBelowThreshold,
  });
}

class AttendanceAnalyticsUseCase {
  AttendanceAnalyticsResult execute(List<AttendanceRecordEntity> records) {
    final present = records.where((r) => r.status == AttendanceStatus.present).length;
    final absent = records.where((r) => r.status == AttendanceStatus.absent).length;
    final late = records.where((r) => r.status == AttendanceStatus.late).length;
    final total = records.length;
    final attended = present + late;
    final percentage = total > 0 ? (attended / total) * 100 : 0.0;

    return AttendanceAnalyticsResult(
      percentage: double.parse(percentage.toStringAsFixed(1)),
      present: present,
      absent: absent,
      late: late,
      total: total,
      isBelowThreshold: percentage < AppConstants.attendanceThreshold,
    );
  }
}
