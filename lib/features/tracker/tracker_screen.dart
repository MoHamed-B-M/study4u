import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/providers/mock_data.dart';
import '../../shared/models/models.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  DateTime _focusedDay = DateTime(2026, 1, 12);
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(mockAttendanceStatsProvider);
    final schedule = ref.watch(mockScheduleProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: AppTheme.surfaceVariant,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=tareq'),
          ),
        ),
        title: Text(
          'stdy4u',
          style: GoogleFonts.outfit(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Text(
                'Tracker',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: _buildAttendanceSummary(context, stats),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: _buildStatusChips(context, stats),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              duration: const Duration(milliseconds: 800),
              child: _buildCalendar(context),
            ),
            const SizedBox(height: 32),
            FadeInLeft(
              duration: const Duration(milliseconds: 500),
              child: Text(
                "Today's Schedule",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(schedule.length, (index) {
              return FadeInUp(
                duration: Duration(milliseconds: 600 + (index * 100)),
                child: _buildScheduleItem(context, schedule[index]),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary(BuildContext context, AttendanceStats stats) {
    return AppCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 80.0,
            lineWidth: 12.0,
            percent: stats.percentage / 100,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${stats.percentage.toInt()}%',
                  style: GoogleFonts.outfit(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
                Text(
                  'TOTAL',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface.withOpacity(0.5),
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            progressColor: AppTheme.primary,
            backgroundColor: const Color(0xFFF1F5F9),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 24),
          Text(
            'Total Attendance',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Keep it up! You\'re above the 75%\nthreshold.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: AppTheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips(BuildContext context, AttendanceStats stats) {
    return Row(
      children: [
        Expanded(child: _buildChip(context, stats.present.toString(), 'PRESENT', const Color(0xFFD1FAE5), const Color(0xFF006D36))),
        const SizedBox(width: 12),
        Expanded(child: _buildChip(context, stats.absent.toString(), 'ABSENT', const Color(0xFFFFDAD6), const Color(0xFF93000A))),
        const SizedBox(width: 12),
        Expanded(child: _buildChip(context, stats.late.toString(), 'LATE', const Color(0xFFFEF3C7), const Color(0xFF92400E))),
      ],
    );
  }

  Widget _buildChip(BuildContext context, String value, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
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
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppTheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          todayTextStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          defaultTextStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
          weekendTextStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, color: Colors.grey),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: false,
          titleTextStyle: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.onSurface),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.onSurface),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
          weekendStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, ScheduleItem item) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    Color iconBgColor;

    switch (item.status) {
      case AttendanceStatus.present:
        statusColor = const Color(0xFF006D36);
        statusText = 'PRESENT';
        statusIcon = Icons.check_circle_outline;
        iconBgColor = const Color(0xFFD1FAE5);
        break;
      case AttendanceStatus.absent:
        statusColor = const Color(0xFFBA1A1A);
        statusText = 'ABSENT';
        statusIcon = Icons.do_not_disturb_on_outlined;
        iconBgColor = const Color(0xFFFFDAD6);
        break;
      case AttendanceStatus.late:
        statusColor = const Color(0xFF795900);
        statusText = 'LATE';
        statusIcon = Icons.access_time_outlined;
        iconBgColor = const Color(0xFFFEF3C7);
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'UPCOMING';
        statusIcon = Icons.radio_button_unchecked;
        iconBgColor = Colors.grey.withOpacity(0.1);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            item.timeRange,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.onSurface.withOpacity(0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.plusJakartaSans(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
