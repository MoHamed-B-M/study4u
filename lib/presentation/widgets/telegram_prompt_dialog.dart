import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/comic_theme.dart';

/// Telegram brand blue, reused for the badge, chips and the Join CTA.
const Color _tgBlue = Color(0xFF229ED9);

/// One-time "Join us on Telegram" prompt shown on first app launch.
/// Comic-print styled with Join / Close actions.
class TelegramPromptDialog {
  TelegramPromptDialog._();

  /// Returns a future that completes when the dialog is dismissed.
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _TelegramPromptContent(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TelegramPromptContent extends StatelessWidget {
  const _TelegramPromptContent();

  Future<void> _join(BuildContext context) async {
    Vibrate.feedback(FeedbackType.light);
    final uri = Uri.parse(AppConstants.telegramUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Telegram')),
      );
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? ComicTheme.darkText : ComicTheme.inkBlack;

    return ConstrainedBox(
      // Fixed cap keeps every line comfortable on narrow screens; the outer
      // horizontal padding guarantees the dialog fits any device.
      constraints: const BoxConstraints(maxWidth: 360),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? ComicTheme.darkPulp : ComicTheme.paperBg,
          border: Border.all(color: ComicTheme.inkBlack, width: 3),
          boxShadow: const [
            BoxShadow(
              color: ComicTheme.inkBlack,
              offset: Offset(5, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Hero: telegram-blue band with an overlapping badge ----
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 64,
                  width: double.infinity,
                  color: _tgBlue,
                  child: const _DiagonalStripes(),
                ),
                Positioned(
                  bottom: -28,
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: _tgBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: ComicTheme.inkBlack, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: ComicTheme.inkBlack,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),

            // ---- Body ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'JOIN US ON TELEGRAM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      color: primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Study tips, update news and community help — '
                    'right in your pocket.',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: primaryText.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Wrap (not Row) so chips re-flow instead of overflowing.
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: const [
                      _PerkChip(icon: Icons.trending_up_rounded, label: 'TIPS'),
                      _PerkChip(
                          icon: Icons.rocket_launch_rounded, label: 'UPDATES'),
                      _PerkChip(icon: Icons.forum_rounded, label: 'COMMUNITY'),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: _ComicButton(
                          label: 'Close',
                          isCta: false,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ComicButton(
                          label: 'Join',
                          isCta: true,
                          icon: Icons.send_rounded,
                          onTap: () => _join(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No spam — helpful stuff only.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                      color: primaryText.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Comic-print diagonal stripes used as texture inside the hero band.
class _DiagonalStripes extends StatelessWidget {
  const _DiagonalStripes();

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.14,
      child: CustomPaint(
        painter: _StripePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 7;
    for (double x = -size.height; x < size.width + size.height; x += 16) {
      canvas.drawLine(
          Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tiny bordered chip highlighting a benefit of the channel.
class _PerkChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PerkChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? ComicTheme.darkSurface : ComicTheme.surfaceWhite,
        border: Border.all(color: ComicTheme.inkBlack, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _tgBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComicButton extends StatefulWidget {
  final String label;
  final bool isCta;
  final IconData? icon;
  final VoidCallback onTap;

  const _ComicButton({
    required this.label,
    required this.isCta,
    this.icon,
    required this.onTap,
  });

  @override
  State<_ComicButton> createState() => _ComicButtonState();
}

class _ComicButtonState extends State<_ComicButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = widget.isCta
        ? _tgBlue
        : (isDark ? ComicTheme.darkSurface : ComicTheme.surfaceWhite);
    final pressedBg = widget.isCta
        ? _tgBlue.withValues(alpha: 0.7)
        : (isDark
            ? ComicTheme.darkText.withValues(alpha: 0.2)
            : ComicTheme.inkBlack.withValues(alpha: 0.1));
    final textColor = widget.isCta
        ? Colors.white
        : (isDark ? ComicTheme.darkText : ComicTheme.inkBlack);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Vibrate.feedback(FeedbackType.light);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _pressed ? pressedBg : bgColor,
          border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
          boxShadow: _pressed
              ? []
              : const [
                  BoxShadow(
                    color: ComicTheme.inkBlack,
                    offset: Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 18, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
