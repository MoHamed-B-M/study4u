import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../domain/usecases/attendance_analytics.dart';
import '../../../theme/comic_theme.dart';
import '../../../widgets/comic_card.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track your class attendance',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildAttendanceStats(context, analytics),
                  const SizedBox(height: 24),
                  _buildCalendarCard(context),
                  const SizedBox(height: 32),
                  _buildDailySchedule(context, courses),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStats(BuildContext context, AttendanceAnalyticsResult analytics) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!analytics.hasRecords) {
      return ComicCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.how_to_reg_outlined,
                size: 40, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No classes tracked yet!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack),
            ),
            const SizedBox(height: 4),
            Text(
              'Start marking attendance to see your stats here.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ComicCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 72,
            lineWidth: 12,
            percent: analytics.percentage / 100,
            center: Text(
              '${analytics.percentage.toInt()}%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
              ),
            ),
            progressColor: analytics.isBelowThreshold
                ? ComicTheme.inkRed
                : ComicTheme.inkRed,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
          ),
          const SizedBox(height: 16),
          Text(
            'Total Attendance',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: analytics.isBelowThreshold
                  ? ComicTheme.inkRed
                  : ComicTheme.inkRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              analytics.isBelowThreshold
                  ? 'Warning: Below 75% threshold!'
                  : 'You are doing great! Keep it up.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: analytics.isBelowThreshold ? Colors.white : ComicTheme.inkRed,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Present', analytics.present, ComicTheme.inkRed, isDark),
              _buildStatItem('Absent', analytics.absent, ComicTheme.inkRed, isDark),
              _buildStatItem('Late', analytics.late, const Color(0xFFFFB74D), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ComicCard(
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
            color: ComicTheme.inkRed.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: ComicTheme.inkRed,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: TextStyle(
            color: isDark ? ComicTheme.darkText.withValues(alpha: 0.7) : ComicTheme.inkBlack,
          ),
          weekendTextStyle: TextStyle(
            color: isDark ? ComicTheme.darkText.withValues(alpha: 0.5) : ComicTheme.inkBlack.withValues(alpha: 0.5),
          ),
          outsideTextStyle: TextStyle(
            color: isDark ? ComicTheme.darkText.withValues(alpha: 0.3) : ComicTheme.inkBlack.withValues(alpha: 0.2),
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: isDark ? ComicTheme.darkText.withValues(alpha: 0.5) : ComicTheme.inkBlack),
          rightChevronIcon: Icon(Icons.chevron_right, color: isDark ? ComicTheme.darkText.withValues(alpha: 0.5) : ComicTheme.inkBlack),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: isDark ? ComicTheme.darkText.withValues(alpha: 0.4) : ComicTheme.inkBlack.withValues(alpha: 0.4),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDailySchedule(BuildContext context, List<CourseEntity> courses) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Schedule",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
          ),
        ),
        const SizedBox(height: 16),
        if (courses.isEmpty)
          Text('No classes scheduled for today.', style: TextStyle(
            color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
          )),
        ...List.generate(courses.length, (index) {
          final course = courses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ComicCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(course.colorValue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.school, color: Color(course.colorValue)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${course.startTime} - ${course.endTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      _buildActionChip('Present', Icons.check_circle, ComicTheme.inkRed, () => _markAttendance(course.id, AttendanceStatus.present)),
                      const SizedBox(height: 6),
                      _buildActionChip('Late', Icons.access_time, const Color(0xFFFFB74D), () => _markAttendance(course.id, AttendanceStatus.late)),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
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
