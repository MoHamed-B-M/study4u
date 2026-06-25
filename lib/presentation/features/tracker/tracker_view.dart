import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toolbar_m3e/toolbar_m3e.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../shared/providers/logic_providers.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/attendance_record.dart';
import '../../../../domain/usecases/attendance_analytics.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/dashboard_card.dart';
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
    HapticFeedback.mediumImpact();
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
      appBar: ToolbarM3E(
        titleText: 'Attendance',
        subtitleText: 'STUDY4U',
        variant: ToolbarM3EVariant.surface,
        size: ToolbarM3ESize.large,
      ),
      body: Stack(
        children: [
          const BlobBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: const SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.spacingLG,
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
        ],
      ),
    );
  }

  Widget _buildAttendanceOverview(AttendanceAnalyticsResult analytics) {
    if (!analytics.hasRecords) {
      return DashboardCard(
        backgroundColor: context.surface,
        borderRadius: DesignTokens.radiusLG,
        padding: const EdgeInsets.all(DesignTokens.spacingLG),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignTokens.cardBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.checkmark_seal,
                size: 32,
                color: DesignTokens.cardBlueAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Classes Tracked Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start marking attendance to see your stats.',
              style: TextStyle(
                fontSize: 13,
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return DashboardCard(
      backgroundColor: DesignTokens.primaryLavender,
      borderRadius: DesignTokens.radiusLG,
      padding: const EdgeInsets.all(DesignTokens.spacingLG),
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
                    color: DesignTokens.textWhite,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${analytics.percentage.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  analytics.isBelowThreshold
                      ? 'Below 75% threshold'
                      : 'You\'re doing great!',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignTokens.textWhite.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatPill('Present', analytics.present,
                        DesignTokens.cardGreenAccent),
                    const SizedBox(width: 8),
                    _buildStatPill('Absent', analytics.absent,
                        DesignTokens.cardPinkAccent),
                    const SizedBox(width: 8),
                    _buildStatPill(
                        'Late', analytics.late, DesignTokens.cardCreamAccent),
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
            progressColor: DesignTokens.textWhite,
            backgroundColor: DesignTokens.textWhite.withValues(alpha: 0.2),
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
        color: DesignTokens.textWhite.withValues(alpha: 0.15),
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
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: DesignTokens.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context) {
    return DashboardCard(
      backgroundColor: context.surface,
      borderRadius: DesignTokens.radiusLG,
      padding: const EdgeInsets.all(DesignTokens.spacingMD),
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
          HapticFeedback.selectionClick();
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: DesignTokens.primaryLavender,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: DesignTokens.secondaryBlue,
            shape: BoxShape.circle,
          ),
          defaultTextStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.textPrimary,
          ),
          weekendTextStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: DesignTokens.cardPinkAccent,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
          leftChevronIcon: Icon(
            CupertinoIcons.chevron_left,
            size: 18,
            color: context.textSecondary,
          ),
          rightChevronIcon: Icon(
            CupertinoIcons.chevron_right,
            size: 18,
            color: context.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDailySchedule(BuildContext context, List<CourseEntity> courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (courses.isEmpty)
          DashboardCard(
            backgroundColor: context.surface,
            borderRadius: DesignTokens.radiusLG,
            padding: const EdgeInsets.all(DesignTokens.spacingLG),
            child: Center(
              child: Text(
                'No classes scheduled for today.',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textTertiary,
                ),
              ),
            ),
          )
        else
          ...courses.map((course) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DashboardCard(
                backgroundColor: context.surface,
                borderRadius: DesignTokens.radiusMD,
                padding: const EdgeInsets.all(DesignTokens.spacingMD),
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
                        CupertinoIcons.book,
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
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${course.startTime} - ${course.endTime}',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _buildMarkButton(
                            'P',
                            CupertinoIcons.checkmark,
                            DesignTokens.cardGreenAccent,
                            () => _markAttendance(
                                course.id, AttendanceStatus.present)),
                        const SizedBox(height: 6),
                        _buildMarkButton(
                            'L',
                            CupertinoIcons.clock,
                            DesignTokens.cardCreamAccent,
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
