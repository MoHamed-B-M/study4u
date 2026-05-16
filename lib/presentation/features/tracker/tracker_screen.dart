import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(attendanceAnalyticsResultProvider);
    final courses = ref.watch(courseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tracker', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAttendanceStats(context, analytics),
            const SizedBox(height: 24),
            _buildCalendarCard(context),
            const SizedBox(height: 32),
            _buildDailySchedule(context, courses),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStats(BuildContext context, AttendanceAnalyticsResult analytics) {
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
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            progressColor: analytics.isBelowThreshold ? AppTheme.error : Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
          ),
          const SizedBox(height: 16),
          Text('Total Attendance', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            analytics.isBelowThreshold ? 'Warning: Below 75% threshold!' : 'You are doing great! Keep it up.',
            style: TextStyle(
              color: analytics.isBelowThreshold ? AppTheme.error : Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Present', analytics.present, Theme.of(context).colorScheme.primary),
              _buildStatItem('Absent', analytics.absent, AppTheme.error),
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
        Text(count.toString(), style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
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
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
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

  Widget _buildDailySchedule(BuildContext context, List<CourseEntity> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Today's Schedule", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (courses.isEmpty)
          Text('No classes scheduled for today.', style: Theme.of(context).textTheme.bodyMedium),
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
                    child: Icon(Icons.school, color: Color(course.colorValue)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          '${course.startTime} - ${course.endTime}',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildStatusIcon(course.id, AttendanceStatus.present, Icons.check_circle, Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      _buildStatusIcon(course.id, AttendanceStatus.absent, Icons.cancel, AppTheme.error),
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

  Widget _buildStatusIcon(String courseId, AttendanceStatus status, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        ref.read(attendanceRepositoryProvider).markAttendance(
          AttendanceRecordEntity(
            id: '${courseId}_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}',
            courseId: courseId,
            date: _selectedDay ?? DateTime.now(),
            status: status,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

bool isSameDay2(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
