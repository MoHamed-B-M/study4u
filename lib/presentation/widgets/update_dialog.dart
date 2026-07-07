import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
  bool _showProgress = false;
  double _downloadProgress = 0.0;
  String? _error;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _checkSavedState();
  }

  void _checkSavedState() {
    try {
      final f = File('${Directory.systemTemp.path}/dl_state.json');
      if (f.existsSync()) {
        final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        if (data['url'] == widget.update.downloadUrl) {
          final bytes = data['bytes'] as int;
          if (bytes > 0) {
            _showProgress = true;
            _isPaused = true;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _startDownload() async {
    setState(() {
      _showProgress = true;
      _isPaused = false;
      _downloadProgress = 0.0;
      _error = null;
    });
    try {
      final path = await _service.downloadApk(
        url: widget.update.downloadUrl,
        onProgress: (p) {
          if (mounted) setState(() => _downloadProgress = p);
        },
      );
      await OpenFilex.open(path);
      if (mounted) Navigator.of(context).pop();
    } on PauseException {
      if (mounted) setState(() => _isPaused = true);
    } on CancelException {
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    }
  }

  void _pause() {
    _service.pauseDownload();
    setState(() => _isPaused = true);
  }

  void _resume() {
    setState(() => _isPaused = false);
    _startDownload();
  }

  void _cancel() async {
    _service.cancelDownload();
    if (mounted) Navigator.of(context).pop();
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
        child: _error != null
            ? _buildError(isDark)
            : _showProgress
                ? _buildProgress(isDark)
                : _buildInfo(isDark),
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
                child: MarkdownBody(
                  data: widget.update.releaseNotes!,
                  selectable: true,
                  shrinkWrap: true,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                      fontSize: 13,
                      height: 0.8,
                    ),
                    h1: TextStyle(
                      color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 0.8,
                    ),
                    h2: TextStyle(
                      color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 0.8,
                    ),
                    h3: TextStyle(
                      color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 0.8,
                    ),
                    code: TextStyle(
                      color: ComicTheme.inkRed,
                      fontSize: 12,
                      backgroundColor: Colors.transparent,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: isDark
                          ? ComicTheme.darkPulp
                          : ComicTheme.paperBg,
                      border: Border.all(color: ComicTheme.inkBlack, width: 1),
                    ),
                    codeblockPadding: const EdgeInsets.all(12),
                    horizontalRuleDecoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: ComicTheme.inkBlack, width: 1),
                      ),
                    ),
                    listBullet: TextStyle(
                      color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                      fontSize: 13,
                    ),
                    strong: TextStyle(
                      color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                      fontWeight: FontWeight.w800,
                    ),
                    em: TextStyle(
                      color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
                      fontStyle: FontStyle.italic,
                    ),
                    a: TextStyle(
                      color: ComicTheme.inkRed,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildProgress(bool isDark) {
    final progress = _downloadProgress.clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDark ? ComicTheme.darkSurface : ComicTheme.surfaceWhite,
              border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
            ),
            child: Icon(
              _isPaused ? Icons.pause_rounded : Icons.download_rounded,
              color: ComicTheme.inkRed,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isPaused ? 'Download Paused' : 'Downloading...',
            style: TextStyle(
              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
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
          ClipRect(
            child: Container(
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
                    color: _isPaused
                        ? ComicTheme.inkBlack.withValues(alpha: 0.4)
                        : ComicTheme.inkRed,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_isPaused) ...[
                Expanded(
                  child: _ComicDialogButton(
                    label: 'Cancel',
                    isCta: false,
                    onTap: _cancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ComicDialogButton(
                    label: 'Resume',
                    isCta: true,
                    icon: Icons.play_arrow_rounded,
                    onTap: _resume,
                  ),
                ),
              ] else ...[
                Expanded(
                  child: _ComicDialogButton(
                    label: 'Cancel',
                    isCta: false,
                    onTap: _cancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ComicDialogButton(
                    label: 'Pause',
                    isCta: true,
                    icon: Icons.pause_rounded,
                    onTap: _pause,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ComicTheme.inkRed.withValues(alpha: 0.2),
              border: Border.all(color: ComicTheme.inkBlack, width: 2.5),
            ),
            child: const Icon(
              Icons.error_outline,
              color: ComicTheme.inkRed,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Download Failed',
            style: TextStyle(
              color: isDark ? ComicTheme.darkText : ComicTheme.inkBlack,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
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
