import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/providers/pomodoro_provider.dart';
import '../../shared/providers/logic_providers.dart';
import '../../shared/models/models.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pomodoro = ref.watch(pomodoroProvider);
    final courses = ref.watch(courseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Performance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildCGPACard(context),
            const SizedBox(height: 24),
            _buildPomodoroControl(context, ref, pomodoro),
            const SizedBox(height: 24),
            _buildGradeDistribution(context),
            const SizedBox(height: 24),
            _buildPerformanceOverview(context, courses),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCGPACard(BuildContext context) {
    return FadeInUp(
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CURRENT CGPA', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary.withOpacity(0.5))),
                const Icon(Icons.show_chart, color: AppTheme.primary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('3.84', style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(width: 4),
                Text('/ 4.0', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary.withOpacity(0.3))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.arrow_upward, color: AppTheme.primary, size: 16),
                const SizedBox(width: 4),
                Text('+0.24 this semester', style: GoogleFonts.plusJakartaSans(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPomodoroControl(BuildContext context, WidgetRef ref, PomodoroState state) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('POMODORO', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary.withOpacity(0.5))),
                _buildStatusBadge(state.status),
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
                        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                      ),
                    ),
                  Text(state.timerString, style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIconButton(
                  Icons.replay,
                  () => ref.read(pomodoroProvider.notifier).resetTimer(),
                ),
                const SizedBox(width: 20),
                _buildPlayPauseButton(ref, state),
                const SizedBox(width: 20),
                _buildIconButton(
                  Icons.skip_next,
                  () {}, // Skip logic placeholder
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('${state.completedSessions} sessions today', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PomodoroStatus status) {
    String text;
    Color color;
    switch (status) {
      case PomodoroStatus.focus: text = 'FOCUS'; color = AppTheme.primary; break;
      case PomodoroStatus.shortBreak: text = 'SHORT BREAK'; color = AppTheme.secondary; break;
      case PomodoroStatus.longBreak: text = 'LONG BREAK'; color = AppTheme.tertiary; break;
      default: text = 'READY'; color = AppTheme.textPrimary.withOpacity(0.3);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.background, shape: BoxShape.circle),
        child: Icon(icon, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _buildPlayPauseButton(WidgetRef ref, PomodoroState state) {
    return InkWell(
      onTap: () {
        if (state.isActive) {
          ref.read(pomodoroProvider.notifier).pauseTimer();
        } else {
          ref.read(pomodoroProvider.notifier).startTimer();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: AppTheme.textPrimary, shape: BoxShape.circle),
        child: Icon(state.isActive ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildGradeDistribution(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: AppCard(
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
                  titlesData: const FlTitlesData(show: false),
                  barGroups: [
                    _makeGroupData(0, 8, AppTheme.primary),
                    _makeGroupData(1, 6, AppTheme.secondary),
                    _makeGroupData(2, 4, AppTheme.tertiary),
                    _makeGroupData(3, 2, AppTheme.error),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y, color: color, width: 20, borderRadius: BorderRadius.circular(10)),
      ],
    );
  }

  Widget _buildPerformanceOverview(BuildContext context, List<Course> courses) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subject Performance', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            if (courses.isEmpty) const Text('Add courses to see progress.'),
            ...courses.map((course) => _buildSubjectProgress(course)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectProgress(Course course) {
    // Simulated progress logic
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('92%', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.92,
            backgroundColor: AppTheme.background,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
