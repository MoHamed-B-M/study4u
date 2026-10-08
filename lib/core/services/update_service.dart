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
  final bool isPreRelease;

  UpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    this.releaseNotes,
    required this.isNewer,
    this.isPreRelease = false,
  });
}

class UpdateService {
  static UpdateInfo? lastKnownUpdate;
  static const _apiUrlStable = 'https://api.github.com/repos/MoHamed-B-M/study4u/releases/latest';
  static const _apiUrlBeta = 'https://api.github.com/repos/MoHamed-B-M/study4u/releases';

  /// Check for updates
  /// [includePreRelease] - If true, checks the latest release including pre-releases (beta).
  ///                       If false (default), checks only the latest stable release.
  Future<UpdateInfo?> checkForUpdate({bool includePreRelease = false}) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      // Use the appropriate API endpoint
      final apiUrl = includePreRelease ? _apiUrlBeta : _apiUrlStable;

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'stdy4u/2.0',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        debugPrint('UpdateService: API returned status ${response.statusCode}');
        return null;
      }

      if (includePreRelease) {
        // For beta, we get a list of releases, find the first non-draft (could be pre-release)
        final releases = jsonDecode(response.body) as List<dynamic>;
        if (releases.isEmpty) return null;

        // Sort by published date descending and take the first one
        releases.sort((a, b) {
          final aDate = DateTime.tryParse(a['published_at'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = DateTime.tryParse(b['published_at'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

        final release = releases.first as Map<String, dynamic>;
        return _parseRelease(release, currentVersion);
      } else {
        // For stable, the 'latest' endpoint already returns the latest non-pre-release
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _parseRelease(data, currentVersion);
      }
    } catch (e, stack) {
      debugPrint('UpdateService.checkForUpdate error: $e\n$stack');
      return null;
    }
  }

  UpdateInfo? _parseRelease(Map<String, dynamic> data, String currentVersion) {
    final tagName = data['tag_name'] as String? ?? '';
    final body = data['body'] as String?;
    final assets = data['assets'] as List<dynamic>? ?? [];
    final isPreRelease = data['prerelease'] as bool? ?? false;
    final isDraft = data['draft'] as bool? ?? false;

    if (isDraft) return null;

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
      isPreRelease: isPreRelease,
    );
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

  Future<String> downloadApk({
    required String url,
    required void Function(double progress) onProgress,
  }) async {
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/study4u_update.apk';
    final file = File(filePath);

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      final totalBytes = response.contentLength;
      var receivedBytes = 0;

      final sink = file.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }
      await sink.flush();
      await sink.close();
    } finally {
      client.close();
    }

    return filePath;
  }
}
