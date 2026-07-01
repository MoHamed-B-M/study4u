import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:parallax_onboarding/parallax_onboarding.dart';
import '../../../theme/comic_theme.dart';
import '../../theme/theme_provider.dart';
import '../../../main.dart';

class FeaturePreviewScreen extends ConsumerWidget {
  const FeaturePreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? ComicTheme.darkPulp : ComicTheme.paperBg;
    final accent = ComicTheme.inkRed;

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
                    color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Stay in the zone with customizable\nPomodoro sessions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? ComicTheme.darkText.withValues(alpha: 0.6)
                        : ComicTheme.inkBlack.withValues(alpha: 0.54),
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          foreground: Padding(
            padding: const EdgeInsets.fromLTRB(32, 56, 32, 32),
            child: Icon(Icons.timer_outlined, size: 120, color: accent),
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
                    color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Never miss a class with\nautomated reminders',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? ComicTheme.darkText.withValues(alpha: 0.6)
                        : ComicTheme.inkBlack.withValues(alpha: 0.54),
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: Icon(Icons.calendar_month_outlined, size: 120, color: accent),
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
                    color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Track your grades and\nstay ahead of your goals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? ComicTheme.darkText.withValues(alpha: 0.6)
                        : ComicTheme.inkBlack.withValues(alpha: 0.54),
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: Icon(Icons.school_outlined, size: 120, color: accent),
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
                  'Usage Access',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Allow study4u to view your usage\nstatistics for insightful analytics',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? ComicTheme.darkText.withValues(alpha: 0.6)
                        : ComicTheme.inkBlack.withValues(alpha: 0.54),
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 24),
                _PermissionButton(
                  label: 'Open Settings',
                  onTap: () async {
                    final info = await PackageInfo.fromPlatform();
                    await launchUrl(
                      Uri.parse('package:${info.packageName}'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            ),
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: Icon(Icons.analytics_outlined, size: 120, color: accent),
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
                  'Battery Optimization',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                    height: 1.2,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Disable battery optimization for\nreliable notifications & focus sessions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? ComicTheme.darkText.withValues(alpha: 0.6)
                        : ComicTheme.inkBlack.withValues(alpha: 0.54),
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 24),
                _PermissionButton(
                  label: 'Open Settings',
                  onTap: () async {
                    final info = await PackageInfo.fromPlatform();
                    await launchUrl(
                      Uri.parse('package:${info.packageName}'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ],
            ),
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: Icon(Icons.battery_charging_full, size: 120, color: accent),
          ),
          foregroundFactor: 0.35,
          foregroundAlignment: Alignment.topCenter,
        ),
      ],
    );
  }
}

class _PermissionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _PermissionButton({
    required this.label,
    required this.onTap,
  });

  @override
  State<_PermissionButton> createState() => _PermissionButtonState();
}

class _PermissionButtonState extends State<_PermissionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: _pressed
              ? (isDark ? ComicTheme.darkText : ComicTheme.surfaceWhite)
              : ComicTheme.inkRed,
          border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: ComicTheme.inkBlack,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _pressed
                ? (isDark ? ComicTheme.darkPulp : ComicTheme.inkBlack)
                : ComicTheme.surfaceWhite,
          ),
        ),
      ),
    );
  }
}
