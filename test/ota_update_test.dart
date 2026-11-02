import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/core/utils/version_comparator.dart';
import 'package:cekbpom/data/models/app_update_info.dart';

void main() {
  group('VersionComparator Tests', () {
    test('Correctly parses basic semver', () {
      final v = VersionComparator.parse('1.2.3');
      expect(v.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 3);
      expect(v.build, 0);
    });

    test('Correctly parses version with "v" prefix and build number', () {
      final v = VersionComparator.parse('v1.2.0+5');
      expect(v.major, 1);
      expect(v.minor, 2);
      expect(v.patch, 0);
      expect(v.build, 5);
    });

    test('Correctly extracts version embedded in release title string', () {
      final v = VersionComparator.parse('CekBPOM v2.0.1 Release Build');
      expect(v.major, 2);
      expect(v.minor, 0);
      expect(v.patch, 1);
    });

    test('Identifies newer major version', () {
      final isNewer = VersionComparator.isNewer(
        remoteVersion: '2.0.0',
        currentVersion: '1.9.9',
      );
      expect(isNewer, isTrue);
    });

    test('Identifies newer minor version', () {
      final isNewer = VersionComparator.isNewer(
        remoteVersion: '1.2.0',
        currentVersion: '1.1.0',
      );
      expect(isNewer, isTrue);
    });

    test('Identifies newer patch version', () {
      final isNewer = VersionComparator.isNewer(
        remoteVersion: '1.1.5',
        currentVersion: '1.1.4',
      );
      expect(isNewer, isTrue);
    });

    test('Identifies newer build number when semver is identical', () {
      final isNewer = VersionComparator.isNewer(
        remoteVersion: '1.1.0',
        currentVersion: '1.1.0',
        remoteBuild: 4,
        currentBuild: 2,
      );
      expect(isNewer, isTrue);
    });

    test('Returns false when remote version is older', () {
      final isNewer = VersionComparator.isNewer(
        remoteVersion: '1.0.0',
        currentVersion: '1.1.0',
      );
      expect(isNewer, isFalse);
    });

    test('Returns false when remote version is identical', () {
      final isNewer = VersionComparator.isNewer(
        remoteVersion: '1.1.0',
        currentVersion: '1.1.0',
        remoteBuild: 2,
        currentBuild: 2,
      );
      expect(isNewer, isFalse);
    });
  });

  group('AppUpdateInfo Model Tests', () {
    final mockGitHubRelease = <String, dynamic>{
      'tag_name': 'v1.2.0',
      'name': 'CekBPOM v1.2.0 - Update OTA & Halal In-App',
      'body': '- Menambahkan fitur OTA update.\n- In-app halal verification.',
      'published_at': '2026-06-14T10:00:00Z',
      'html_url': 'https://github.com/codewithtama/CekBPOM/releases/tag/v1.2.0',
      'assets': [
        {
          'name': 'app-arm64-v8a-release.apk',
          'size': 25713600,
          'browser_download_url':
              'https://github.com/codewithtama/CekBPOM/releases/download/v1.2.0/app-arm64-v8a-release.apk',
        },
        {
          'name': 'app-armeabi-v7a-release.apk',
          'size': 23500000,
          'browser_download_url':
              'https://github.com/codewithtama/CekBPOM/releases/download/v1.2.0/app-armeabi-v7a-release.apk',
        },
        {
          'name': 'app-release.apk',
          'size': 45000000,
          'browser_download_url':
              'https://github.com/codewithtama/CekBPOM/releases/download/v1.2.0/app-release.apk',
        },
      ],
    };

    test('Selects matching ABI APK asset when device ABI is provided', () {
      final info = AppUpdateInfo.fromGitHubRelease(
        json: mockGitHubRelease,
        currentVersion: '1.1.0',
        currentBuildNumber: 2,
        deviceAbi: 'arm64-v8a',
      );

      expect(info.hasUpdate, isTrue);
      expect(info.latestVersion, '1.2.0');
      expect(info.assetName, 'app-arm64-v8a-release.apk');
      expect(info.downloadUrl, contains('app-arm64-v8a-release.apk'));
      expect(info.formattedFileSize, '24.5 MB');
    });

    test('Falls back to universal release APK when ABI not specifically matched', () {
      final info = AppUpdateInfo.fromGitHubRelease(
        json: mockGitHubRelease,
        currentVersion: '1.1.0',
        currentBuildNumber: 2,
        deviceAbi: 'mips',
      );

      expect(info.hasUpdate, isTrue);
      expect(info.assetName, 'app-release.apk');
      expect(info.downloadUrl, contains('app-release.apk'));
    });

    test('Correctly flags hasUpdate as false when app is on newer version', () {
      final info = AppUpdateInfo.fromGitHubRelease(
        json: mockGitHubRelease,
        currentVersion: '1.3.0',
        currentBuildNumber: 1,
      );

      expect(info.hasUpdate, isFalse);
    });
  });
}

