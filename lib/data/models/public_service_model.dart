import 'package:flutter/material.dart';

enum PublicServiceType {
  alkesPkrt,
  halal,
  sni,
  pdki,
  imei,
  sdppi,
  kfa,
}

class PublicServiceInfo {
  final PublicServiceType type;
  final String title;
  final String shortTitle;
  final String institution;
  final String category;
  final String description;
  final String codeFormatHint;
  final String exampleCode;
  final String officialPortalUrl;
  final String searchEndpointUrl;
  final IconData icon;
  final Color themeColor;
  final TextInputType keyboardType;

  const PublicServiceInfo({
    required this.type,
    required this.title,
    required this.shortTitle,
    required this.institution,
    required this.category,
    required this.description,
    required this.codeFormatHint,
    required this.exampleCode,
    required this.officialPortalUrl,
    required this.searchEndpointUrl,
    required this.icon,
    required this.themeColor,
    this.keyboardType = TextInputType.text,
  });

  /// Validates input code according to the service standard
  String? validate(String code) {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      return 'Nomor atau kata kunci tidak boleh kosong.';
    }

    switch (type) {
      case PublicServiceType.imei:
        final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
        if (digitsOnly.length != 15) {
          return 'Nomor IMEI harus terdiri dari 15 digit angka.';
        }
        if (!_isValidLuhn(digitsOnly)) {
          return 'Nomor IMEI tidak valid (Gagal verifikasi checksum Luhn).';
        }
        return null;

      case PublicServiceType.alkesPkrt:
        if (trimmed.length < 5) {
          return 'Nomor izin edar terlalu pendek.';
        }
        return null;

      case PublicServiceType.halal:
        if (trimmed.length < 3) {
          return 'Nomor sertifikat atau nama produk minimal 3 karakter.';
        }
        return null;

      case PublicServiceType.sni:
        if (trimmed.length < 3) {
          return 'Nomor sertifikat atau nama produk minimal 3 karakter.';
        }
        return null;

      case PublicServiceType.pdki:
        if (trimmed.length < 2) {
          return 'Nama merek atau nomor permohonan minimal 2 karakter.';
        }
        return null;

      case PublicServiceType.sdppi:
        if (trimmed.length < 3) {
          return 'Nomor sertifikat atau model perangkat minimal 3 karakter.';
        }
        return null;

      case PublicServiceType.kfa:
        if (trimmed.length < 2) {
          return 'Nama obat atau zat aktif minimal 2 karakter.';
        }
        return null;
    }
  }

  /// Luhn Checksum Algorithm for IMEI
  static bool _isValidLuhn(String number) {
    int sum = 0;
    bool alternate = false;
    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);
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

  /// Builds direct verification search URL based on query
  String buildVerificationUrl(String query) {
    final encoded = Uri.encodeComponent(query.trim());
    switch (type) {
      case PublicServiceType.alkesPkrt:
        return 'https://regalkes.kemkes.go.id/';
      case PublicServiceType.halal:
        return 'https://bpjph.halal.go.id/search/sertifikat?nama_produk=$encoded';
      case PublicServiceType.sni:
        return 'https://bangbeni.bsn.go.id/';
      case PublicServiceType.pdki:
        return 'https://pdki-indonesia.dgip.go.id/search?type=trademark&keyword=$encoded';
      case PublicServiceType.imei:
        return 'https://www.beacukai.go.id/cek-imei.html';
      case PublicServiceType.sdppi:
        return 'https://sertifikasi.postel.go.id/sertifikat/index';
      case PublicServiceType.kfa:
        return 'https://satusehat.kemkes.go.id/kfa-browser';
    }
  }

  static const List<PublicServiceInfo> allServices = [
    PublicServiceInfo(
      type: PublicServiceType.alkesPkrt,
      title: 'Alat Kesehatan & PKRT',
      shortTitle: 'Alkes & PKRT',
      institution: 'Kementerian Kesehatan RI (Regalkes)',
      category: 'Kesehatan & Kebersihan',
      description:
          'Verifikasi izin edar resmi Alat Kesehatan (AKL/AKD) dan Perbekalan Kesehatan Rumah Tangga (PKL/PKD) seperti desinfektan, sabun cuci tangan, popok, dan masker medis.',
      codeFormatHint: 'AKL/AKD/PKL/PKD diikuti 11 digit (cth: KEMENKES RI AKD 20501810123)',
      exampleCode: 'AKD 20501810123',
      officialPortalUrl: 'https://regalkes.kemkes.go.id/',
      searchEndpointUrl: 'https://regalkes.kemkes.go.id/',
      icon: Icons.medical_services_rounded,
      themeColor: Color(0xFF00897B),
    ),
    PublicServiceInfo(
      type: PublicServiceType.halal,
      title: 'Sertifikasi Halal Resmi',
      shortTitle: 'Halal BPJPH',
      institution: 'BPJPH Kementerian Agama RI',
      category: 'Pangan & Gaya Hidup',
      description:
          'Penelusuran keabsahan sertifikat halal resmi yang diterbitkan oleh Badan Penyelenggara Jaminan Produk Halal (BPJPH) untuk makanan, kosmetik, dan barang konsumsi.',
      codeFormatHint: 'Nomor ID Halal atau Nama Produk (cth: ID0011000001234 atau Nama Merk)',
      exampleCode: 'ID0011000001234',
      officialPortalUrl: 'https://info.halal.go.id/',
      searchEndpointUrl: 'https://bpjph.halal.go.id/search/sertifikat',
      icon: Icons.verified_rounded,
      themeColor: Color(0xFF2E7D32),
    ),
    PublicServiceInfo(
      type: PublicServiceType.sni,
      title: 'Sertifikasi SNI',
      shortTitle: 'Standar SNI',
      institution: 'Badan Standardisasi Nasional (BSN)',
      category: 'Standar Industri',
      description:
          'Verifikasi tanda Standar Nasional Indonesia (SNI) untuk menjamin keselamatan dan kualitas produk konsumen (elektronik, helm, mainan anak, AMDK, dll).',
      codeFormatHint: 'Nomor SNI atau nomor sertifikat produk (cth: SNI 04-6292.1-2003)',
      exampleCode: 'SNI 04-6292.1-2003',
      officialPortalUrl: 'https://bangbeni.bsn.go.id/',
      searchEndpointUrl: 'https://bangbeni.bsn.go.id/',
      icon: Icons.security_rounded,
      themeColor: Color(0xFF1565C0),
    ),
    PublicServiceInfo(
      type: PublicServiceType.pdki,
      title: 'Merek Dagang & Paten (PDKI)',
      shortTitle: 'Merek & Paten',
      institution: 'DJKI Kemenkumham RI',
      category: 'Hak Kekayaan Intelektual',
      description:
          'Pangkalan Data Kekayaan Intelektual untuk menelusuri keaslian pendaftaran merek dagang, paten inovasi, desain industri, dan hak cipta di Indonesia.',
      codeFormatHint: 'Nama Merek Dagang atau No. Permohonan (cth: IDM000123456 atau Nama Brand)',
      exampleCode: 'IDM000123456',
      officialPortalUrl: 'https://pdki-indonesia.dgip.go.id/',
      searchEndpointUrl: 'https://pdki-indonesia.dgip.go.id/search',
      icon: Icons.gavel_rounded,
      themeColor: Color(0xFF6A1B9A),
    ),
    PublicServiceInfo(
      type: PublicServiceType.imei,
      title: 'Pendaftaran IMEI Gadget',
      shortTitle: 'Cek IMEI',
      institution: 'Direktorat Jenderal Bea dan Cukai (Kemenkeu)',
      category: 'Telekomunikasi & Pajak',
      description:
          'Cek legalitas nomor International Mobile Equipment Identity (IMEI) 15 digit handphone/gadget Anda agar tidak terblokir dari jaringan seluler nasional.',
      codeFormatHint: '15 digit angka IMEI (Ketik *#06# pada ponsel untuk melihat IMEI)',
      exampleCode: '358912345678902',
      officialPortalUrl: 'https://www.beacukai.go.id/cek-imei.html',
      searchEndpointUrl: 'https://www.beacukai.go.id/cek-imei.html',
      icon: Icons.phonelink_setup_rounded,
      themeColor: Color(0xFFD84315),
      keyboardType: TextInputType.number,
    ),
    PublicServiceInfo(
      type: PublicServiceType.sdppi,
      title: 'Sertifikasi Perangkat SDPPI',
      shortTitle: 'SDPPI Komdigi',
      institution: 'Kemkomdigi (ex-Kominfo RI)',
      category: 'Perangkat Frekuensi',
      description:
          'Verifikasi sertifikat kelaikan teknis perangkat telekomunikasi, pemancar frekuensi, Wi-Fi, dan Bluetooth resmi yang telah diuji laboratorium SDPPI.',
      codeFormatHint: 'Nomor Sertifikat SDPPI atau Tipe Model (cth: 12345/SDPPI/2026)',
      exampleCode: '12345/SDPPI/2026',
      officialPortalUrl: 'https://sertifikasi.postel.go.id/sertifikat/index',
      searchEndpointUrl: 'https://sertifikasi.postel.go.id/sertifikat/index',
      icon: Icons.cell_tower_rounded,
      themeColor: Color(0xFF00695C),
    ),
    PublicServiceInfo(
      type: PublicServiceType.kfa,
      title: 'Kamus Farmasi & Alkes (KFA)',
      shortTitle: 'KFA SatuSehat',
      institution: 'SatuSehat Kementerian Kesehatan RI',
      category: 'Standar Medis Nasional',
      description:
          'Pangkalan data master farmasi nasional berstandar interoperabilitas HL7 FHIR untuk menelusuri zat aktif obat, kode ATC, bentuk sediaan, dan izin edar terintegrasi.',
      codeFormatHint: 'Nama Obat Generik/Paten atau Zat Aktif (cth: Paracetamol, Amoxicillin)',
      exampleCode: 'Paracetamol',
      officialPortalUrl: 'https://satusehat.kemkes.go.id/kfa-browser',
      searchEndpointUrl: 'https://satusehat.kemkes.go.id/kfa-browser',
      icon: Icons.medication_rounded,
      themeColor: Color(0xFFC2185B),
    ),
  ];

  static PublicServiceInfo getByType(PublicServiceType type) {
    return allServices.firstWhere(
      (s) => s.type == type,
      orElse: () => allServices.first,
    );
  }
}
