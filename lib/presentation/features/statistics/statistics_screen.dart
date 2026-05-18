import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        border: const Border(bottom: BorderSide.none),
        middle: const Text('Performance'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              FadeTransition(
                opacity: _fadeController.drive(CurveTween(curve: const Interval(0.0, 0.3, curve: Curves.easeOut))),
                child: _buildCGPACard(context, cgpa, primaryColor),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeController.drive(CurveTween(curve: const Interval(0.15, 0.45, curve: Curves.easeOut))),
                child: _buildPomodoroControl(context, ref, pomodoro, primaryColor),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeController.drive(CurveTween(curve: const Interval(0.3, 0.6, curve: Curves.easeOut))),
                child: _buildPomodoroChart(context, sessions, primaryColor),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeController.drive(CurveTween(curve: const Interval(0.45, 0.75, curve: Curves.easeOut))),
                child: _buildGradeDistribution(context, courses),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeController.drive(CurveTween(curve: const Interval(0.6, 0.9, curve: Curves.easeOut))),
                child: _buildPerformanceOverview(context, courses, primaryColor),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCGPACard(BuildContext context, CgpaResult cgpa, Color primaryColor) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CURRENT CGPA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemGrey2,
                ),
              ),
              Icon(CupertinoIcons.chart_bar_alt_fill, color: primaryColor),
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
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '/ 4.0',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemGrey2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(CupertinoIcons.arrow_up_right, color: primaryColor, size: 16),
              const SizedBox(width: 4),
              Text(
                '${cgpa.letterGrade} · ${cgpa.percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroControl(BuildContext context, WidgetRef ref, PomodoroState state, Color primaryColor) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'POMODORO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.systemGrey2,
                ),
              ),
              Row(
                children: [
                  _buildStatusBadge(state.status),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showDurationSettings(context, ref, state),
                    child: Icon(CupertinoIcons.gear, size: 18, color: primaryColor),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _pickMusicFile(ref, state),
                    child: Icon(
                      CupertinoIcons.music_note,
                      size: 18,
                      color: state.musicFilePath != null
                          ? primaryColor
                          : CupertinoColors.systemGrey3,
                    ),
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
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Text(
                    key: ValueKey(state.timerString),
                    state.timerString,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(CupertinoIcons.arrow_counterclockwise, () => ref.read(pomodoroProvider.notifier).resetTimer(), context),
              const SizedBox(width: 20),
              _buildPlayPauseButton(ref, state, context, primaryColor),
              const SizedBox(width: 20),
              _buildIconButton(
                CupertinoIcons.forward_end_fill,
                () => ref.read(pomodoroProvider.notifier).skipSession(),
                context,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('${state.completedSessions} sessions today', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          if (state.musicFilePath != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.music_note, size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Focus Music',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: primaryColor),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(pomodoroProvider.notifier).toggleMusic(),
                    child: Icon(
                      state.isMusicPlaying ? CupertinoIcons.pause_circle_fill : CupertinoIcons.play_circle_fill,
                      size: 24,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _pickMusicFile(ref, state),
                    child: Icon(
                      CupertinoIcons.xmark_circle,
                      size: 18,
                      color: CupertinoColors.systemGrey3,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          GradientButton(
            label: 'Start Focus Session',
            icon: CupertinoIcons.play_fill,
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
        color = CupertinoColors.systemGrey3;
    }
    return PillChip(label: text, color: color, fontSize: 10);
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          shape: BoxShape.circle,
        ),
        child: Icon(icon),
      ),
    );
  }

  Widget _buildPlayPauseButton(WidgetRef ref, PomodoroState state, BuildContext context, Color primaryColor) {
    return GestureDetector(
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
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          state.isActive ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
          color: CupertinoColors.white,
          size: 32,
        ),
      ),
    );
  }

  void _showDurationSettings(BuildContext context, WidgetRef ref, PomodoroState state) {
    double focus = state.focusMinutes.toDouble();
    double shortBreak = state.shortBreakMinutes.toDouble();
    double longBreak = state.longBreakMinutes.toDouble();

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return CupertinoActionSheet(
              title: const Text('Timer Settings'),
              message: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Focus Duration', style: TextStyle(fontWeight: FontWeight.bold)),
                  CupertinoSlider(
                    value: focus,
                    min: 1,
                    max: 60,
                    divisions: 59,
                    onChanged: (v) => setSheetState(() => focus = v),
                  ),
                  Text('${focus.round()} min'),
                  const SizedBox(height: 8),
                  const Text('Short Break', style: TextStyle(fontWeight: FontWeight.bold)),
                  CupertinoSlider(
                    value: shortBreak,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    onChanged: (v) => setSheetState(() => shortBreak = v),
                  ),
                  Text('${shortBreak.round()} min'),
                  const SizedBox(height: 8),
                  const Text('Long Break', style: TextStyle(fontWeight: FontWeight.bold)),
                  CupertinoSlider(
                    value: longBreak,
                    min: 1,
                    max: 60,
                    divisions: 59,
                    onChanged: (v) => setSheetState(() => longBreak = v),
                  ),
                  Text('${longBreak.round()} min'),
                ],
              ),
              actions: [
                CupertinoActionSheetAction(
                  isDefaultAction: true,
                  onPressed: () {
                    ref.read(pomodoroProvider.notifier).setDurations(
                      focus.round(),
                      shortBreak.round(),
                      longBreak.round(),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
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

  Widget _buildPomodoroChart(BuildContext context, List<PomodoroSessionEntity> sessions, Color primaryColor) {
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
              const Text('Focus Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(CupertinoIcons.timer, color: primaryColor, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Minutes focused per day', style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey2)),
          const SizedBox(height: 24),
          if (!hasData)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Complete focus sessions to see your weekly chart',
                  style: TextStyle(color: CupertinoColors.systemGrey3, fontSize: 13),
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
                          const TextStyle(fontWeight: FontWeight.bold),
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
                            child: Text(label, style: const TextStyle(fontSize: 9, color: CupertinoColors.systemGrey2)),
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
                          color: d.minutes > 0 ? primaryColor : CupertinoColors.systemGrey6,
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
          const Text('Grade Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    CupertinoColors.systemRed.withOpacity(0.6),
                    CupertinoColors.systemRed,
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

  Widget _buildPerformanceOverview(BuildContext context, List<CourseEntity> courses, Color primaryColor) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Subject Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (courses.isEmpty)
            Text(
              'Add courses to see progress.',
              style: TextStyle(color: CupertinoColors.systemGrey2),
            ),
          ...courses.map((course) => _buildSubjectProgress(context, course, primaryColor)),
        ],
      ),
    );
  }

  Widget _buildSubjectProgress(BuildContext context, CourseEntity course, Color primaryColor) {
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
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: CupertinoColors.systemGrey6,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 80
                    ? AppTheme.primary
                    : percentage >= 60
                        ? AppTheme.tertiary
                        : CupertinoColors.systemRed,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
