import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String latestVersion;
  final String downloadUrl;
  final String? releaseNotes;
  final bool isNewer;

  UpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    this.releaseNotes,
    required this.isNewer,
  });
}

class PauseException implements Exception {}
class CancelException implements Exception {}

class UpdateService {
  static UpdateInfo? lastKnownUpdate;
  static const _apiUrl = 'https://api.github.com/repos/MoHamed-B-M/study4u/releases?per_page=10';
  static const _stateFileName = 'dl_state.json';

  HttpClient? _client;
  StreamSubscription<List<int>>? _sub;
  IOSink? _sink;
  String? _currentUrl;
  String? _currentPath;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  Completer<String>? _completer;

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'stdy4u/2.0',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        debugPrint('UpdateService: API returned status ${response.statusCode}');
        return null;
      }

      final allReleases = jsonDecode(response.body) as List<dynamic>;
      if (allReleases.isEmpty) return null;

      Map<String, dynamic>? latestRelease;
      DateTime? latestDate;
      for (final r in allReleases) {
        final release = r as Map<String, dynamic>;
        final published = DateTime.tryParse(release['published_at'] as String? ?? '');
        if (published != null && (latestDate == null || published.isAfter(latestDate))) {
          latestRelease = release;
          latestDate = published;
        }
      }
      if (latestRelease == null) return null;

      final tagName = latestRelease['tag_name'] as String? ?? '';
      final body = latestRelease['body'] as String?;
      final assets = latestRelease['assets'] as List<dynamic>? ?? [];

      String? downloadUrl;
      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          downloadUrl = asset['browser_download_url'] as String?;
          break;
        }
      }

      final cleanTag = tagName.replaceAll(RegExp(r'^v'), '');
      final isNewer = _isVersionNewer(cleanTag, currentVersion);

      return UpdateInfo(
        latestVersion: cleanTag,
        downloadUrl: downloadUrl ?? '',
        releaseNotes: body,
        isNewer: isNewer,
      );
    } catch (e, stack) {
      debugPrint('UpdateService.checkForUpdate error: $e\n$stack');
      return null;
    }
  }

  bool _isVersionNewer(String latest, String current) {
    try {
      final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen = latestParts.length > currentParts.length
          ? latestParts.length
          : currentParts.length;
      while (latestParts.length < maxLen) { latestParts.add(0); }
      while (currentParts.length < maxLen) { currentParts.add(0); }

      for (int i = 0; i < maxLen; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Download with pause / resume / cancel
  // ---------------------------------------------------------------------------

  /// Returns a [Future<String>] that completes with the APK path when done.
  /// Throws [PauseException] if the download was paused (state saved for resume).
  /// Throws [CancelException] if the download was cancelled.
  Future<String> downloadApk({
    required String url,
    required void Function(double progress) onProgress,
  }) async {
    _currentUrl = url;
    final dir = await getTemporaryDirectory();
    _currentPath = '${dir.path}/study4u_update.apk';

    final saved = await _loadState();
    final startByte = (saved != null && saved['url'] == url)
        ? saved['bytes'] as int
        : 0;

    final file = File(_currentPath!);
    if (startByte == 0 && file.existsSync()) {
      await file.delete();
    }

    _client = HttpClient();
    _completer = Completer<String>();
    try {
      final request = await _client!.getUrl(Uri.parse(url));
      request.followRedirects = true;
      if (startByte > 0) {
        request.headers.set('Range', 'bytes=$startByte-');
      }
      final response = await request.close();

      _totalBytes = response.contentLength + startByte;
      _receivedBytes = startByte;
      _sink = file.openWrite(mode: startByte > 0 ? FileMode.append : FileMode.write);

      _sub = response.listen(
        (chunk) {
          _sink!.add(chunk);
          _receivedBytes += chunk.length;
          if (_totalBytes > 0) onProgress(_receivedBytes / _totalBytes);
        },
        onDone: () async {
          await _sink?.flush();
          await _sink?.close();
          _sink = null;
          _client?.close();
          _client = null;
          await _clearState();
          if (!_completer!.isCompleted) _completer!.complete(_currentPath);
        },
        onError: (e) async {
          await _sink?.close();
          _sink = null;
          _client?.close();
          _client = null;
          if (!_completer!.isCompleted) _completer!.completeError(e);
        },
        cancelOnError: false,
      );
      return _completer!.future;
    } catch (e) {
      _client?.close();
      _client = null;
      _completer!.completeError(e);
      return _completer!.future;
    }
  }

  void pauseDownload() {
    _sub?.cancel();
    _sub = null;
    _sink?.close();
    _sink = null;
    _client?.close();
    _client = null;
    _saveState(_currentUrl!, _receivedBytes);
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(PauseException());
    }
  }

  Future<void> cancelDownload() async {
    await _sub?.cancel();
    _sub = null;
    await _sink?.close();
    _sink = null;
    _client?.close();
    _client = null;
    if (_currentPath != null) {
      final f = File(_currentPath!);
      if (f.existsSync()) await f.delete();
    }
    await _clearState();
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(CancelException());
    }
  }

  bool get hasSavedState => _stateFile.existsSync();

  Map<String, dynamic>? loadSavedState() {
    if (!_stateFile.existsSync()) return null;
    try {
      return jsonDecode(_stateFile.readAsStringSync()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // State persistence
  // ---------------------------------------------------------------------------
  File get _stateFile {
    final dir = Directory.systemTemp;
    return File('${dir.path}/$_stateFileName');
  }

  Future<Map<String, dynamic>?> _loadState() async {
    try {
      if (!_stateFile.existsSync()) return null;
      return jsonDecode(await _stateFile.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveState(String url, int bytes) async {
    try {
      await _stateFile.writeAsString(jsonEncode({
        'url': url,
        'bytes': bytes,
      }));
    } catch (_) {}
  }

  Future<void> _clearState() async {
    try {
      if (_stateFile.existsSync()) await _stateFile.delete();
    } catch (_) {}
  }
}
