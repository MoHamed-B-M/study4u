import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme_provider.dart';
import '../../../main.dart';

class FeaturePreviewScreen extends ConsumerStatefulWidget {
  const FeaturePreviewScreen({super.key});

  @override
  ConsumerState<FeaturePreviewScreen> createState() => _FeaturePreviewScreenState();
}

class _FeaturePreviewScreenState extends ConsumerState<FeaturePreviewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _continue() {
    ref.read(settingsProvider.notifier).setOnboardingComplete(true);
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ProviderScope(child: Stdy4uApp()),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sceneLabel = _SceneLabel(
      value: _ctrl.value,
      sceneA: 'Focus Timer',
      sceneB: 'Schedule',
      sceneC: 'Tasks',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF111625),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            Transform.scale(
              scale: 1.3,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 220,
                    height: 330,
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, _) => Stack(
                        children: [
                          _SceneAPomodoro(value: _ctrl.value),
                          _SceneBSchedule(value: _ctrl.value),
                          _SceneCTasks(value: _ctrl.value),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    sceneLabel.label,
                    style: const TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = sceneLabel.index == i;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF4ADE80)
                              : const Color(0xFF4ADE80).withAlpha(51),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'START APPLICATION',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneLabel {
  final String label;
  final int index;
  _SceneLabel({
    required double value,
    required String sceneA,
    required String sceneB,
    required String sceneC,
  })  : index = value < 1 / 3 ? 0 : value < 2 / 3 ? 1 : 2,
        label = value < 1 / 3 ? sceneA : value < 2 / 3 ? sceneB : sceneC;
}

double _tremap(double t, double start, double end) {
  if (t < start) return 0.0;
  if (t > end) return 1.0;
  return (t - start) / (end - start);
}

Color _green(double opacity) => const Color(0xFF4ADE80).withOpacity(opacity);

class _SceneAPomodoro extends StatelessWidget {
  final double value;
  const _SceneAPomodoro({required this.value});

  @override
  Widget build(BuildContext context) {
    final local = _tremap(value, 0.0, 1 / 3);
    final opacity = local < 0.8 ? (local / 0.8).clamp(0.0, 1.0) : (1.0 - (local - 0.8) / 0.2).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();

    final progress = (local * 3).clamp(0.0, 1.0);
    final pulseT = _tremap(local, 0.65, 1.0);
    final pulseScale = 1.0 + pulseT * 0.5;
    final pulseOpacity = (1.0 - pulseT).clamp(0.0, 1.0) * 0.3;

    final displaySeconds = ((1.0 - progress) * 25 * 60).round();
    final displayMin = (displaySeconds / 60).floor().toString().padLeft(2, '0');
    final displaySec = (displaySeconds % 60).toString().padLeft(2, '0');

    return Opacity(
      opacity: opacity,
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(100, 100),
                painter: _RingPainter(
                  progress: progress,
                  color: const Color(0xFF4ADE80),
                  trackColor: const Color(0xFF4ADE80).withAlpha(38),
                ),
              ),
              Transform.scale(
                scale: pulseScale,
                child: Opacity(
                  opacity: pulseOpacity,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _green(0.3), width: 2),
                    ),
                  ),
                ),
              ),
              Text(
                progress >= 1.0 ? '\u2713' : '$displayMin:$displaySec',
                style: TextStyle(
                  color: _green(0.9),
                  fontSize: progress >= 1.0 ? 32 : 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter({required this.progress, required this.color, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    paint.color = trackColor;
    canvas.drawCircle(center, radius, paint);

    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _SceneBSchedule extends StatelessWidget {
  final double value;
  const _SceneBSchedule({required this.value});

  @override
  Widget build(BuildContext context) {
    final local = _tremap(value, 1 / 3, 2 / 3);
    final opacity = local < 0.85 ? (local / 0.85).clamp(0.0, 1.0) : (1.0 - (local - 0.85) / 0.15).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();

    return Opacity(
      opacity: opacity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ScheduleCard(
              delay: 0.0,
              local: local,
              code: 'MATH 201',
              name: 'Advanced Calculus',
              time: '09:00 AM',
            ),
            const SizedBox(height: 10),
            _ScheduleCard(
              delay: 0.2,
              local: local,
              code: 'PHY 101',
              name: 'Physics',
              time: '11:00 AM',
              showCheck: true,
            ),
            const SizedBox(height: 10),
            _ScheduleCard(
              delay: 0.4,
              local: local,
              code: 'CSC 301',
              name: 'Data Structures',
              time: '02:00 PM',
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final double delay;
  final double local;
  final String code;
  final String name;
  final String time;
  final bool showCheck;

  const _ScheduleCard({
    required this.delay,
    required this.local,
    required this.code,
    required this.name,
    required this.time,
    this.showCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardT = ((local - delay) / 0.3).clamp(0.0, 1.0);
    final slideX = 60.0 * (1.0 - Curves.elasticOut.transform(cardT));
    final cardOpacity = cardT.clamp(0.0, 1.0);
    final checkT = showCheck ? ((local - 0.3) / 0.2).clamp(0.0, 1.0) : 0.0;
    final checkScale = Curves.elasticOut.transform(checkT);

    return Transform.translate(
      offset: Offset(-slideX, 0),
      child: Opacity(
        opacity: cardOpacity,
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: _green(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _green(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(code, style: TextStyle(color: _green(0.9), fontSize: 9, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 1),
                    Text(name, style: TextStyle(color: _green(0.5), fontSize: 7), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(time, style: TextStyle(color: _green(0.4), fontSize: 7)),
                  ],
                ),
              ),
              if (showCheck)
                Transform.scale(
                  scale: checkScale,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _green(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Color(0xFF111625)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SceneCTasks extends StatelessWidget {
  final double value;
  const _SceneCTasks({required this.value});

  @override
  Widget build(BuildContext context) {
    final local = _tremap(value, 2 / 3, 1.0);
    final opacity = local < 0.85 ? (local / 0.85).clamp(0.0, 1.0) : (1.0 - (local - 0.85) / 0.15).clamp(0.0, 1.0);
    if (opacity <= 0) return const SizedBox.shrink();

    return Opacity(
      opacity: opacity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final gridT = ((local - i * 0.08) / 0.2).clamp(0.0, 1.0);
                return Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  child: Opacity(
                    opacity: gridT,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _green(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _green(0.15)),
                      ),
                      child: Icon(Icons.description_outlined, size: 14, color: _green(0.5)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            _FallingCircle(delay: 0.1, local: local, bottomY: 70, size: 12),
            const SizedBox(height: 4),
            _FallingCircle(delay: 0.25, local: local, bottomY: 70, size: 10),
            const SizedBox(height: 4),
            _FallingCircle(delay: 0.4, local: local, bottomY: 70, size: 14),
          ],
        ),
      ),
    );
  }
}

class _FallingCircle extends StatelessWidget {
  final double delay;
  final double local;
  final double bottomY;
  final double size;

  const _FallingCircle({
    required this.delay,
    required this.local,
    required this.bottomY,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final t = ((local - delay) / 0.2).clamp(0.0, 1.0);
    final fallY = t < 0.8
        ? -(bottomY * (1.0 - t / 0.8))
        : -(bottomY * (1.0 - Curves.elasticOut.transform((t - 0.8) / 0.2)));

    return Transform.translate(
      offset: Offset(0, fallY),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _green(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: _green(0.4), width: 1),
        ),
      ),
    );
  }
}
