import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
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

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});
  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pomodoro = ref.watch(pomodoroProvider);
    final courses = ref.watch(courseListProvider);
    final cgpa = ref.watch(cgpaResultProvider);
    final sessions = ref.watch(pomodoroSessionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Performance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeController.drive(CurveTween(curve: const Interval(0.0, 0.3, curve: Curves.easeOut))),
              child: _buildCGPACard(context, cgpa, isDark),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeController.drive(CurveTween(curve: const Interval(0.15, 0.45, curve: Curves.easeOut))),
              child: _buildPomodoroControl(context, ref, pomodoro, isDark),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeController.drive(CurveTween(curve: const Interval(0.3, 0.6, curve: Curves.easeOut))),
              child: _buildPomodoroChart(context, sessions, isDark),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeController.drive(CurveTween(curve: const Interval(0.45, 0.75, curve: Curves.easeOut))),
              child: _buildGradeDistribution(context, courses, isDark),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _fadeController.drive(CurveTween(curve: const Interval(0.6, 0.9, curve: Curves.easeOut))),
              child: _buildPerformanceOverview(context, courses, isDark),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCGPACard(BuildContext context, CgpaResult cgpa, bool isDark) {
    return AppCard(
      color: isDark ? AppTheme.surfaceDark : Colors.white,
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
                  color: isDark ? Colors.white60 : Theme.of(context).textTheme.bodyMedium?.color,
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
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ 4.0',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.arrow_upward, color: AppTheme.primary, size: 16),
              const SizedBox(width: 4),
              Text(
                '${cgpa.letterGrade} \u2022 ${cgpa.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroControl(BuildContext context, WidgetRef ref, PomodoroState state, bool isDark) {
    return AppCard(
      color: isDark ? AppTheme.surfaceDark : Colors.white,
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
                  color: isDark ? Colors.white60 : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Row(
                children: [
                  _buildStatusBadge(state.status, isDark),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showDurationSettings(context, ref, state),
                    child: Icon(Icons.settings, size: 18, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _pickMusicFile(ref, state),
                    child: Icon(
                      Icons.music_note,
                      size: 18,
                      color: state.musicFilePath != null
                          ? Theme.of(context).colorScheme.primary
                          : (isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              state.timerString,
              key: ValueKey(state.timerString),
              style: GoogleFonts.outfit(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.completedSessions} sessions today',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white60 : AppTheme.textPrimary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(Icons.replay, () => ref.read(pomodoroProvider.notifier).resetTimer(), context, isDark),
              const SizedBox(width: 24),
              _buildPlayPauseButton(ref, state, context, isDark),
              const SizedBox(width: 24),
              _buildIconButton(Icons.skip_next, () => ref.read(pomodoroProvider.notifier).skipSession(), context, isDark),
            ],
          ),
          if (state.musicFilePath != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.music_note, size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Focus Music',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  InkWell(
                    onTap: () => ref.read(pomodoroProvider.notifier).toggleMusic(),
                    child: Icon(
                      state.isMusicPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _pickMusicFile(ref, state),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: isDark ? Colors.white38 : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          GradientButton(
            label: state.isActive ? 'Pause Focus Session' : 'Start Focus Session',
            icon: state.isActive ? Icons.pause : Icons.play_arrow,
            onPressed: state.isActive
                ? () => ref.read(pomodoroProvider.notifier).pauseTimer()
                : () => ref.read(pomodoroProvider.notifier).startTimer(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PomodoroStatus status, bool isDark) {
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
        color = isDark ? Colors.white38 : AppTheme.textPrimary.withValues(alpha: 0.3);
    }
    return PillChip(label: text, color: color, fontSize: 10);
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, BuildContext context, bool isDark) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.transparent,
          ),
        ),
        child: Icon(icon, color: isDark ? Colors.white60 : null),
      ),
    );
  }

  Widget _buildPlayPauseButton(WidgetRef ref, PomodoroState state, BuildContext context, bool isDark) {
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          state.isActive ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 36,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
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

  void _pickMusicFile(WidgetRef ref, PomodoroState state) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      ref.read(pomodoroProvider.notifier).setMusicFile(result.files.single.path);
    }
  }

  Widget _buildPomodoroChart(BuildContext context, List<PomodoroSessionEntity> sessions, bool isDark) {
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
      color: isDark ? AppTheme.surfaceDark : Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Analytics',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              Icon(Icons.timer_outlined, color: scheme.primary, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Minutes focused per day',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Complete focus sessions to see your weekly chart',
                  style: TextStyle(color: isDark ? Colors.white38 : scheme.onSurface.withValues(alpha: 0.4), fontSize: 13),
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
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 9,
                                color: isDark ? Colors.white38 : scheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
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
                          color: d.minutes > 0
                              ? scheme.primary
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : scheme.surfaceContainerHighest.withValues(alpha: 0.3)),
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

  Widget _buildGradeDistribution(BuildContext context, List<CourseEntity> courses, bool isDark) {
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
      color: isDark ? AppTheme.surfaceDark : Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grade Distribution',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
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
                          child: Text(
                            data[idx].grade,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white60 : AppTheme.textPrimary,
                            ),
                          ),
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
                    AppTheme.primary.withValues(alpha: 0.6),
                    AppTheme.secondary.withValues(alpha: 0.6),
                    AppTheme.tertiary.withValues(alpha: 0.6),
                    AppTheme.warningRed.withValues(alpha: 0.6),
                    AppTheme.warningRed,
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

  Widget _buildPerformanceOverview(BuildContext context, List<CourseEntity> courses, bool isDark) {
    return AppCard(
      color: isDark ? AppTheme.surfaceDark : Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Performance',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          if (courses.isEmpty)
            Text('Add courses to see progress.', style: Theme.of(context).textTheme.bodyMedium),
          ...courses.map((course) => _buildSubjectProgress(context, course, isDark)),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress(BuildContext context, CourseEntity course, bool isDark) {
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
              Expanded(
                child: Text(
                  course.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                '$letter \u2022 ${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 80
                  ? AppTheme.primary
                  : percentage >= 60
                      ? AppTheme.tertiary
                      : AppTheme.warningRed,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
