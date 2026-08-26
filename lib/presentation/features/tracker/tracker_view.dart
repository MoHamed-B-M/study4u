import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../domain/usecases/attendance_analytics.dart';
import '../../../theme/comic_theme.dart';
import '../../../widgets/comic_card.dart';
import '../../widgets/circular_progress_ring.dart';

class TrackerView extends ConsumerStatefulWidget {
  const TrackerView({super.key});

  @override
  ConsumerState<TrackerView> createState() => _TrackerViewState();
}

class _TrackerViewState extends ConsumerState<TrackerView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _markAttendance(String courseId, AttendanceStatus status) {
    Vibrate.feedback(FeedbackType.medium);
    final day = _selectedDay ?? DateTime.now();
    final id =
        '${courseId}_${day.year}${day.month.toString().padLeft(2, '0')}${day.day.toString().padLeft(2, '0')}';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                children: [
                  _buildAttendanceOverview(analytics),
                  const SizedBox(height: 24),
                  _buildCalendarCard(context),
                  const SizedBox(height: 24),
                  _buildDailySchedule(context, courses),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceOverview(AttendanceAnalyticsResult analytics) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!analytics.hasRecords) {
      return ComicCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                SolarIconsBold.diploma,
                size: 32,
                color: Color(0xFF64B5F6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Classes Tracked Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start marking attendance to see your stats.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ComicCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Attendance Rate',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${analytics.percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  analytics.isBelowThreshold
                      ? 'Below 75% threshold'
                      : 'You\'re doing great!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatPill('Present', analytics.present,
                        const Color(0xFF66BB6A)),
                    const SizedBox(width: 8),
                    _buildStatPill('Absent', analytics.absent,
                        const Color(0xFFEF5350)),
                    const SizedBox(width: 8),
                    _buildStatPill(
                        'Late', analytics.late, const Color(0xFFFFB74D)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircularProgressRing(
            progress: analytics.percentage / 100,
            size: 80,
            strokeWidth: 8,
            progressColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            label: '${analytics.percentage.toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ComicCard(
      padding: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => _isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          Vibrate.feedback(FeedbackType.selection);
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: const Color(0xFFA18CFF),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: const Color(0xFF8F99FB),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
          ),
          weekendTextStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFFEF5350),
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
          ),
          leftChevronIcon: Icon(
            SolarIconsBold.arrowLeft,
            size: 18,
            color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
          ),
          rightChevronIcon: Icon(
            SolarIconsBold.arrowRight,
            size: 18,
            color: isDark ? ComicTheme.darkText.withValues(alpha: 0.6) : ComicTheme.inkBlack.withValues(alpha: 0.6),
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
          'Today\'s Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
          ),
        ),
        const SizedBox(height: 16),
        if (courses.isEmpty)
          ComicCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No classes scheduled for today.',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? ComicTheme.darkText.withValues(alpha: 0.4) : ComicTheme.inkBlack.withValues(alpha: 0.4),
                ),
              ),
            ),
          )
        else
          ...courses.map((course) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ComicCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Color(course.colorValue).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        SolarIconsBold.book,
                        color: Color(course.colorValue),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                            ),
                          ),
                          const SizedBox(height: 2),
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
                    Column(
                      children: [
                        _buildMarkButton(
                            'P',
                            SolarIconsBold.checkCircle,
                            const Color(0xFF66BB6A),
                            () => _markAttendance(
                                course.id, AttendanceStatus.present)),
                        const SizedBox(height: 6),
                        _buildMarkButton(
                            'L',
                            SolarIconsBold.clockCircle,
                            const Color(0xFFFFB74D),
                            () => _markAttendance(
                                course.id, AttendanceStatus.late)),
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

  Widget _buildMarkButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
