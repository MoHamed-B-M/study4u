import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import '../../core/services/update_service.dart';

class UpdateDialog {
  static Future<void> show({
    required BuildContext context,
    required UpdateInfo update,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UpdateDialogContent(update: update),
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
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: _downloadProgress == null
          ? _buildInfo(scheme)
          : _buildProgress(scheme),
    );
  }

  Widget _buildInfo(ColorScheme scheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.system_update, color: scheme.primary, size: 32),
        ),
        const SizedBox(height: 20),
        Text(
          'Update Available',
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'v${widget.update.latestVersion}',
          style: GoogleFonts.outfit(fontSize: 16, color: scheme.primary),
        ),
        if (widget.update.releaseNotes != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.update.releaseNotes!,
              style: const TextStyle(fontSize: 13),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Ignore',
                  style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.7)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _startDownload,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Download'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgress(ColorScheme scheme) {
    final progress = (_downloadProgress ?? 0.0).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: _error != null
              ? Icon(Icons.error_outline, color: scheme.error, size: 32)
              : Icon(Icons.downloading, color: scheme.primary, size: 32),
        ),
        const SizedBox(height: 20),
        Text(
          _error != null ? 'Download Failed' : 'Downloading...',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_error!, style: TextStyle(color: scheme.error, fontSize: 13)),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(scheme.primary),
          ),
        ),
        const SizedBox(height: 8),
        Text('$percent%', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
        if (_error != null) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ],
    );
  }
}
