import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/utils/grade_calculator.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../../shared/providers/pomodoro_provider.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/pomodoro_session.dart';
import '../../../domain/usecases/cgpa_calculator.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/pill_chip.dart';
import '../../widgets/animated_counter.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final courses = ref.watch(courseListProvider);
    final cgpa = ref.watch(cgpaResultProvider);
    final sessions = ref.watch(pomodoroSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Performance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            FadeInUp(child: _buildCGPACard(context, cgpa)),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 200), child: _buildPomodoroControl(context, ref, pomodoro)),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 250), child: _buildPomodoroChart(context, sessions)),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 300), child: _buildGradeDistribution(context, courses)),
            const SizedBox(height: 24),
            FadeInUp(delay: const Duration(milliseconds: 400), child: _buildPerformanceOverview(context, courses)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCGPACard(BuildContext context, CgpaResult cgpa) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT CGPA',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Icon(Icons.show_chart, color: Theme.of(context).colorScheme.primary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedCounter(
                targetValue: cgpa.cgpa,
                decimals: 2,
                style: GoogleFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.displayLarge?.color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ 4.0',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.arrow_upward, color: Theme.of(context).colorScheme.primary, size: 16),
              const SizedBox(width: 4),
              Text(
                '${cgpa.letterGrade} · ${cgpa.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroControl(BuildContext context, WidgetRef ref, PomodoroState state) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'POMODORO',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Row(
                children: [
                  _buildStatusBadge(state.status),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showDurationSettings(context, ref, state),
                    child: Icon(Icons.settings, size: 18, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (state.isActive)
                  Pulse(
                    infinite: true,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Text(
                    key: ValueKey(state.timerString),
                    state.timerString,
                    style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(Icons.replay, () => ref.read(pomodoroProvider.notifier).resetTimer(), context),
              const SizedBox(width: 20),
              _buildPlayPauseButton(ref, state, context),
              const SizedBox(width: 20),
              _buildIconButton(
                Icons.skip_next,
                () => ref.read(pomodoroProvider.notifier).skipSession(),
                context,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('${state.completedSessions} sessions today', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          GradientButton(
            label: 'Start Focus Session',
            icon: Icons.play_arrow,
            onPressed: state.isActive
                ? () => ref.read(pomodoroProvider.notifier).pauseTimer()
                : () => ref.read(pomodoroProvider.notifier).startTimer(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PomodoroStatus status) {
    String text;
    Color color;
    switch (status) {
      case PomodoroStatus.focus:
        text = 'FOCUS';
        color = AppTheme.primary;
        break;
      case PomodoroStatus.shortBreak:
        text = 'SHORT BREAK';
        color = AppTheme.secondary;
        break;
      case PomodoroStatus.longBreak:
        text = 'LONG BREAK';
        color = AppTheme.tertiary;
        break;
      default:
        text = 'READY';
        color = AppTheme.textPrimary.withOpacity(0.3);
    }
    return PillChip(label: text, color: color, fontSize: 10);
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon),
      ),
    );
  }

  Widget _buildPlayPauseButton(WidgetRef ref, PomodoroState state, BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        if (state.isActive) {
          ref.read(pomodoroProvider.notifier).pauseTimer();
        } else {
          ref.read(pomodoroProvider.notifier).startTimer();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          state.isActive ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  void _showDurationSettings(BuildContext context, WidgetRef ref, PomodoroState state) {
    double focus = state.focusMinutes.toDouble();
    double shortBreak = state.shortBreakMinutes.toDouble();
    double longBreak = state.longBreakMinutes.toDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Timer Settings',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Focus Duration', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: focus,
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '${focus.round()} min',
                    onChanged: (v) => setSheetState(() => focus = v),
                  ),
                  const SizedBox(height: 8),
                  Text('Short Break', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: shortBreak,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: '${shortBreak.round()} min',
                    onChanged: (v) => setSheetState(() => shortBreak = v),
                  ),
                  const SizedBox(height: 8),
                  Text('Long Break', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Slider(
                    value: longBreak,
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: '${longBreak.round()} min',
                    onChanged: (v) => setSheetState(() => longBreak = v),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: 'Save',
                      onPressed: () {
                        ref.read(pomodoroProvider.notifier).setDurations(
                          focus.round(),
                          shortBreak.round(),
                          longBreak.round(),
                        );
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPomodoroChart(BuildContext context, List<PomodoroSessionEntity> sessions) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final weekData = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayMinutes = sessions
          .where((s) =>
              s.timestamp.year == day.year &&
              s.timestamp.month == day.month &&
              s.timestamp.day == day.day)
          .fold<int>(0, (sum, s) => sum + (s.durationSeconds / 60).round());
      return (day: day, minutes: dayMinutes);
    });

    final maxMinutes = weekData.fold<int>(0, (max, d) => d.minutes > max ? d.minutes : max);
    final hasData = weekData.any((d) => d.minutes > 0);

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Focus Analytics', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.timer_outlined, color: scheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text('Minutes focused per day', style: TextStyle(fontSize: 12, color: scheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 24),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Complete focus sessions to see your weekly chart',
                  style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
                ),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  maxY: (maxMinutes + 5).toDouble(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} min',
                          TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= weekData.length) return const SizedBox.shrink();
                          final day = weekData[idx].day;
                          final label = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(label, style: TextStyle(fontSize: 9, color: scheme.onSurface.withValues(alpha: 0.5))),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(weekData.length, (i) {
                    final d = weekData[i];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: d.minutes.toDouble().clamp(0.5, double.infinity),
                          color: d.minutes > 0 ? scheme.primary : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGradeDistribution(BuildContext context, List<CourseEntity> courses) {
    if (courses.isEmpty) return const SizedBox.shrink();

    final gradeCounts = <String, int>{};
    for (final course in courses) {
      if (course.currentGrade > 0) {
        final letter = GradeCalculator.gpaToLetter(course.currentGrade);
        gradeCounts[letter] = (gradeCounts[letter] ?? 0) + 1;
      }
    }

    if (gradeCounts.isEmpty) return const SizedBox.shrink();

    final grades = ['A', 'B+', 'B', 'B-', 'C+', 'C', 'D', 'F'];
    final data = grades.map((g) => (grade: g, count: gradeCounts[g] ?? 0)).toList();
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grade Distribution', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(data[idx].grade, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: List.generate(data.length, (i) {
                  final colors = [
                    AppTheme.primary,
                    AppTheme.secondary,
                    AppTheme.tertiary,
                    AppTheme.primary.withOpacity(0.6),
                    AppTheme.secondary.withOpacity(0.6),
                    AppTheme.tertiary.withOpacity(0.6),
                    AppTheme.error.withOpacity(0.6),
                    AppTheme.error,
                  ];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].count.toDouble().clamp(0.5, double.infinity),
                        color: colors[i % colors.length],
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview(BuildContext context, List<CourseEntity> courses) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subject Performance', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (courses.isEmpty) Text('Add courses to see progress.', style: Theme.of(context).textTheme.bodyMedium),
          ...courses.map((course) => _buildSubjectProgress(context, course)),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress(BuildContext context, CourseEntity course) {
    final percentage = course.currentGrade > 0
        ? (course.currentGrade / 4.0 * 100).clamp(0, 100)
        : 0.0;
    final letter = GradeCalculator.gpaToLetter(course.currentGrade);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(
                '$letter · ${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 80
                  ? AppTheme.primary
                  : percentage >= 60
                      ? AppTheme.tertiary
                      : AppTheme.error,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
