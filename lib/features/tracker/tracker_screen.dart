import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/providers/logic_providers.dart';
import '../../shared/models/models.dart';

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
    final attendanceRecords = ref.watch(attendanceTrackerProvider);
    final courses = ref.watch(courseListProvider);
    final percentage = ref.read(attendanceTrackerProvider.notifier).getAttendancePercentage();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tracker', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAttendanceStats(context, percentage, attendanceRecords),
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

  Widget _buildAttendanceStats(BuildContext context, double percentage, List<AttendanceRecord> records) {
    final isBelowThreshold = percentage < 75;
    return FadeInUp(
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 10.0,
              percent: percentage / 100,
              center: Text('${percentage.toInt()}%', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
              progressColor: isBelowThreshold ? AppTheme.error : AppTheme.primary,
              backgroundColor: AppTheme.background,
              circularStrokeCap: CircularStrokeCap.round,
              animation: true,
            ),
            const SizedBox(height: 16),
            Text('Total Attendance', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              isBelowThreshold ? 'Warning: Below 75% threshold!' : 'You are doing great! Keep it up.',
              style: TextStyle(color: isBelowThreshold ? AppTheme.error : AppTheme.textPrimary.withOpacity(0.6), fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Present', records.where((r) => r.status == AttendanceStatus.present).length, AppTheme.primary),
                _buildStatItem('Absent', records.where((r) => r.status == AttendanceStatus.absent).length, AppTheme.error),
                _buildStatItem('Late', records.where((r) => r.status == AttendanceStatus.late).length, AppTheme.tertiary),
              ],
            ),
          ],
        ),
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
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle),
          ),
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        ),
      ),
    );
  }

  Widget _buildDailySchedule(BuildContext context, List<Course> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Schedule", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
        const SizedBox(height: 16),
        if (courses.isEmpty) const Text('No classes scheduled for today.'),
        ...List.generate(courses.length, (index) {
          final course = courses[index];
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: course.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.school, color: course.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${course.startTime} - ${course.endTime}', style: TextStyle(fontSize: 12, color: AppTheme.textPrimary.withOpacity(0.6))),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildStatusIcon(course.id, AttendanceStatus.present, Icons.check_circle, AppTheme.primary),
                        const SizedBox(width: 8),
                        _buildStatusIcon(course.id, AttendanceStatus.absent, Icons.cancel, AppTheme.error),
                      ],
                    ),
                  ],
                ),
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
        ref.read(attendanceTrackerProvider.notifier).markAttendance(courseId, _selectedDay ?? DateTime.now(), status);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
