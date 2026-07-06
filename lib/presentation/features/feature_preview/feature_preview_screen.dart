// BATTERY_OPT: import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

    // BATTERY_OPT: void _showBatteryHelp(BuildContext ctx, bool dark) {
    //   showDialog(
    //     context: ctx,
    //     builder: (dCtx) => AlertDialog(
    //       backgroundColor: dark ? ComicTheme.darkPulp : ComicTheme.paperBg,
    //       title: Text('Battery Settings',
    //         style: TextStyle(
    //           color: dark ? ComicTheme.darkText : ComicTheme.inkBlack,
    //           fontWeight: FontWeight.w700,
    //         ),
    //       ),
    //       content: Text(
    //         'Please go to Settings → Apps → study4u → Battery and disable battery optimization manually.',
    //         style: TextStyle(
    //           color: dark ? ComicTheme.darkText : ComicTheme.inkBlack,
    //         ),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(dCtx),
    //           child: const Text('OK'),
    //         ),
    //       ],
    //     ),
    //   );
    // }

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
        // BATTERY_OPT: OnboardingPage(
        // BATTERY_OPT:   background: ColoredBox(color: bgColor),
        // BATTERY_OPT:   backgroundFactor: -0.4,
        // BATTERY_OPT:   content: _comicContent(
        // BATTERY_OPT:     'Battery Optimization',
        // BATTERY_OPT:     'Disable battery optimization for\nreliable notifications & focus sessions',
        // BATTERY_OPT:     action: _PermissionButton(
        // BATTERY_OPT:       label: 'Auto Start',
        // BATTERY_OPT:       onTap: () async {
        // BATTERY_OPT:         try {
        // BATTERY_OPT:           await DisableBatteryOptimization.showEnableAutoStartSettings(
        // BATTERY_OPT:             'Enable Auto Start',
        // BATTERY_OPT:             'Follow the steps and enable the auto start of this app',
        // BATTERY_OPT:           );
        // BATTERY_OPT:         } catch (e) {
        // BATTERY_OPT:           if (context.mounted) _showBatteryHelp(context, isDark);
        // BATTERY_OPT:         }
        // BATTERY_OPT:       },
        // BATTERY_OPT:     ),
        // BATTERY_OPT:   ),
        // BATTERY_OPT:   foreground: Padding(
        // BATTERY_OPT:     padding: const EdgeInsets.all(32),
        // BATTERY_OPT:     child: _foregroundIcon(Icons.power_settings_new),
        // BATTERY_OPT:   ),
        // BATTERY_OPT:   foregroundFactor: -0.1,
        // BATTERY_OPT:   foregroundAlignment: Alignment(0, -0.6),
        // BATTERY_OPT: ),
        // BATTERY_OPT: OnboardingPage(
        // BATTERY_OPT:   background: ColoredBox(color: bgColor),
        // BATTERY_OPT:   backgroundFactor: -0.4,
        // BATTERY_OPT:   content: _comicContent(
        // BATTERY_OPT:     'Battery Saver',
        // BATTERY_OPT:     'Disable manufacturer battery optimization\nfor smooth background operation',
        // BATTERY_OPT:     action: _PermissionButton(
        // BATTERY_OPT:       label: 'Disable Optimization',
        // BATTERY_OPT:       onTap: () async {
        // BATTERY_OPT:         try {
        // BATTERY_OPT:           final isDisabled = await DisableBatteryOptimization
        // BATTERY_OPT:               .isManufacturerBatteryOptimizationDisabled;
        // BATTERY_OPT:           if (isDisabled != true) {
        // BATTERY_OPT:             await DisableBatteryOptimization
        // BATTERY_OPT:                 .showDisableManufacturerBatteryOptimizationSettings(
        // BATTERY_OPT:               'Your device has additional battery optimization',
        // BATTERY_OPT:               'Follow the steps and disable the optimizations to allow smooth functioning of this app',
        // BATTERY_OPT:             );
        // BATTERY_OPT:           }
        // BATTERY_OPT:         } catch (e) {
        // BATTERY_OPT:           if (context.mounted) _showBatteryHelp(context, isDark);
        // BATTERY_OPT:         }
        // BATTERY_OPT:       },
        // BATTERY_OPT:     ),
        // BATTERY_OPT:   ),
        // BATTERY_OPT:   foreground: Padding(
        // BATTERY_OPT:     padding: const EdgeInsets.all(32),
        // BATTERY_OPT:     child: _foregroundIcon(Icons.battery_charging_full),
        // BATTERY_OPT:   ),
        // BATTERY_OPT:   foregroundFactor: -0.1,
        // BATTERY_OPT:   foregroundAlignment: Alignment(0, -0.6),
        // BATTERY_OPT: ),
      ],
    );
  }
}

// BATTERY_OPT: class _PermissionButton extends StatefulWidget {
// BATTERY_OPT:   final String label;
// BATTERY_OPT:   final Future<void> Function() onTap;
// BATTERY_OPT: 
// BATTERY_OPT:   const _PermissionButton({
// BATTERY_OPT:     required this.label,
// BATTERY_OPT:     required this.onTap,
// BATTERY_OPT:   });
// BATTERY_OPT: 
// BATTERY_OPT:   @override
// BATTERY_OPT:   State<_PermissionButton> createState() => _PermissionButtonState();
// BATTERY_OPT: }
// BATTERY_OPT: 
// BATTERY_OPT: class _PermissionButtonState extends State<_PermissionButton> {
// BATTERY_OPT:   bool _loading = false;
// BATTERY_OPT: 
// BATTERY_OPT:   @override
// BATTERY_OPT:   Widget build(BuildContext context) {
// BATTERY_OPT:     final isDark = Theme.of(context).brightness == Brightness.dark;
// BATTERY_OPT:     return GestureDetector(
// BATTERY_OPT:       onTap: _loading
// BATTERY_OPT:           ? null
// BATTERY_OPT:           : () async {
// BATTERY_OPT:               setState(() => _loading = true);
// BATTERY_OPT:               try {
// BATTERY_OPT:                 await widget.onTap();
// BATTERY_OPT:               } finally {
// BATTERY_OPT:                 if (mounted) setState(() => _loading = false);
// BATTERY_OPT:               }
// BATTERY_OPT:             },
// BATTERY_OPT:       child: AnimatedContainer(
// BATTERY_OPT:         duration: const Duration(milliseconds: 100),
// BATTERY_OPT:         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// BATTERY_OPT:         decoration: BoxDecoration(
// BATTERY_OPT:           color: _loading
// BATTERY_OPT:               ? (isDark ? ComicTheme.darkText : ComicTheme.surfaceWhite)
// BATTERY_OPT:               : ComicTheme.inkRed,
// BATTERY_OPT:           border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
// BATTERY_OPT:           boxShadow: _loading
// BATTERY_OPT:               ? []
// BATTERY_OPT:               : [
// BATTERY_OPT:                   BoxShadow(
// BATTERY_OPT:                     color: ComicTheme.inkBlack,
// BATTERY_OPT:                     offset: const Offset(4, 4),
// BATTERY_OPT:                     blurRadius: 0,
// BATTERY_OPT:                   ),
// BATTERY_OPT:                 ],
// BATTERY_OPT:         ),
// BATTERY_OPT:         child: _loading
// BATTERY_OPT:             ? SizedBox(
// BATTERY_OPT:                 width: 16,
// BATTERY_OPT:                 height: 16,
// BATTERY_OPT:                 child: CircularProgressIndicator(
// BATTERY_OPT:                   strokeWidth: 2,
// BATTERY_OPT:                   valueColor: AlwaysStoppedAnimation<Color>(
// BATTERY_OPT:                     isDark ? ComicTheme.darkPulp : ComicTheme.inkBlack,
// BATTERY_OPT:                   ),
// BATTERY_OPT:                 ),
// BATTERY_OPT:               )
// BATTERY_OPT:             : Text(
// BATTERY_OPT:                 widget.label,
// BATTERY_OPT:                 style: TextStyle(
// BATTERY_OPT:                   fontSize: 14,
// BATTERY_OPT:                   fontWeight: FontWeight.w700,
// BATTERY_OPT:                   color: ComicTheme.surfaceWhite,
// BATTERY_OPT:                 ),
// BATTERY_OPT:               ),
// BATTERY_OPT:       ),
// BATTERY_OPT:     );
// BATTERY_OPT:   }
// BATTERY_OPT: }
