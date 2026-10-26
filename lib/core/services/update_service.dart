import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String releaseTitle;
  final String releaseNotes;
  final String? apkDownloadUrl;
  final String? releasePageUrl;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    required this.releaseTitle,
    required this.releaseNotes,
    this.apkDownloadUrl,
    this.releasePageUrl,
  });
}

class UpdateService {
  // Your GitHub repo details: https://github.com/Vivek-k001/DEDO
  static const String repoOwner = 'Vivek-k001';
  static const String repoName = 'DEDO';

  /// Compare two semantic version strings like "1.0.0" and "1.0.1"
  /// Returns 1 if v2 is strictly greater than v1, 0 if equal, -1 if v1 is greater
  static int compareVersions(String v1, String v2) {
    // Strip leading 'v' or 'V' if present
    final cleanV1 = v1.toLowerCase().replaceAll(RegExp(r'[^0-9.]'), '');
    final cleanV2 = v2.toLowerCase().replaceAll(RegExp(r'[^0-9.]'), '');

    final parts1 = cleanV1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = cleanV2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLen = parts1.length > parts2.length ? parts1.length : parts2.length;
    for (int i = 0; i < maxLen; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;
      if (p2 > p1) return 1;
      if (p2 < p1) return -1;
    }
    return 0;
  }

  /// Checks GitHub Releases API for latest published release
  static Future<UpdateInfo> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVer = packageInfo.version; // e.g. "1.0.0"

    final uri = Uri.parse('https://api.github.com/repos/$repoOwner/$repoName/releases/latest');
    
    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Dedo-App-Updater',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rawTag = (data['tag_name'] as String? ?? '').trim();
        final cleanTag = rawTag.replaceAll(RegExp(r'^[vV]'), '');
        final releaseTitle = (data['name'] as String? ?? 'New Update Available').trim();
        final releaseNotes = (data['body'] as String? ?? 'Bug fixes and performance improvements.').trim();
        final releasePage = data['html_url'] as String?;

        // Look for .apk asset in the release
        String? apkUrl;
        final assets = data['assets'] as List<dynamic>?;
        if (assets != null && assets.isNotEmpty) {
          for (final asset in assets) {
            final name = (asset['name'] as String? ?? '').toLowerCase();
            if (name.endsWith('.apk')) {
              apkUrl = asset['browser_download_url'] as String?;
              break;
            }
          }
        }

        final isNewer = compareVersions(currentVer, cleanTag) > 0;

        return UpdateInfo(
          currentVersion: currentVer,
          latestVersion: cleanTag.isNotEmpty ? cleanTag : currentVer,
          hasUpdate: isNewer,
          releaseTitle: releaseTitle,
          releaseNotes: releaseNotes,
          apkDownloadUrl: apkUrl,
          releasePageUrl: releasePage,
        );
      } else if (response.statusCode == 404) {
        // No release published yet on this repo
        return UpdateInfo(
          currentVersion: currentVer,
          latestVersion: currentVer,
          hasUpdate: false,
          releaseTitle: 'Up to Date',
          releaseNotes: 'No releases found on GitHub repository.',
        );
      } else {
        throw Exception('GitHub API returned status ${response.statusCode}');
      }
    } catch (e) {
      return UpdateInfo(
        currentVersion: currentVer,
        latestVersion: currentVer,
        hasUpdate: false,
        releaseTitle: 'Check Failed',
        releaseNotes: 'Unable to check for updates: $e',
      );
    }
  }

  /// Downloads the APK with real-time percentage progress callback
  /// and immediately triggers the Android system package installer.
  static Future<void> downloadAndInstallApk({
    required String downloadUrl,
    required void Function(double progress) onProgress,
  }) async {
    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(downloadUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to download APK: status ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final tempDir = await getTemporaryDirectory();
      final apkFile = File('${tempDir.path}/dedo_update.apk');

      if (await apkFile.exists()) {
        await apkFile.delete();
      }

      final sink = apkFile.openWrite();
      int downloadedBytes = 0;

      await for (final chunk in response.stream) {
        downloadedBytes += chunk.length;
        sink.add(chunk);

        if (contentLength > 0) {
          onProgress(downloadedBytes / contentLength);
        }
      }

      await sink.flush();
      await sink.close();

      onProgress(1.0);

      // Trigger the native Android APK install prompt
      final result = await OpenFilex.open(
        apkFile.path,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type != ResultType.done) {
        // Fallback: If open_filex fails, launch browser link
        if (await canLaunchUrl(Uri.parse(downloadUrl))) {
          await launchUrl(Uri.parse(downloadUrl), mode: LaunchMode.externalApplication);
        }
      }
    } finally {
      client.close();
    }
  }
}
