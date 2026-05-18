import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../domain/usecases/attendance_analytics.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _markAttendance(String courseId, AttendanceStatus status) {
    HapticFeedback.mediumImpact();
    final day = _selectedDay ?? DateTime.now();
    final id = '${courseId}_${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
    ref.read(attendanceRepositoryProvider).markAttendance(
      AttendanceRecordEntity(
        id: id,
        courseId: courseId,
        date: day,
        status: status,
      ),
    );
    ref.read(dataRefreshProvider.notifier).state++;
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(attendanceAnalyticsResultProvider);
    final courses = ref.watch(courseListProvider);
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: const Border(bottom: BorderSide.none),
        middle: const Text('Tracker'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildAttendanceStats(context, analytics, primaryColor),
              const SizedBox(height: 24),
              _buildCalendarCard(context, primaryColor),
              const SizedBox(height: 32),
              _buildDailySchedule(context, courses, primaryColor),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceStats(BuildContext context, AttendanceAnalyticsResult analytics, Color primaryColor) {
    if (!analytics.hasRecords) {
      return AppCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.checkmark_seal,
                size: 40,
                color: CupertinoColors.systemGrey3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No classes tracked yet!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Start marking attendance to see your stats here.',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemGrey2,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 60,
            lineWidth: 10,
            percent: analytics.percentage / 100,
            center: Text(
              '${analytics.percentage.toInt()}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            progressColor: analytics.isBelowThreshold
                ? CupertinoColors.systemRed
                : primaryColor,
            backgroundColor: CupertinoColors.systemGrey6,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
          ),
          const SizedBox(height: 16),
          const Text(
            'Total Attendance',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            analytics.isBelowThreshold
                ? 'Warning: Below 75% threshold!'
                : 'You are doing great! Keep it up.',
            style: TextStyle(
              color: analytics.isBelowThreshold
                  ? CupertinoColors.systemRed
                  : CupertinoColors.systemGrey2,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Present', analytics.present, primaryColor),
              _buildStatItem('Absent', analytics.absent, CupertinoColors.systemRed),
              _buildStatItem('Late', analytics.late, AppTheme.tertiary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCalendarCard(BuildContext context, Color primaryColor) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay2(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          HapticFeedback.selectionClick();
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: primaryColor,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppTheme.secondary,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildDailySchedule(BuildContext context, List<CourseEntity> courses, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Schedule",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (courses.isEmpty)
          Text(
            'No classes scheduled for today.',
            style: TextStyle(color: CupertinoColors.systemGrey2),
          ),
        ...List.generate(courses.length, (index) {
          final course = courses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(course.colorValue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.book,
                      color: Color(course.colorValue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course.startTime} - ${course.endTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      _buildActionChip('Present', CupertinoIcons.checkmark_circle, primaryColor, () => _markAttendance(course.id, AttendanceStatus.present)),
                      const SizedBox(height: 6),
                      _buildActionChip('Late', CupertinoIcons.clock, AppTheme.tertiary, () => _markAttendance(course.id, AttendanceStatus.late)),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

bool isSameDay2(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
