import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parallax_onboarding/parallax_onboarding.dart';
import '../../theme/theme_provider.dart';
import '../../../main.dart';

class FeaturePreviewScreen extends ConsumerWidget {
  const FeaturePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF111625) : const Color(0xFFF5F5F5);
    final green = const Color(0xFF4ADE80);

    void finish() {
      ref.read(settingsProvider.notifier).setOnboardingComplete(true);
      HapticFeedback.mediumImpact();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ProviderScope(child: Stdy4uApp()),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }

    return ParallaxOnboarding(
      onDone: finish,
      onSkip: finish,
      pages: [
        OnboardingPage(
          background: ColoredBox(color: bgColor),
          backgroundFactor: -0.2,
          content: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Focus Timer',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Stay in the zone with customizable\nPomodoro sessions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: Icon(Icons.timer_outlined, size: 120, color: green),
          ),
          foregroundFactor: 0.35,
          foregroundAlignment: Alignment.topCenter,
        ),
        OnboardingPage(
          background: ColoredBox(color: bgColor),
          backgroundFactor: -0.2,
          content: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Never miss a class with\nautomated reminders',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: Icon(Icons.calendar_month_outlined, size: 120, color: green),
          ),
          foregroundFactor: 0.35,
          foregroundAlignment: Alignment.topCenter,
        ),
        OnboardingPage(
          background: ColoredBox(color: bgColor),
          backgroundFactor: -0.2,
          content: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CGPA Tracker',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Track your grades and\nstay ahead of your goals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: Icon(Icons.school_outlined, size: 120, color: green),
          ),
          foregroundFactor: 0.35,
          foregroundAlignment: Alignment.topCenter,
        ),
      ],
    );
  }
}
