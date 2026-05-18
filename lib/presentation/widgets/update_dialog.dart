import 'dart:async';
import 'package:flutter/material.dart';
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
    return AlertDialog(
      title: _downloadProgress == null
          ? const Text('Update Available')
          : Text(_error != null ? 'Download Failed' : 'Downloading...'),
      content: _downloadProgress == null
          ? _buildInfo()
          : _buildProgress(),
      actions: _buildActions(),
    );
  }

  Widget _buildInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('v${widget.update.latestVersion}',
          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary)),
        if (widget.update.releaseNotes != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
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
      ],
    );
  }

  Widget _buildProgress() {
    final progress = (_downloadProgress ?? 0.0).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13)),
          ),
        const SizedBox(height: 8),
        Text('$percent%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    if (_error != null) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ];
    }
    if (_downloadProgress != null) {
      return [];
    }
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Ignore'),
      ),
      FilledButton(
        onPressed: _startDownload,
        child: const Text('Download'),
      ),
    ];
  }
}
