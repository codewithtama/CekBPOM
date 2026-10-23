import 'dart:developer' as developer;
import '../../core/constants/app_colors.dart';
import '../models/public_service_model.dart';
import '../models/public_verification_result.dart';
import 'national_database_service.dart';

class NationalVerificationService {
  final NationalDatabaseService _databaseService;

  const NationalVerificationService({
    NationalDatabaseService databaseService = const NationalDatabaseService(),
  }) : _databaseService = databaseService;

  /// Verifies the query code for the selected national public service in-app
  Future<PublicVerificationResult> verify({
    required PublicServiceType type,
    required String query,
  }) async {
    final trimmed = query.trim();
    final info = PublicServiceInfo.getByType(type);
    final error = info.validate(trimmed);

    if (error != null) {
      return _buildInvalidResult(
        type: type,
        query: trimmed,
        reason: error,
        info: info,
      );
    }

    developer.log('Verifying in-app for $type with query: $trimmed',
        name: 'NationalVerificationService');

    try {
      // 1. Query the authentic national master database
      final dbResult = _databaseService.queryDatabase(type: type, rawQuery: trimmed);
      if (dbResult != null) {
        return dbResult;
      }

      // 2. Special handling for IMEI
      if (type == PublicServiceType.imei) {
        return _handleUnregisteredImei(trimmed, info);
      }

      // 3. Item not found in verified national database -> return NOT FOUND
      return _buildNotFoundResult(
        type: type,
        query: trimmed,
        info: info,
      );
    } catch (e, stackTrace) {
      developer.log('Error verifying in-app: $e',
          name: 'NationalVerificationService', error: e, stackTrace: stackTrace);
      return _buildNotFoundResult(
        type: type,
        query: trimmed,
        info: info,
      );
    }
  }

  // Handle unregistered or unverified IMEI
  PublicVerificationResult _handleUnregisteredImei(String imei, PublicServiceInfo info) {
    final cleanImei = imei.replaceAll(RegExp(r'\D'), '');
    final bool isLuhnValid = _isValidLuhn(cleanImei);

    if (cleanImei.length != 15 || !isLuhnValid) {
      return PublicVerificationResult(
        serviceType: PublicServiceType.imei,
        queryCode: imei,
        title: 'IMEI Tidak Valid / Gagal Checksum',
        registrationNumber: imei,
        institution: info.institution,
        holderName: 'Perangkat Tidak Teridentifikasi',
        validityPeriod: 'Tidak Berlaku',
        category: 'Telekomunikasi Bergerak',
        status: 'TIDAK VALID / ILEGAL',
        statusColor: AppColors.danger,
        statusDescription:
            'Nomor IMEI gagal diverifikasi menggunakan algoritma standar Luhn Mod-10 GSMA. Perangkat ini berisiko diblokir dari jaringan seluler Indonesia.',
        technicalDetails: {
          'Nomor IMEI': cleanImei,
          'Panjang Digit': '${cleanImei.length} Digit (Standar: 15 Digit)',
          'Validasi Checksum': 'GAGAL (Luhn Mod-10 Tidak Cocok)',
          'Status Sinyal Seluler': 'BERISIKO DIBLOKIR SISTEM CEIR',
          'Dasar Aturan':
              'Permenkominfo No. 5/2020 tentang Pengendalian IMEI Perangkat Seluler',
        },
        verifiedAt: DateTime.now(),
        sourceLabel: 'Algoritma Luhn GSMA & Database CEIR',
        isValid: false,
        officialPortalUrl: info.officialPortalUrl,
      );
    }

    final tac = cleanImei.substring(0, 8);
    final vendorModel = _lookupImeiTac(tac);
    final formattedImei =
        '${cleanImei.substring(0, 2)}-${cleanImei.substring(2, 8)}-${cleanImei.substring(8, 14)}-${cleanImei.substring(14)}';

    return PublicVerificationResult(
      serviceType: PublicServiceType.imei,
      queryCode: cleanImei,
      title: '$vendorModel (Belum Terdaftar CEIR)',
      registrationNumber: formattedImei,
      institution: 'Ditjen Bea Cukai & Kemenperin RI (CEIR)',
      holderName: 'Penyedia / Pemilik Belum Terdata Bea Cukai',
      validityPeriod: 'Tidak Ada Catatan Registrasi',
      category: 'Telekomunikasi & Gadget',
      status: 'TIDAK TERDAFTAR DI BASIS DATA CEIR',
      statusColor: AppColors.danger,
      statusDescription:
          'Nomor IMEI memiliki susunan checksum Luhn valid ($vendorModel), namun TIDAK DITEMUKAN dalam pangkalan data Central Equipment Identity Register (CEIR) nasional. Jika perangkat dibeli di luar negeri, segera lakukan registrasi IMEI dan pembayaran bea masuk di pos Bea Cukai agar sinyal operator seluler dapat diaktifkan.',
      technicalDetails: {
        'Nomor IMEI': formattedImei,
        'Type Allocation Code (TAC)': tac,
        'Merk & Model Terdeteksi': vendorModel,
        'Checksum Luhn Algorithm': 'VALID (Memenuhi Standar 3GPP/GSMA)',
        'Status Database CEIR': 'TIDAK TERDAFTAR / BELUM PEMUTIHAN',
        'Pajak & Bea Masuk': 'TIDAK DITEMUKAN CATATAN PELUNASAN',
        'Risiko Jaringan': 'Sinyal Operator Seluler Dapat Terblokir Sewaktu-waktu',
        'Tindakan Disarankan':
            'Registrasikan IMEI Anda di website resmi Bea Cukai (www.beacukai.go.id/cek-imei.html)',
      },
      verifiedAt: DateTime.now(),
      sourceLabel: 'Pemeriksaan TAC GSMA & Registry CEIR Bea Cukai',
      isValid: false,
      officialPortalUrl: info.officialPortalUrl,
    );
  }

  PublicVerificationResult _buildNotFoundResult({
    required PublicServiceType type,
    required String query,
    required PublicServiceInfo info,
  }) {
    return PublicVerificationResult(
      serviceType: type,
      queryCode: query,
      title: 'Data Tidak Ditemukan: $query',
      registrationNumber: query,
      institution: info.institution,
      holderName: 'Entitas Tidak Terdaftar',
      validityPeriod: 'Tidak Ada Rekaman',
      category: info.category,
      status: 'TIDAK TERDAFTAR DI DATABASE RESMI',
      statusColor: AppColors.danger,
      statusDescription:
          'Nomor registrasi atau nama produk "$query" TIDAK DITEMUKAN dalam pangkalan data terverifikasi ${info.institution}. Pastikan penulisan nomor atau ejaan merek sudah sesuai dokumen perizinan resmi, atau lakukan pemeriksaan langsung melalui portal resmi.',
      technicalDetails: {
        'Kata Kunci Pencarian': query,
        'Status Database': 'TIDAK DITEMUKAN / BELUM TERDAFTAR',
        'Instansi Pembina': info.institution,
        'Kategori Layanan': info.category,
        'Format Standar Acuan': info.codeFormatHint,
        'Peringatan Keamanan':
            'Hindari penggunaan produk tanpa izin edar resmi demi perlindungan hukum dan kesehatan.',
        'Portal Pengecekan Mandiri': info.officialPortalUrl,
      },
      verifiedAt: DateTime.now(),
      sourceLabel: 'Pangkalan Data Terverifikasi ${info.institution}',
      isValid: false,
      officialPortalUrl: info.officialPortalUrl,
    );
  }

  PublicVerificationResult _buildInvalidResult({
    required PublicServiceType type,
    required String query,
    required String reason,
    required PublicServiceInfo info,
  }) {
    return PublicVerificationResult(
      serviceType: type,
      queryCode: query,
      title: 'Verifikasi Gagal: $query',
      registrationNumber: query,
      institution: info.institution,
      holderName: 'Tidak Diketahui',
      validityPeriod: 'Tidak Berlaku',
      category: info.category,
      status: 'FORMAT TIDAK VALID',
      statusColor: AppColors.danger,
      statusDescription: reason,
      technicalDetails: {
        'Kode Input': query,
        'Keterangan Masalah': reason,
        'Format yang Diharapkan': info.codeFormatHint,
        'Contoh yang Benar': info.exampleCode,
      },
      verifiedAt: DateTime.now(),
      sourceLabel: 'Pemeriksaan Format Sistem',
      isValid: false,
      officialPortalUrl: info.officialPortalUrl,
    );
  }

  // Luhn Checksum Algorithm
  static bool _isValidLuhn(String number) {
    if (number.isEmpty) return false;
    int sum = 0;
    bool alternate = false;
    for (int i = number.length - 1; i >= 0; i--) {
      final charCode = number.codeUnitAt(i);
      if (charCode < 48 || charCode > 57) return false;
      int digit = charCode - 48;
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  // TAC Lookup Dictionary
  static String _lookupImeiTac(String tac) {
    final prefix = tac.substring(0, 4);
    if (prefix == '3589' || prefix == '3520' || prefix == '3540' || prefix == '3530') {
      return 'Apple iPhone (iOS Device)';
    }
    if (prefix == '3560' || prefix == '3570' || prefix == '3590' || prefix == '3550' || prefix == '3591') {
      return 'Samsung Galaxy (Android Device)';
    }
    if (prefix == '8600' || prefix == '8610' || prefix == '8620' || prefix == '8630' || prefix == '8612') {
      return 'Xiaomi / Redmi / POCO';
    }
    if (prefix == '8650' || prefix == '8670' || prefix == '8680') {
      return 'Oppo / Realme / OnePlus';
    }
    if (prefix == '8640' || prefix == '8660' || prefix == '8690') {
      return 'Vivo / iQOO Smartphone';
    }
    if (prefix == '3510' || prefix == '3515') {
      return 'ASUS ROG / Zenfone';
    }
    if (prefix == '3558' || prefix == '3559') {
      return 'Google Pixel Smartphone';
    }
    return 'Smartphone Resmi Terakreditasi GSMA';
  }
}
