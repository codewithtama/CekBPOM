import 'dart:async';
import 'package:dio/dio.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/app_update_info.dart';

/// Service responsible for GitHub Releases API checking and in-app OTA updates.
class UpdateService {
  UpdateService({Dio? dio, OtaUpdate? otaUpdate})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {
                  'Accept': 'application/vnd.github.v3+json',
                  'User-Agent': 'CekBPOM-Mobile-App',
                },
              ),
            ),
        _otaUpdate = otaUpdate ?? OtaUpdate();

  final Dio _dio;
  final OtaUpdate _otaUpdate;

  static const String _releasesEndpoint =
      'https://api.github.com/repos/codewithtama/CekBPOM/releases/latest';

  /// Queries GitHub releases and returns parsed [AppUpdateInfo].
  Future<AppUpdateInfo> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      String? deviceAbi;
      try {
        deviceAbi = await _otaUpdate.getAbi();
      } catch (_) {
        deviceAbi = null;
      }

      final response = await _dio.get<Map<String, dynamic>>(_releasesEndpoint);
      final data = response.data;

      if (data == null) {
        throw Exception('Respon rilis pembaruan dari GitHub kosong.');
      }

      return AppUpdateInfo.fromGitHubRelease(
        json: data,
        currentVersion: currentVersion,
        currentBuildNumber: currentBuildNumber,
        deviceAbi: deviceAbi,
      );
    } on DioException catch (dioErr) {
      if (dioErr.response?.statusCode == 404) {
        throw Exception('Belum ada rilis versi publik yang dipublikasikan di repositori.');
      } else if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout ||
          dioErr.type == DioExceptionType.connectionError) {
        throw Exception('Gagal menghubungi server pembaruan. Periksa koneksi internet Anda.');
      } else {
        throw Exception('Terjadi kendala saat memeriksa pembaruan: ${dioErr.message}');
      }
    } catch (e) {
      throw Exception('Gagal memeriksa pembaruan: $e');
    }
  }

  /// Initiates the OTA APK download and triggers system installation.
  Stream<OtaEvent> startOtaUpdate(
    String downloadUrl, {
    String destinationFilename = 'cekbpom_update.apk',
  }) {
    return _otaUpdate.execute(
      downloadUrl,
      destinationFilename: destinationFilename,
    );
  }

  /// Cancels an in-progress OTA download.
  Future<void> cancelUpdate() async {
    try {
      await _otaUpdate.cancel();
    } catch (_) {
      // Ignore if no download is running
    }
  }
}

