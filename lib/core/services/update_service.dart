import 'dart:convert';
import 'dart:io';
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

class UpdateService {
  static const _apiUrl = 'https://api.github.com/repos/MoHamed-B-M/study4u/releases/latest';

  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final body = data['body'] as String?;
      final assets = data['assets'] as List<dynamic>? ?? [];

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
    } catch (_) {
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
