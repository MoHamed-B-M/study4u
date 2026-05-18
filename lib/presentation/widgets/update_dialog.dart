import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator;
import 'package:open_filex/open_filex.dart';
import '../../core/services/update_service.dart';

class UpdateDialog {
  static Future<void> show({
    required BuildContext context,
    required UpdateInfo update,
  }) async {
    return showCupertinoDialog(
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
    return CupertinoAlertDialog(
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
        Text(
          'v${widget.update.latestVersion}',
          style: const TextStyle(fontSize: 16, color: CupertinoColors.systemBlue),
        ),
        if (widget.update.releaseNotes != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
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
            child: Text(_error!, style: const TextStyle(color: CupertinoColors.systemRed, fontSize: 13)),
          ),
        const SizedBox(height: 8),
        Text('$percent%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: CupertinoColors.systemGrey6,
            valueColor: const AlwaysStoppedAnimation(CupertinoColors.systemBlue),
          ),
        ),
      ],
    );
  }

  List<CupertinoDialogAction> _buildActions() {
    if (_error != null) {
      return [
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ];
    }
    if (_downloadProgress != null) {
      return [];
    }
    return [
      CupertinoDialogAction(
        child: const Text('Ignore'),
        onPressed: () => Navigator.of(context).pop(),
      ),
      CupertinoDialogAction(
        isDefaultAction: true,
        child: const Text('Download'),
        onPressed: _startDownload,
      ),
    ];
  }
}
