import '../../core/utils/version_comparator.dart';

/// Represents parsed metadata of an available application release from GitHub.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.tagName,
    required this.releaseTitle,
    required this.releaseNotes,
    required this.publishedAt,
    required this.downloadUrl,
    required this.assetName,
    required this.fileSizeBytes,
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.hasUpdate,
  });

  final String tagName;
  final String releaseTitle;
  final String releaseNotes;
  final DateTime publishedAt;
  final String downloadUrl;
  final String assetName;
  final int fileSizeBytes;
  final String currentVersion;
  final int currentBuildNumber;
  final String latestVersion;
  final int latestBuildNumber;
  final bool hasUpdate;

  /// Returns human-readable file size (e.g., "24.5 MB").
  String get formattedFileSize {
    if (fileSizeBytes <= 0) return 'Ukuran tidak diketahui';
    final mb = fileSizeBytes / (1024 * 1024);
    if (mb >= 1.0) {
      return '${mb.toStringAsFixed(1)} MB';
    }
    final kb = fileSizeBytes / 1024;
    return '${kb.toStringAsFixed(0)} KB';
  }

  /// Returns readable release date (e.g. "13/06/2026").
  String get formattedPublishedDate {
    final day = publishedAt.day.toString().padLeft(2, '0');
    final month = publishedAt.month.toString().padLeft(2, '0');
    final year = publishedAt.year.toString();
    return '$day/$month/$year';
  }

  /// Creates [AppUpdateInfo] from GitHub Releases API JSON.
  factory AppUpdateInfo.fromGitHubRelease({
    required Map<String, dynamic> json,
    required String currentVersion,
    required int currentBuildNumber,
    String? deviceAbi,
  }) {
    final tagName = json['tag_name'] as String? ?? '';
    final releaseTitle = json['name'] as String? ?? tagName;
    final releaseNotes = (json['body'] as String? ?? '').trim();
    final publishedStr = json['published_at'] as String?;
    final publishedAt = publishedStr != null
        ? (DateTime.tryParse(publishedStr) ?? DateTime.now())
        : DateTime.now();

    // Parse remote version parts from tag_name or release title
    var versionText = tagName;
    var parsed = VersionComparator.parse(versionText);
    if (parsed.major == 0 && parsed.minor == 0 && parsed.patch == 0) {
      versionText = releaseTitle;
      parsed = VersionComparator.parse(versionText);
    }

    final latestVersion = '${parsed.major}.${parsed.minor}.${parsed.patch}';
    final latestBuildNumber = parsed.build;

    final hasUpdate = VersionComparator.isNewer(
      remoteVersion: versionText,
      currentVersion: currentVersion,
      remoteBuild: latestBuildNumber > 0 ? latestBuildNumber : null,
      currentBuild: currentBuildNumber,
    );

    // Pick best APK asset
    final assets = (json['assets'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    Map<String, dynamic>? selectedAsset;

    // 1. Check matching ABI if provided (e.g. arm64-v8a)
    if (deviceAbi != null && deviceAbi.isNotEmpty) {
      selectedAsset = assets.cast<Map<String, dynamic>?>().firstWhere(
            (a) =>
                a != null &&
                (a['name'] as String? ?? '').toLowerCase().contains(deviceAbi.toLowerCase()) &&
                (a['name'] as String? ?? '').toLowerCase().endsWith('.apk'),
            orElse: () => null,
          );
    }

    // 2. Fallback to universal APK (e.g. app-release.apk without specific ABI tag in filename)
    selectedAsset ??= assets.cast<Map<String, dynamic>?>().firstWhere(
          (a) {
            if (a == null) return false;
            final name = (a['name'] as String? ?? '').toLowerCase();
            if (!name.endsWith('.apk')) return false;
            final isSpecificAbi = name.contains('arm64') ||
                name.contains('armeabi') ||
                name.contains('v7a') ||
                name.contains('v8a') ||
                name.contains('x86');
            return !isSpecificAbi;
          },
          orElse: () => null,
        );

    // 3. Fallback to any APK
    selectedAsset ??= assets.cast<Map<String, dynamic>?>().firstWhere(
          (a) => a != null && (a['name'] as String? ?? '').toLowerCase().endsWith('.apk'),
          orElse: () => null,
        );

    final downloadUrl = selectedAsset?['browser_download_url'] as String? ??
        json['html_url'] as String? ??
        '';
    final assetName = selectedAsset?['name'] as String? ?? 'app-release.apk';
    final fileSizeBytes = (selectedAsset?['size'] as num?)?.toInt() ?? 0;

    return AppUpdateInfo(
      tagName: tagName,
      releaseTitle: releaseTitle,
      releaseNotes: releaseNotes.isEmpty ? 'Pembaruan stabilitas dan peningkatan performa sistem.' : releaseNotes,
      publishedAt: publishedAt,
      downloadUrl: downloadUrl,
      assetName: assetName,
      fileSizeBytes: fileSizeBytes,
      currentVersion: currentVersion,
      currentBuildNumber: currentBuildNumber,
      latestVersion: latestVersion,
      latestBuildNumber: latestBuildNumber,
      hasUpdate: hasUpdate,
    );
  }
}
