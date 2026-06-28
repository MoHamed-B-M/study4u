import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_bar_m3e/app_bar_m3e.dart';
import 'package:m3e_card_list/m3e_card_list.dart';
import '../../../../core/animation/m3e_spring.dart';
import '../../../../core/utils/grade_calculator.dart';
import '../../../../domain/usecases/cgpa_calculator.dart';
import '../../../../shared/providers/logic_providers.dart';
import '../../../../shared/providers/pomodoro_provider.dart';
import '../../../../domain/entities/course.dart';
import '../../theme/design_tokens.dart';

class StatsView extends ConsumerStatefulWidget {
  const StatsView({super.key});

  @override
  ConsumerState<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends ConsumerState<StatsView>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl1;
  late final AnimationController _fadeCtrl2;
  late final AnimationController _fadeCtrl3;
  late final AnimationController _fadeCtrl4;
  bool _cgpaTargetExpanded = true;

  @override
  void initState() {
    super.initState();
    _fadeCtrl1 = AnimationController(vsync: this);
    _fadeCtrl2 = AnimationController(vsync: this);
    _fadeCtrl3 = AnimationController(vsync: this);
    _fadeCtrl4 = AnimationController(vsync: this);

    if (M3ESpring.isReducedMotion(context)) {
      _fadeCtrl1.value = 1;
      _fadeCtrl2.value = 1;
      _fadeCtrl3.value = 1;
      _fadeCtrl4.value = 1;
    } else {
      M3ESpring.animate(_fadeCtrl1, to: 1, spring: M3ESpring.effects());
      Timer(const Duration(milliseconds: 120), () {
        if (mounted) M3ESpring.animate(_fadeCtrl2, to: 1, spring: M3ESpring.effects());
      });
      Timer(const Duration(milliseconds: 240), () {
        if (mounted) M3ESpring.animate(_fadeCtrl3, to: 1, spring: M3ESpring.effects());
      });
      Timer(const Duration(milliseconds: 360), () {
        if (mounted) M3ESpring.animate(_fadeCtrl4, to: 1, spring: M3ESpring.effects());
      });
    }
  }

  @override
  void dispose() {
    _fadeCtrl1.dispose();
    _fadeCtrl2.dispose();
    _fadeCtrl3.dispose();
    _fadeCtrl4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cgpa = ref.watch(cgpaResultProvider);
    final courses = ref.watch(courseListProvider);
    final pomodoro = ref.watch(pomodoroProvider);
    final sessions = ref.watch(pomodoroSessionsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalCredits =
        courses.fold<double>(0.0, (sum, c) => sum + c.creditHours);
    final totalScreenSeconds =
        sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds);

    return Scaffold(
      appBar: AppBarM3E(
        titleText: 'Statistics',
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
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
                    opacity: _fadeCtrl1,
                    child: _buildHeroGrid(
                        context, cgpa, pomodoro, courses, totalCredits),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeCtrl2,
                    child: _buildCgpaTargetCard(context, isDark),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeCtrl3,
                    child:
                        _buildScreenTime(context, totalScreenSeconds, isDark),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeCtrl4,
                    child: _buildSubjectPerformance(context, courses),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGrid(
    BuildContext context,
    CgpaResult cgpa,
    PomodoroState pomodoro,
    List<CourseEntity> courses,
    double totalCredits,
  ) {
    return Row(
      children: [
        Expanded(child: _buildCgpaCard(context, cgpa, courses, totalCredits)),
        const SizedBox(width: 12),
        Expanded(child: _buildPomodoroCard(context, pomodoro)),
      ],
    );
  }

  Widget _buildCgpaCard(
    BuildContext context,
    CgpaResult cgpa,
    List<CourseEntity> courses,
    double totalCredits,
  ) {
    return M3ECard(
      index: 0,
      position: M3ECardPosition.single,
      outerRadius: 24,
      innerRadius: 24,
      gap: 0,
      color: const Color(0xFF1B5E20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${cgpa.cgpa.toStringAsFixed(1)} / 4',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              _buildMiniStat(Icons.book_outlined, 'Courses ${courses.length}'),
              _buildMiniStat(
                  Icons.credit_card, 'Credits ${totalCredits.toInt()}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildPomodoroCard(BuildContext context, PomodoroState pomodoro) {
    final label = switch (pomodoro.status) {
      PomodoroStatus.focus => 'FOCUS',
      PomodoroStatus.shortBreak || PomodoroStatus.longBreak => 'BREAK',
      PomodoroStatus.idle => 'READY',
    };

    return M3ECard(
      index: 1,
      position: M3ECardPosition.single,
      outerRadius: 24,
      innerRadius: 24,
      gap: 0,
      color: const Color(0xFF2E7D32),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pomodoro.timerString,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                if (pomodoro.isActive) {
                  ref.read(pomodoroProvider.notifier).pauseTimer();
                } else {
                  ref.read(pomodoroProvider.notifier).startTimer();
                }
              },
              child: Text(
                pomodoro.isActive ? 'Pause' : 'Start',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCgpaTargetCard(BuildContext context, bool isDark) {
    return M3ECard(
      index: 2,
      position: M3ECardPosition.single,
      outerRadius: 24,
      innerRadius: 24,
      gap: 0,
      color: const Color(0xFF1E293B),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () =>
                setState(() => _cgpaTargetExpanded = !_cgpaTargetExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CGPA Target',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    _cgpaTargetExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white70,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_cgpaTargetExpanded) ...[
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'No Target CGPA Set',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADE80),
                  foregroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                child: const Text(
                  'Set Target (e.g. 3.50)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScreenTime(BuildContext context, int totalSeconds, bool isDark) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final display = totalSeconds > 0 ? '${hours}h ${minutes}m' : '0h 0m';
    final cs = Theme.of(context).colorScheme;

    return M3ECard(
      index: 3,
      position: M3ECardPosition.single,
      outerRadius: 24,
      innerRadius: 24,
      gap: 0,
      color: cs.surfaceContainerLow,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timer_outlined,
              size: 22,
              color: Color(0xFF4ADE80),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Screen Time',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total focus time',
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              display,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4ADE80),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformance(
      BuildContext context, List<CourseEntity> courses) {
    final cs = Theme.of(context).colorScheme;

    if (courses.isEmpty) {
      return M3ECard(
        index: 4,
        position: M3ECardPosition.single,
        outerRadius: 24,
        innerRadius: 24,
        gap: 0,
        color: cs.surfaceContainerLow,
        padding: const EdgeInsets.all(DesignTokens.spacingLG),
        child: Center(
          child: Text(
            'Add courses to see performance',
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return M3ECard(
      index: 4,
      position: M3ECardPosition.single,
      outerRadius: 24,
      innerRadius: 24,
      gap: 0,
      color: cs.surfaceContainerLow,
      padding: const EdgeInsets.all(DesignTokens.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grade Distribution',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...courses.map((course) {
            final percentage = course.currentGrade > 0
                ? (course.currentGrade / 4.0 * 100).clamp(0, 100)
                : 0.0;
            final letter = GradeCalculator.gpaToLetter(course.currentGrade);
            final barColor = percentage >= 80
                ? const Color(0xFF66BB6A)
                : percentage >= 60
                    ? const Color(0xFFFFB74D)
                    : const Color(0xFFEF5350);

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
                      Icons.book,
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
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 6,
                            backgroundColor: cs.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(barColor),
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
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
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
