import 'dart:async';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../../core/animation/m3e_spring.dart';
import '../../core/services/update_service.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: screenWidth * 0.88),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.surfaceDark
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
        ),
        child: _downloadProgress == null && _error == null
            ? _buildInfo()
            : _buildProgressOrError(),
      ),
    );
  }

  Widget _buildInfo() {
    final hasNotes = widget.update.releaseNotes != null &&
        widget.update.releaseNotes!.trim().isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 32),
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFF334155),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.download_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Update Available',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'v${widget.update.latestVersion}',
          style: const TextStyle(
            color: DesignTokens.primaryLavender,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (hasNotes) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.update.releaseNotes!,
                  style: const TextStyle(
                    color: Colors.white70,
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
                child: _SquishActionButton(
                  onTap: () => Navigator.of(context).pop(),
                  builder: (pressed) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      color: pressed
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.transparent,
                    ),
                    child: const Center(
                      child: Text(
                        'Ignore',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SquishActionButton(
                  onTap: _startDownload,
                  builder: (pressed) => Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9999),
                      color: pressed
                          ? DesignTokens.primaryLavender.withValues(alpha: 0.8)
                          : DesignTokens.primaryLavender,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Download',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProgressOrError() {
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
                  ? AppTheme.warningRed.withValues(alpha: 0.2)
                  : const Color(0xFF334155),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isError ? Icons.error_outline : Icons.download_rounded,
              color: isError ? AppTheme.warningRed : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isError ? 'Download Failed' : 'Downloading...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isError) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                color: AppTheme.warningRed.withValues(alpha: 0.8),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _squishCloseButton(),
          ] else ...[
            const SizedBox(height: 24),
            Text(
              '$percent%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  DesignTokens.primaryLavender,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _squishCloseButton() {
    return _SquishActionButton(
      onTap: () => Navigator.of(context).pop(),
      builder: (pressed) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
          color: pressed
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.1),
        ),
        child: const Text(
          'Close',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SquishActionButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget Function(bool pressed) builder;

  const _SquishActionButton({
    required this.onTap,
    required this.builder,
  });

  @override
  State<_SquishActionButton> createState() => _SquishActionButtonState();
}

class _SquishActionButtonState extends State<_SquishActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _pressed = true);
    if (M3ESpring.isReducedMotion(context)) {
      _controller.value = 1;
    } else {
      M3ESpring.animate(
        _controller,
        to: 1,
        spring: M3ESpring.spatial(stiffness: 600, damping: 14),
      );
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _pressed = false);
    if (M3ESpring.isReducedMotion(context)) {
      _controller.value = 0;
      if (mounted && widget.onTap != null) widget.onTap!();
    } else {
      M3ESpring.animate(
        _controller,
        to: 0,
        spring: M3ESpring.spatial(stiffness: 600, damping: 14),
      ).then((_) {
        if (mounted && widget.onTap != null) widget.onTap!();
      });
    }
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
    if (M3ESpring.isReducedMotion(context)) {
      _controller.value = 0;
    } else {
      M3ESpring.animate(
        _controller,
        to: 0,
        spring: M3ESpring.spatial(stiffness: 600, damping: 14),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: 1.0 - (_controller.value * 0.06),
            child: child,
          ),
          child: widget.builder(_pressed),
        ),
    );
  }
}
