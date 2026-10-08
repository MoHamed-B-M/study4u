import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:parallax_onboarding/parallax_onboarding.dart';
import '../../../data/platform/settings_bridge.dart';
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

    Widget _comicContent(String title, String subtitle, {Widget? action}) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
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
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.luckiestGuy(
                  fontSize: 26,
                  color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                  height: 1.2,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? ComicTheme.darkText.withValues(alpha: 0.6)
                      : ComicTheme.inkBlack.withValues(alpha: 0.54),
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
              ),
              if (action != null) ...[
                const SizedBox(height: 20),
                action,
              ],
            ],
          ),
        ),
      );
    }

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

    Widget _foregroundIcon(IconData icon) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: ComicTheme.inkBlack,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, size: 80, color: accent),
      );
    }

    return ParallaxOnboarding(
      onDone: finish,
      onSkip: finish,
      pages: [
        OnboardingPage(
          background: ColoredBox(color: bgColor),
          backgroundFactor: -0.3,
          content: _comicContent(
            'Focus Timer',
            'Stay in the zone with customizable\nPomodoro sessions',
          ),
          foreground: Padding(
            padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
            child: _foregroundIcon(Icons.timer_outlined),
          ),
          foregroundFactor: 0.1,
          foregroundAlignment: Alignment(0, -0.6),
        ),
        OnboardingPage(
          background: ColoredBox(color: bgColor),
          backgroundFactor: -0.4,
          content: _comicContent(
            'Schedule',
            'Never miss a class with\nautomated reminders',
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: _foregroundIcon(Icons.calendar_month_outlined),
          ),
          foregroundFactor: 0.1,
          foregroundAlignment: Alignment(0, -0.6),
        ),
        OnboardingPage(
          background: ColoredBox(color: bgColor),
          backgroundFactor: -0.4,
          content: _comicContent(
            'CGPA Tracker',
            'Track your grades and\nstay ahead of your goals',
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: _foregroundIcon(Icons.school_outlined),
          ),
          foregroundFactor: 0.1,
          foregroundAlignment: Alignment(0, -0.6),
        ),
        OnboardingPage(
          background: ColoredBox(color: bgColor),
          backgroundFactor: -0.3,
          content: _comicContent(
            'Usage Access',
            'Allow study4u to view your usage\nstatistics for insightful analytics',
            action: _PermissionButton(
              label: 'Open Settings',
              onTap: () async {
                try {
                  final info = await PackageInfo.fromPlatform();
                  final opened = await SettingsBridge.openAppSettings(packageName: info.packageName);
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please open Settings manually'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: ComicTheme.inkRed,
                      ),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please open Settings manually'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: ComicTheme.inkRed,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: _foregroundIcon(Icons.analytics_outlined),
          ),
          foregroundFactor: -0.1,
          foregroundAlignment: Alignment(0, -0.6),
        ),
        OnboardingPage(
          background: ColoredBox(color: bgColor),
          backgroundFactor: -0.4,
          content: _comicContent(
            'Battery Optimization',
            'Disable battery optimization for\nreliable notifications & focus sessions',
            action: _PermissionButton(
              label: 'Open Settings',
              onTap: () async {
                try {
                  final info = await PackageInfo.fromPlatform();
                  final opened = await SettingsBridge.openAppSettings(packageName: info.packageName);
                  if (!opened && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please open Settings manually'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: ComicTheme.inkRed,
                      ),
                    );
                  }
                } catch (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please open Settings manually'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: ComicTheme.inkRed,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          foreground: Padding(
            padding: const EdgeInsets.all(32),
            child: _foregroundIcon(Icons.battery_charging_full),
          ),
          foregroundFactor: -0.1,
          foregroundAlignment: Alignment(0, -0.6),
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
