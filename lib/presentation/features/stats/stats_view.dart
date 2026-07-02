import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/animation/m3e_spring.dart';
import '../../../core/utils/grade_calculator.dart';
import '../../../domain/usecases/cgpa_calculator.dart';
import '../../../shared/providers/logic_providers.dart';
import '../../../shared/providers/pomodoro_provider.dart';
import '../../../shared/providers/app_usage_provider.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/pomodoro_session.dart';
import '../../../theme/comic_theme.dart';
import '../../../widgets/comic_card.dart';
import '../../../widgets/comic_button.dart';

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
  late final AnimationController _screenTimeCtrl;
  bool _cgpaTargetExpanded = true;
  bool _screenTimeExpanded = false;
  double? _targetCgpa;

  @override
  void initState() {
    super.initState();
    _fadeCtrl1 = AnimationController(vsync: this);
    _fadeCtrl2 = AnimationController(vsync: this);
    _fadeCtrl3 = AnimationController(vsync: this);
    _fadeCtrl4 = AnimationController(vsync: this);
    _screenTimeCtrl = AnimationController(vsync: this);

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
    _screenTimeCtrl.dispose();
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
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
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
    final s = ref.watch(pomodoroSessionsProvider);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildCgpaCard(context, cgpa, courses, totalCredits),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: _buildPomodoroCard(context, pomodoro, s),
        ),
      ],
    );
  }

  Widget _buildCgpaCard(
    BuildContext context,
    CgpaResult cgpa,
    List<CourseEntity> courses,
    double totalCredits,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? ComicTheme.darkText : ComicTheme.inkBlack;
    return ComicCard(
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school,
                  size: 18,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${cgpa.cgpa.toStringAsFixed(1)} / 4',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: primary,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? ComicTheme.darkText.withValues(alpha: 0.7)
        : ComicTheme.inkBlack.withValues(alpha: 0.7);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: secondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPomodoroCard(
      BuildContext context, PomodoroState pomodoro,
      List<PomodoroSessionEntity> sessions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = switch (pomodoro.status) {
      PomodoroStatus.focus => 'FOCUS',
      PomodoroStatus.shortBreak || PomodoroStatus.longBreak => 'BREAK',
      PomodoroStatus.idle => 'READY',
    };

    return ComicCard(
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: isDark
                      ? ComicTheme.darkText.withValues(alpha: 0.7)
                      : ComicTheme.inkBlack.withValues(alpha: 0.7),
                  size: 18,
                ),
                onPressed: _showPomodoroModal,
                visualDensity: VisualDensity.compact,
                tooltip: 'Open pomodoro controls',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            pomodoro.timerString,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
              fontFeatures: [FontFeature.tabularFigures()],
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? ComicTheme.darkText.withValues(alpha: 0.85)
                  : ComicTheme.inkBlack.withValues(alpha: 0.85),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ComicButton(
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



  void _showSetTargetDialog() {
    HapticFeedback.lightImpact();
    final ctrl = TextEditingController(
      text: _targetCgpa?.toStringAsFixed(2) ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) {
        final dk = Theme.of(ctx).brightness == Brightness.dark;
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: dk ? ComicTheme.darkPulp : ComicTheme.paperBg,
              border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: ComicTheme.inkBlack,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Set Target CGPA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: dk ? ComicTheme.darkText : ComicTheme.inkBlack,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: dk ? ComicTheme.darkSurface : ComicTheme.surfaceWhite,
                    border: Border.all(color: ComicTheme.inkBlack, width: 2),
                  ),
                  child: TextField(
                    controller: ctrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      color: dk ? ComicTheme.darkText : ComicTheme.inkBlack,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. 3.50',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: dk ? ComicTheme.darkText.withValues(alpha: 0.4) : ComicTheme.inkBlack.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    final text = ctrl.text.trim();
                    final val = double.tryParse(text);
                    if (val != null && val >= 0 && val <= 4) {
                      setState(() => _targetCgpa = val);
                      Navigator.pop(ctx);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: ComicTheme.inkRed,
                      border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: ComicTheme.inkBlack,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: ComicTheme.surfaceWhite,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPomodoroModal() {
    HapticFeedback.lightImpact();
    final pomodoro = ref.read(pomodoroProvider);
    final sessions = ref.read(pomodoroSessionsProvider);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final dk = Theme.of(ctx).brightness == Brightness.dark;
        final label = switch (pomodoro.status) {
          PomodoroStatus.focus => 'FOCUS',
          PomodoroStatus.shortBreak || PomodoroStatus.longBreak => 'BREAK',
          PomodoroStatus.idle => 'READY',
        };
        final secondary = dk
            ? ComicTheme.darkText.withValues(alpha: 0.7)
            : ComicTheme.inkBlack.withValues(alpha: 0.7);
        final muted = dk
            ? ComicTheme.darkText.withValues(alpha: 0.5)
            : ComicTheme.inkBlack.withValues(alpha: 0.5);
        final primary = dk ? ComicTheme.darkText : ComicTheme.inkBlack;
        final screenW = MediaQuery.of(ctx).size.width;
        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              constraints: BoxConstraints(maxWidth: screenW * 0.85),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: dk ? ComicTheme.darkPulp : ComicTheme.paperBg,
                border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: ComicTheme.inkBlack,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        'Pomodoro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: ComicTheme.inkRed,
                            border: Border.all(color: ComicTheme.inkBlack, width: 2),
                          ),
                          child: const Icon(Icons.close, size: 16, color: ComicTheme.surfaceWhite),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    pomodoro.timerString,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: primary,
                      fontFeatures: [FontFeature.tabularFigures()],
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: secondary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ComicButton(
                        isCta: true,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          if (pomodoro.isActive) {
                            ref.read(pomodoroProvider.notifier).pauseTimer();
                          } else {
                            ref.read(pomodoroProvider.notifier).startTimer();
                          }
                          Navigator.pop(ctx);
                        },
                        child: Icon(
                          pomodoro.isActive ? Icons.pause : Icons.play_arrow,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ComicButton(
                        isCta: true,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(pomodoroProvider.notifier).resetTimer();
                          Navigator.pop(ctx);
                        },
                        child: const Icon(Icons.restart_alt, size: 18),
                      ),
                      const SizedBox(width: 8),
                      ComicButton(
                        isCta: true,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(pomodoroProvider.notifier).skipSession();
                          Navigator.pop(ctx);
                        },
                        child: const Icon(Icons.nightlight_round, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (sessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No sessions yet',
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                    )
                  else
                    SizedBox(
                      height: 140,
                      child: SingleChildScrollView(
                        child: Column(
                          children: sessions.reversed.take(10).map((s) {
                            final dur = s.durationSeconds;
                            final dh = dur ~/ 3600;
                            final dm = (dur % 3600) ~/ 60;
                            final date = '${s.timestamp.day}/${s.timestamp.month}/${s.timestamp.year}';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(date, style: TextStyle(fontSize: 11, color: secondary)),
                                  Text(
                                    dh > 0 ? '${dh}h ${dm}m' : '${dm}m',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primary),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCgpaTargetCard(BuildContext context, bool isDark) {
    return ComicCard(
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
                    Text(
                      'CGPA Target',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                      ),
                    ),
                    Icon(
                      _cgpaTargetExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: isDark
                          ? ComicTheme.darkText.withValues(alpha: 0.7)
                          : ComicTheme.inkBlack.withValues(alpha: 0.7),
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
            if (_cgpaTargetExpanded) ...[
            const SizedBox(height: 16),
            Center(
              child: Text(
                _targetCgpa != null ? 'Target: ${_targetCgpa!.toStringAsFixed(2)}' : 'No Target CGPA Set',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? ComicTheme.darkText.withValues(alpha: 0.5)
                      : ComicTheme.inkBlack.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showSetTargetDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: ComicTheme.inkRed,
                  border: Border.all(
                      color: ComicTheme.inkBlack, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: ComicTheme.inkBlack,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _targetCgpa != null ? 'Change Target' : 'Set Target (e.g. 3.50)',
                    style: const TextStyle(
                      color: ComicTheme.surfaceWhite,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
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
    final usage = ref.watch(appUsageProvider);

    return ComicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _toggleScreenTime,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  const SizedBox(width: 4),
                  Icon(
                    _screenTimeExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: cs.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: SizeTransition(
              sizeFactor: _screenTimeCtrl,
              axisAlignment: -1,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _buildScreenTimeExpanded(context, usage),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenTimeExpanded(
      BuildContext context, AppUsageState usage) {
    final cs = Theme.of(context).colorScheme;

    if (usage.error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            usage.error!,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    final now = DateTime.now();
    final today = usage.todayTotal;
    final todayStr =
        '${today.inHours}h ${today.inMinutes.remainder(60)}m';

    final topApps = usage.todayUsage.take(6).toList();
    final maxUsage =
        topApps.isNotEmpty ? topApps.first.usage.inMinutes : 1;

    final hourly = List.generate(
      24,
      (h) => h == now.hour ? 85 : (h < now.hour ? (h * 7 + 5) % 100 : 0),
    );
    final maxHourly = hourly.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: Color(0xFF2A2A2A)),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Screen T',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              todayStr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF4ADE80).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '5h 35m less than yesterday',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4ADE80),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(24, (i) {
              final value = hourly[i];
              final isMax = value == maxHourly && value > 0;
              final barHeight = maxHourly > 0
                  ? (value / maxHourly) * 90
                  : 0.0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: barHeight.clamp(2.0, 100.0),
                        decoration: BoxDecoration(
                          color: isMax
                              ? const Color(0xFF4ADE80)
                              : const Color(0xFF4ADE80)
                                  .withValues(alpha: 0.3),
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFF2A2A2A)),
        const SizedBox(height: 12),
        Text(
          'Top Apps',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ...topApps.map((info) {
          final minutes = info.usage.inMinutes;
          final hrs = info.usage.inHours;
          final mins = info.usage.inMinutes.remainder(60);
          final timeStr = hrs > 0 ? '${hrs}h ${mins}m' : '${mins}m';
          final progress =
              maxUsage > 0 ? minutes / maxUsage : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    Icons.smartphone_outlined,
                    size: 16,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: Text(
                    _friendlyAppName(info.appName),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4ADE80)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 52,
                  child: Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _toggleScreenTime() {
    HapticFeedback.lightImpact();
    setState(() => _screenTimeExpanded = !_screenTimeExpanded);
    final reduced = M3ESpring.isReducedMotion(context);
    if (reduced) {
      _screenTimeCtrl.value = _screenTimeExpanded ? 1 : 0;
    } else {
      M3ESpring.animate(
        _screenTimeCtrl,
        to: _screenTimeExpanded ? 1 : 0,
        spring: M3ESpring.spatial(),
      );
    }
    if (_screenTimeExpanded) {
      ref.read(appUsageProvider.notifier).fetchUsage();
    }
  }

  Widget _buildSubjectPerformance(
      BuildContext context, List<CourseEntity> courses) {
    final cs = Theme.of(context).colorScheme;

    if (courses.isEmpty) {
      return ComicCard(
        padding: const EdgeInsets.all(24),
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

    return ComicCard(
      padding: const EdgeInsets.all(24),
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


String _friendlyAppName(String packageName) {
  const names = <String, String>{
    'com.android.chrome': 'Chrome',
    'com.google.android.youtube': 'YouTube',
    'com.instagram.android': 'Instagram',
    'com.twitter.android': 'X',
    'com.facebook.katana': 'Facebook',
    'com.facebook.orca': 'Messenger',
    'com.whatsapp': 'WhatsApp',
    'com.spotify.music': 'Spotify',
    'com.google.android.apps.maps': 'Google Maps',
    'com.google.android.gm': 'Gmail',
    'com.android.vending': 'Play Store',
    'com.google.android.apps.docs': 'Google Docs',
    'com.google.android.apps.photos': 'Google Photos',
    'com.google.android.apps.plus': 'Google+',
    'com.google.android.deskclock': 'Clock',
    'com.android.settings': 'Settings',
    'com.google.android.calculator': 'Calculator',
    'com.google.android.calendar': 'Calendar',
    'com.google.android.apps.messaging': 'Messages',
    'com.android.dialer': 'Phone',
    'com.android.contacts': 'Contacts',
    'com.android.camera2': 'Camera',
    'com.android.gallery3d': 'Gallery',
    'com.android.filemanager': 'Files',
    'com.android.documentsui': 'Files',
    'com.google.android.apps.docs.editors.docs': 'Google Docs',
    'com.google.android.apps.docs.editors.sheets': 'Google Sheets',
    'com.google.android.apps.docs.editors.slides': 'Google Slides',
    'com.google.android.apps.tasks': 'Google Tasks',
    'com.google.android.keep': 'Google Keep',
    'com.google.android.apps.books': 'Google Play Books',
    'com.netflix.mediaclient': 'Netflix',
    'com.snapchat.android': 'Snapchat',
    'com.tiktok': 'TikTok',
    'com.zhiliaoapp.musically': 'TikTok',
    'com.android.systemui': 'System UI',
    'com.example.study4u': 'study4u',
    'com.stdy4u': 'study4u',
  };
  return names[packageName] ?? packageName;
}
