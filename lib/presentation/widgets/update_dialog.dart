import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import '../../core/services/update_service.dart';
import '../../theme/comic_theme.dart';

class UpdateDialog {
  static Future<void> show({
    required BuildContext context,
    required UpdateInfo update,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).dialogLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: Center(
            child: _UpdateDialogContent(update: update),
          ),
        );
      },
    );
  }
}

class _UpdateDialogContent extends StatefulWidget {
  final UpdateInfo update;
  const _UpdateDialogContent({required this.update});

  @override
  State<_UpdateDialogContent> createState() => _UpdateDialogContentState();
}

class _UpdateDialogContentState extends State<_UpdateDialogContent> {
  final _service = UpdateService();
  double? _downloadProgress;
  String? _error;

  Future<void> _startDownload() async {
    setState(() => _downloadProgress = 0.0);
    try {
      final path = await _service.downloadApk(
        url: widget.update.downloadUrl,
        onProgress: (p) {
          if (mounted) setState(() => _downloadProgress = p);
        },
      );
      await OpenFilex.open(path);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.88),
      child: Container(
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
        child: _downloadProgress == null && _error == null
            ? _buildInfo(isDark)
            : _buildProgressOrError(isDark),
      ),
    );
  }

  Widget _buildInfo(bool isDark) {
    final hasNotes = widget.update.releaseNotes != null &&
        widget.update.releaseNotes!.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isDark ? ComicTheme.darkSurface : ComicTheme.surfaceWhite,
            border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
          ),
          child: Icon(
            Icons.download_rounded,
            color: ComicTheme.inkRed,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'UPDATE\nAVAILABLE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'v${widget.update.latestVersion}',
          style: TextStyle(
            color: ComicTheme.inkRed,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (hasNotes) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: isDark
                    ? ComicTheme.darkSurface
                    : ComicTheme.surfaceWhite,
                border: Border.all(color: ComicTheme.inkBlack, width: 2),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.update.releaseNotes!,
                  style: TextStyle(
                    color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _ComicDialogButton(
                  label: 'Ignore',
                  isCta: false,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ComicDialogButton(
                  label: 'Download',
                  isCta: true,
                  icon: Icons.download_rounded,
                  onTap: _startDownload,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProgressOrError(bool isDark) {
    final progress = (_downloadProgress ?? 0.0).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();
    final isError = _error != null;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isError
                  ? ComicTheme.inkRed.withValues(alpha: 0.2)
                  : (isDark ? ComicTheme.darkSurface : ComicTheme.surfaceWhite),
              border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
            ),
            child: Icon(
              isError ? Icons.error_outline : Icons.download_rounded,
              color: isError ? ComicTheme.inkRed : ComicTheme.inkRed,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isError ? 'Download Failed' : 'Downloading...',
            style: TextStyle(
              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isError) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                color: ComicTheme.inkRed.withValues(alpha: 0.8),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _ComicDialogButton(
              label: 'Close',
              isCta: false,
              onTap: () => Navigator.of(context).pop(),
            ),
          ] else ...[
            const SizedBox(height: 24),
            Text(
              '$percent%',
              style: TextStyle(
                color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: isDark ? ComicTheme.darkSurface : ComicTheme.paperBg,
                border: Border.all(color: ComicTheme.inkBlack, width: 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: ComicTheme.inkRed,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComicDialogButton extends StatefulWidget {
  final String label;
  final bool isCta;
  final IconData? icon;
  final VoidCallback onTap;

  const _ComicDialogButton({
    required this.label,
    required this.isCta,
    this.icon,
    required this.onTap,
  });

  @override
  State<_ComicDialogButton> createState() => _ComicDialogButtonState();
}

class _ComicDialogButtonState extends State<_ComicDialogButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = widget.isCta
        ? ComicTheme.inkRed
        : (isDark ? ComicTheme.darkSurface : ComicTheme.surfaceWhite);
    final pressedBg = widget.isCta
        ? ComicTheme.inkRed.withValues(alpha: 0.7)
        : (isDark ? ComicTheme.darkText.withValues(alpha: 0.2) : ComicTheme.inkBlack.withValues(alpha: 0.1));
    final textColor = widget.isCta
        ? ComicTheme.surfaceWhite
        : (isDark ? ComicTheme.darkText : ComicTheme.inkBlack);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
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
