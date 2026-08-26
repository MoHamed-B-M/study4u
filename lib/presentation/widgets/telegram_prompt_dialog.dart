import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../theme/comic_theme.dart';

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
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: const Center(
            child: _TelegramPromptContent(),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final primaryText = isDark ? ComicTheme.darkText : ComicTheme.inkBlack;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.85),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? ComicTheme.darkPulp : ComicTheme.paperBg,
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF229ED9).withValues(alpha: 0.12),
                border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Color(0xFF229ED9),
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'JOIN US ON\nTELEGRAM',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                height: 1.15,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Get study tips, update news and community help — '
              'right in your pocket.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: primaryText.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 24),
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
          ],
        ),
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
        ? ComicTheme.inkRed
        : (isDark ? ComicTheme.darkSurface : ComicTheme.surfaceWhite);
    final pressedBg = widget.isCta
        ? ComicTheme.inkRed.withValues(alpha: 0.7)
        : (isDark
            ? ComicTheme.darkText.withValues(alpha: 0.2)
            : ComicTheme.inkBlack.withValues(alpha: 0.1));
    final textColor = widget.isCta
        ? ComicTheme.surfaceWhite
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
