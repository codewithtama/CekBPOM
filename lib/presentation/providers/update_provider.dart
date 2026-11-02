import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ota_update/ota_update.dart';
import '../../data/models/app_update_info.dart';
import '../../data/services/update_service.dart';

enum UpdateStatus {
  initial,
  checking,
  available,
  upToDate,
  downloading,
  installing,
  installed,
  error,
}

class UpdateState {
  const UpdateState({
    this.status = UpdateStatus.initial,
    this.updateInfo,
    this.downloadProgress = 0,
    this.errorMessage,
  });

  final UpdateStatus status;
  final AppUpdateInfo? updateInfo;
  final int downloadProgress;
  final String? errorMessage;

  UpdateState copyWith({
    UpdateStatus? status,
    AppUpdateInfo? updateInfo,
    int? downloadProgress,
    String? errorMessage,
  }) {
    return UpdateState(
      status: status ?? this.status,
      updateInfo: updateInfo ?? this.updateInfo,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage,
    );
  }
}

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

class UpdateNotifier extends StateNotifier<UpdateState> {
  UpdateNotifier(this._service) : super(const UpdateState());

  final UpdateService _service;
  StreamSubscription<OtaEvent>? _otaSubscription;

  /// Checks GitHub releases API for latest updates.
  Future<AppUpdateInfo?> checkForUpdate() async {
    state = state.copyWith(status: UpdateStatus.checking, errorMessage: null);

    try {
      final info = await _service.checkForUpdate();
      state = state.copyWith(
        status: info.hasUpdate ? UpdateStatus.available : UpdateStatus.upToDate,
        updateInfo: info,
      );
      return info;
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }

  /// Begins downloading the OTA update APK and launches the installer.
  Future<void> startDownloadAndInstall({String? customUrl}) async {
    final targetUrl = customUrl ?? state.updateInfo?.downloadUrl;
    if (targetUrl == null || targetUrl.isEmpty) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'URL unduhan APK tidak valid atau kosong.',
      );
      return;
    }

    state = state.copyWith(
      status: UpdateStatus.downloading,
      downloadProgress: 0,
      errorMessage: null,
    );

    await _otaSubscription?.cancel();

    try {
      _otaSubscription = _service.startOtaUpdate(targetUrl).listen(
        (OtaEvent event) {
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              final progress = int.tryParse(event.value ?? '0') ?? 0;
              state = state.copyWith(
                status: UpdateStatus.downloading,
                downloadProgress: progress,
              );
              break;

            case OtaStatus.INSTALLING:
              state = state.copyWith(
                status: UpdateStatus.installing,
                downloadProgress: 100,
              );
              break;

            case OtaStatus.INSTALLATION_DONE:
              state = state.copyWith(
                status: UpdateStatus.installed,
                downloadProgress: 100,
              );
              break;

            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              state = state.copyWith(
                status: UpdateStatus.error,
                errorMessage:
                    'Izin instalasi aplikasi pihak ketiga ditolak. Aktifkan izin "Install unknown apps" untuk CekBPOM di Pengaturan Android Anda.',
              );
              break;

            case OtaStatus.DOWNLOAD_ERROR:
              state = state.copyWith(
                status: UpdateStatus.error,
                errorMessage: 'Gagal mengunduh file APK. Periksa koneksi internet Anda.',
              );
              break;

            case OtaStatus.CHECKSUM_ERROR:
              state = state.copyWith(
                status: UpdateStatus.error,
                errorMessage: 'Verifikasi integritas file APK gagal (checksum tidak cocok).',
              );
              break;

            case OtaStatus.ALREADY_RUNNING_ERROR:
              state = state.copyWith(
                status: UpdateStatus.error,
                errorMessage: 'Proses pembaruan OTA lain sedang berjalan.',
              );
              break;

            case OtaStatus.INSTALLATION_ERROR:
              state = state.copyWith(
                status: UpdateStatus.error,
                errorMessage: 'Sistem Android membatalkan proses instalasi paket APK.',
              );
              break;

            case OtaStatus.INTERNAL_ERROR:
            default:
              state = state.copyWith(
                status: UpdateStatus.error,
                errorMessage: event.value ?? 'Terjadi kesalahan sistem saat pembaruan OTA.',
              );
              break;
          }
        },
        onError: (dynamic err) {
          state = state.copyWith(
            status: UpdateStatus.error,
            errorMessage: 'Terjadi kegagalan proses OTA: $err',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: UpdateStatus.error,
        errorMessage: 'Gagal memulai unduhan OTA: $e',
      );
    }
  }

  /// Cancels in-progress OTA download.
  Future<void> cancelDownload() async {
    await _otaSubscription?.cancel();
    _otaSubscription = null;
    await _service.cancelUpdate();
    state = state.copyWith(
      status: UpdateStatus.initial,
      downloadProgress: 0,
    );
  }

  @override
  void dispose() {
    _otaSubscription?.cancel();
    super.dispose();
  }
}

final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  final service = ref.watch(updateServiceProvider);
  return UpdateNotifier(service);
});

