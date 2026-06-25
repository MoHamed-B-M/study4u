import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/grade_calculator.dart';
import '../../../../shared/providers/logic_providers.dart';
import '../../../../shared/providers/pomodoro_provider.dart';
import '../../../../domain/entities/course.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/study_charts.dart';

class StatsView extends ConsumerStatefulWidget {
  const StatsView({super.key});

  @override
  ConsumerState<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends ConsumerState<StatsView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cgpa = ref.watch(cgpaResultProvider);
    final analytics = ref.watch(attendanceAnalyticsResultProvider);
    final courses = ref.watch(courseListProvider);
    final pomodoro = ref.watch(pomodoroProvider);

    return CupertinoPageScaffold(
      backgroundColor: context.background,
      child: Stack(
        children: [
          const BlobBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      DesignTokens.spacingLG,
                      DesignTokens.spacingMD,
                      DesignTokens.spacingLG,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STUDY4U',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: context.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Statistics',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: context.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const SizedBox(height: 24)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spacingLG,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeTransition(
                          opacity: _fadeController.drive(
                            CurveTween(
                                curve: const Interval(0.0, 0.4,
                                    curve: Curves.easeOut)),
                          ),
                          child: AttendanceCard(
                            attendanceRate: analytics.percentage,
                            grade: cgpa.letterGrade,
                            gradePercentage: cgpa.percentage,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _fadeController.drive(
                            CurveTween(
                                curve: const Interval(0.2, 0.6,
                                    curve: Curves.easeOut)),
                          ),
                          child: _buildCgpaBreakdown(context, courses),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _fadeController.drive(
                            CurveTween(
                                curve: const Interval(0.4, 0.8,
                                    curve: Curves.easeOut)),
                          ),
                          child: PomodoroCard(
                            timerDisplay: pomodoro.timerString,
                            isActive: pomodoro.isActive,
                            completedSessions: pomodoro.completedSessions,
                            onStartPause: () {
                              HapticFeedback.mediumImpact();
                              if (pomodoro.isActive) {
                                ref
                                    .read(pomodoroProvider.notifier)
                                    .pauseTimer();
                              } else {
                                ref
                                    .read(pomodoroProvider.notifier)
                                    .startTimer();
                              }
                            },
                            onReset: () {
                              HapticFeedback.lightImpact();
                              ref.read(pomodoroProvider.notifier).resetTimer();
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _fadeController.drive(
                            CurveTween(
                                curve: const Interval(0.6, 1.0,
                                    curve: Curves.easeOut)),
                          ),
                          child: _buildSubjectPerformance(context, courses),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCgpaBreakdown(BuildContext context, List<CourseEntity> courses) {
    final gradedCourses = courses.where((c) => c.currentGrade > 0).toList();

    if (gradedCourses.isEmpty) {
      return DashboardCard(
        backgroundColor: context.surface,
        borderRadius: DesignTokens.radiusLG,
        padding: const EdgeInsets.all(DesignTokens.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryLavender.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.chart_bar,
                    size: 16,
                    color: DesignTokens.primaryLavender,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Academic Progress Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Add grades to see your progress chart',
                style: TextStyle(
                  fontSize: 13,
                  color: context.textTertiary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final barData = gradedCourses.map((c) {
      final colors = [
        DesignTokens.primaryLavender,
        DesignTokens.secondaryBlue,
        DesignTokens.cardCreamAccent,
        DesignTokens.cardPinkAccent,
        DesignTokens.cardGreenAccent,
        DesignTokens.cardTealAccent,
      ];
      final colorIndex = gradedCourses.indexOf(c) % colors.length;
      return BarChartData(
        label: c.code.length > 4 ? c.code.substring(0, 4) : c.code,
        value: c.currentGrade,
        color: colors[colorIndex],
      );
    }).toList();

    return DashboardCard(
      backgroundColor: context.surface,
      borderRadius: DesignTokens.radiusLG,
      padding: const EdgeInsets.all(DesignTokens.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryLavender.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.chart_bar,
                  size: 16,
                  color: DesignTokens.primaryLavender,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Academic Progress Details',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StudyBarChart(
            data: barData,
            maxHeight: 140,
            yMax: 4.0,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformance(
      BuildContext context, List<CourseEntity> courses) {
    if (courses.isEmpty) {
      return DashboardCard(
        backgroundColor: context.surface,
        borderRadius: DesignTokens.radiusLG,
        padding: const EdgeInsets.all(DesignTokens.spacingLG),
        child: Center(
          child: Text(
            'Add courses to see performance',
            style: TextStyle(
              fontSize: 13,
              color: context.textTertiary,
            ),
          ),
        ),
      );
    }

    return DashboardCard(
      backgroundColor: context.surface,
      borderRadius: DesignTokens.radiusLG,
      padding: const EdgeInsets.all(DesignTokens.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Performance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...courses.map((course) {
            final percentage = course.currentGrade > 0
                ? (course.currentGrade / 4.0 * 100).clamp(0, 100)
                : 0.0;
            final letter = GradeCalculator.gpaToLetter(course.currentGrade);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(course.colorValue).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      CupertinoIcons.book,
                      size: 18,
                      color: Color(course.colorValue),
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
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 6,
                            backgroundColor: context.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percentage >= 80
                                  ? DesignTokens.cardGreenAccent
                                  : percentage >= 60
                                      ? DesignTokens.cardCreamAccent
                                      : DesignTokens.cardPinkAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        letter,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
