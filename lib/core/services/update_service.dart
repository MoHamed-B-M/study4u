import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

enum UpdateChannel { stable, beta }

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

class UpdateService {
  static UpdateInfo? lastKnownUpdate;
  static const _apiUrl = 'https://api.github.com/repos/MoHamed-B-M/study4u/releases?per_page=10';

  Future<UpdateInfo?> checkForUpdate({UpdateChannel channel = UpdateChannel.stable}) async {
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
        if (channel == UpdateChannel.stable && release['prerelease'] == true) {
          continue;
        }
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
      request.followRedirects = true;
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
