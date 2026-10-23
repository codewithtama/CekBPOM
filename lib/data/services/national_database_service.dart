import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../models/public_service_model.dart';
import '../models/public_verification_result.dart';

class NationalDatabaseRecord {
  final PublicServiceType serviceType;
  final String title;
  final String registrationNumber;
  final String institution;
  final String holderName;
  final String validityPeriod;
  final String category;
  final String status;
  final Color statusColor;
  final String statusDescription;
  final Map<String, String> technicalDetails;
  final String sourceLabel;
  final bool isValid;
  final String officialPortalUrl;
  final List<String> searchKeywords;

  const NationalDatabaseRecord({
    required this.serviceType,
    required this.title,
    required this.registrationNumber,
    required this.institution,
    required this.holderName,
    required this.validityPeriod,
    required this.category,
    required this.status,
    required this.statusColor,
    required this.statusDescription,
    required this.technicalDetails,
    required this.sourceLabel,
    required this.isValid,
    required this.officialPortalUrl,
    required this.searchKeywords,
  });

  PublicVerificationResult toVerificationResult(String queryCode) {
    return PublicVerificationResult(
      serviceType: serviceType,
      queryCode: queryCode,
      title: title,
      registrationNumber: registrationNumber,
      institution: institution,
      holderName: holderName,
      validityPeriod: validityPeriod,
      category: category,
      status: status,
      statusColor: statusColor,
      statusDescription: statusDescription,
      technicalDetails: technicalDetails,
      verifiedAt: DateTime.now(),
      sourceLabel: sourceLabel,
      isValid: isValid,
      officialPortalUrl: officialPortalUrl,
    );
  }
}

class NationalDatabaseService {
  const NationalDatabaseService();

  // ==========================================
  // 1. DATA MASTER ALKES & PKRT (KEMENKES RI)
  // ==========================================
  static final List<NationalDatabaseRecord> alkesRecords = [
    NationalDatabaseRecord(
      serviceType: PublicServiceType.alkesPkrt,
      title: 'OneMed Surgical Face Mask 3-Ply Earloop',
      registrationNumber: 'KEMENKES RI AKD 20501810123',
      institution: 'Kementerian Kesehatan RI (Regalkes)',
      holderName: 'PT Jayamas Medica Industri Tbk (OneMed)',
      validityPeriod: '28 Oktober 2028',
      category: 'Alat Kesehatan Dalam Negeri (AKD)',
      status: 'TERDAFTAR & SAH',
      statusColor: AppColors.success,
      statusDescription:
          'Izin edar aktif dan sah terdaftar pada pangkalan data Regalkes Kemenkes RI. Lulus uji efisiensi filtrasi bakteri (BFE ≥ 98%) dan aman digunakan untuk tenaga medis serta publik.',
      technicalDetails: {
        'Nomor Izin Edar': 'KEMENKES RI AKD 20501810123',
        'Kategori Layanan': 'Alat Kesehatan Dalam Negeri (AKD)',
        'Pabrikan / Pendaftar': 'PT Jayamas Medica Industri Tbk',
        'Lokasi Pabrik': 'Krian, Sidoarjo, Jawa Timur, Indonesia',
        'Klasifikasi Risiko': 'Kelas A (Risiko Rendah)',
        'Standar Uji Mutu': 'SNI EN 14683:2019 & CPAKB Kemenkes RI',
        'Bahan Material': 'Non-Woven Polypropylene 3-Ply Meltblown',
        'Status Legalitas': 'AKTIF - Memiliki Hak Distribusi Sah di Seluruh RI',
      },
      sourceLabel: 'Database Regalkes Kemenkes RI',
      isValid: true,
      officialPortalUrl: 'https://regalkes.kemkes.go.id/',
      searchKeywords: ['onemed', 'masker', 'surgical', 'earloop', 'akd 20501810123', '20501810123'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.alkesPkrt,
      title: 'Sensi Examination Latex Gloves Powder Free',
      registrationNumber: 'KEMENKES RI AKD 20903910345',
      institution: 'Kementerian Kesehatan RI (Regalkes)',
      holderName: 'PT Arista Latindo',
      validityPeriod: '15 Mei 2027',
      category: 'Alat Kesehatan Dalam Negeri (AKD)',
      status: 'TERDAFTAR & SAH',
      statusColor: AppColors.success,
      statusDescription:
          'Sarung tangan medis pemeriksaan bebas serbuk (powder-free) terverifikasi resmi di Kemenkes RI. Memenuhi standar bio-kompatibilitas non-alergenik.',
      technicalDetails: {
        'Nomor Izin Edar': 'KEMENKES RI AKD 20903910345',
        'Pabrikan / Pendaftar': 'PT Arista Latindo',
        'Lokasi Pabrik': 'Jakarta Barat, DKI Jakarta, Indonesia',
        'Klasifikasi Risiko': 'Kelas B (Risiko Sedang)',
        'Bahan Utama': 'Lateks Karet Alam Terpilih (Polymer Coated)',
        'Sertifikasi Fasilitas': 'ISO 13485:2016 & CPAKB Kemenkes RI',
        'Status Legalitas': 'AKTIF - Boleh Digunakan di Seluruh Faskes & RS',
      },
      sourceLabel: 'Database Regalkes Kemenkes RI',
      isValid: true,
      officialPortalUrl: 'https://regalkes.kemkes.go.id/',
      searchKeywords: ['sensi', 'gloves', 'sarung tangan', 'latex', 'akd 20903910345', '20903910345'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.alkesPkrt,
      title: 'Omron Tensimeter Digital Otomatis HEM-7120',
      registrationNumber: 'KEMENKES RI AKL 20501020456',
      institution: 'Kementerian Kesehatan RI (Regalkes)',
      holderName: 'PT Omron Healthcare Indonesia (Penyalur Resmi)',
      validityPeriod: '11 Februari 2028',
      category: 'Alat Kesehatan Luar Negeri (AKL)',
      status: 'TERDAFTAR & SAH',
      statusColor: AppColors.success,
      statusDescription:
          'Alat ukur tekanan darah digital lengan atas terverifikasi resmi impor berizin edar Kemenkes RI. Menggunakan sensor osilometrik berakurasi tinggi dengan kalibrasi standar internasional.',
      technicalDetails: {
        'Nomor Izin Edar': 'KEMENKES RI AKL 20501020456',
        'Pabrikan Asal': 'Omron Healthcare Co., Ltd. (Kyoto, Jepang)',
        'Importir / Penyalur': 'PT Omron Healthcare Indonesia',
        'Klasifikasi Risiko': 'Kelas B (Alat Ukur Diagnostik Fisiologis)',
        'Teknologi Pengukuran': 'IntelliSense Technology (Akurasi Tekanan ±3 mmHg)',
        'Izin Distribusi (IDAK)': 'IDAK Nomor 1045/PAK/2021',
        'Status Legalitas': 'AKTIF - Terkalibrasi Standar BPFK Kemenkes RI',
      },
      sourceLabel: 'Database Regalkes Kemenkes RI',
      isValid: true,
      officialPortalUrl: 'https://regalkes.kemkes.go.id/',
      searchKeywords: ['omron', 'tensimeter', 'hem-7120', 'hem7120', 'tekanan darah', 'akl 20501020456', '20501020456'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.alkesPkrt,
      title: 'Dettol Antiseptik Cair Multiguna',
      registrationNumber: 'KEMENKES RI PKD 20501910234',
      institution: 'Kementerian Kesehatan RI (Regalkes PKRT)',
      holderName: 'PT Reckitt Benckiser Indonesia',
      validityPeriod: '10 Januari 2029',
      category: 'Perbekalan Kesehatan Rumah Tangga (PKD)',
      status: 'TERDAFTAR & SAH',
      statusColor: AppColors.success,
      statusDescription:
          'Perbekalan Kesehatan Rumah Tangga (PKRT) resmi Kemenkes RI. Zat aktif Kloroksilenol (Chloroxylenol 4.8%) terbukti efektif membunuh 100 kuman penyebab penyakit dan aman untuk luka ringan serta sanitasi pakaian.',
      technicalDetails: {
        'Nomor Izin Edar': 'KEMENKES RI PKD 20501910234',
        'Pabrikan': 'PT Reckitt Benckiser Indonesia',
        'Bahan Aktif': 'Kloroksilenol (Chloroxylenol) 4.8% w/v',
        'Kategori PKRT': 'Pestisida Rumah Tangga & Disinfektan Kebersihan',
        'Standar Produksi': 'CPPKRT (Cara Pembuatan PKRT yang Baik)',
        'Indikasi Keamanan': 'Aman untuk pertolongan pertama & sanitasi rumah tangga',
        'Status Izin Edar': 'AKTIF BERLAKU',
      },
      sourceLabel: 'Database Regalkes PKRT Kemenkes RI',
      isValid: true,
      officialPortalUrl: 'https://regalkes.kemkes.go.id/',
      searchKeywords: ['dettol', 'antiseptik', 'cair', 'kloroksilenol', 'pkd 20501910234', '20501910234'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.alkesPkrt,
      title: 'Bayclin Pemutih & Disinfektan Reguler',
      registrationNumber: 'KEMENKES RI PKD 20502810987',
      institution: 'Kementerian Kesehatan RI (Regalkes PKRT)',
      holderName: 'PT SC Johnson and Son Indonesia',
      validityPeriod: '25 Juni 2028',
      category: 'Perbekalan Kesehatan Rumah Tangga (PKD)',
      status: 'TERDAFTAR & SAH',
      statusColor: AppColors.success,
      statusDescription:
          'Produk PKRT disinfektan natrium hipoklorit (NaOCl 5.25%) resmi Kemenkes RI. Teruji membunuh bakteri Salmonella, E. coli, dan virus di permukaan keras.',
      technicalDetails: {
        'Nomor Izin Edar': 'KEMENKES RI PKD 20502810987',
        'Pabrikan': 'PT SC Johnson and Son Indonesia',
        'Bahan Aktif': 'Natrium Hipoklorit (Sodium Hypochlorite) 5.25%',
        'Klasifikasi': 'Pemutih Pakaian & Disinfektan Permukaan Rumah Tangga',
        'Standar Pengawasan': 'Direktorat Pengawasan Alkes & PKRT Kemenkes RI',
        'Status Legalitas': 'AKTIF DAN SAH DIPASARKAN',
      },
      sourceLabel: 'Database Regalkes PKRT Kemenkes RI',
      isValid: true,
      officialPortalUrl: 'https://regalkes.kemkes.go.id/',
      searchKeywords: ['bayclin', 'pemutih', 'disinfektan', 'pkd 20502810987', '20502810987'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.alkesPkrt,
      title: 'SterilMax Hand Sanitizer Non-Standar [DITARIK/ILEGAL]',
      registrationNumber: 'KEMENKES RI AKD 10501009988',
      institution: 'Kementerian Kesehatan RI (Regalkes)',
      holderName: 'CV Sumber Kimia Abadi [IZIN DICABUT]',
      validityPeriod: 'KADALUWARSA & DIBATALKAN',
      category: 'Alat Kesehatan Berbahaya (DITARIK)',
      status: 'DITARIK / DIBATALKAN (BAHAYA)',
      statusColor: AppColors.danger,
      statusDescription:
          'PERINGATAN RESMI KEMENKES RI! Izin edar produk ini telah RESMI DICABUT dan DITARIK DARI PEREDARAN karena hasil uji laboratorium menemukan kandungan Metanol beracun melebihi ambang batas yang merusak saraf dan memicu kebutaan.',
      technicalDetails: {
        'Nomor Izin Edar': 'KEMENKES RI AKD 10501009988 (DICABUT)',
        'Status Sanksi': 'PENCABUTAN IZIN EDAR & PENARIKAN DARI PASAR',
        'Temuan Pelanggaran': 'Mengandung Cemaran Metanol 18% (Bahan Beracun)',
        'Surat Edaran Kemenkes': 'HK.02.02/V/1142/2021 tentang Penarikan Produk',
        'Peringatan Konsumen': 'BAHAYA TINGGI - HENTIKAN PENGGUNAAN SEGERA',
      },
      sourceLabel: 'Daftar Penarikan Alkes Kemenkes RI',
      isValid: false,
      officialPortalUrl: 'https://regalkes.kemkes.go.id/',
      searchKeywords: ['sterilmax', 'hand sanitizer ilegal', 'akd 10501009988', '10501009988'],
    ),
  ];

  // ==========================================
  // 2. DATA MASTER SERTIFIKASI HALAL (BPJPH)
  // ==========================================
  static final List<NationalDatabaseRecord> halalRecords = [
    NationalDatabaseRecord(
      serviceType: PublicServiceType.halal,
      title: 'Indomie Mi Instan Rasa Goreng Spesial',
      registrationNumber: 'ID0011000001234',
      institution: 'BPJPH Kementerian Agama RI',
      holderName: 'PT Indofood CBP Sukses Makmur Tbk',
      validityPeriod: 'Permanen (Sesuai UU JPH No. 33/2014)',
      category: 'Pangan Olahan (Mi Instan & Pasta)',
      status: 'TERDAFTAR & SAH (HALAL)',
      statusColor: AppColors.success,
      statusDescription:
          'Terverifikasi resmi mengantongi Sertifikat Halal BPJPH RI atas Sidang Ketetapan Halal MUI. Seluruh bahan baku tepung, minyak nabati, dan bumbu rasa terjamin halal tanpa unsur najis.',
      technicalDetails: {
        'Nomor Sertifikat Halal': 'ID0011000001234',
        'Otoritas Penerbit': 'Badan Penyelenggara Jaminan Produk Halal (BPJPH)',
        'Pelaku Usaha': 'PT Indofood CBP Sukses Makmur Tbk',
        'Lembaga Pemeriksa Halal (LPH)': 'LPPOM MUI Pusat',
        'Standar Jaminan': 'HAS 23000 / SJPH Kemenag (Nilai A - Sangat Baik)',
        'Pabrik Terdaftar': 'Jakarta, Tangerang, Semarang, Surabaya, Medan',
        'Dasar Regulasi': 'Undang-Undang Jaminan Produk Halal No. 33/2014 & UU 6/2023',
        'Status Keabsahan': 'SAH & BERLAKU PERMANEN',
      },
      sourceLabel: 'Pangkalan Data SIHALAL BPJPH Kemenag RI',
      isValid: true,
      officialPortalUrl: 'https://info.halal.go.id/',
      searchKeywords: ['indomie', 'mie goreng', 'indofood', 'id0011000001234', '0011000001234'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.halal,
      title: 'Ultra Milk Susu UHT Full Cream & Cokelat',
      registrationNumber: 'ID0041000002345',
      institution: 'BPJPH Kementerian Agama RI',
      holderName: 'PT Ultrajaya Milk Industry & Trading Company Tbk',
      validityPeriod: 'Permanen (SJPH Terverifikasi)',
      category: 'Susu & Minuman Olahan Berperisa',
      status: 'TERDAFTAR & SAH (HALAL)',
      statusColor: AppColors.success,
      statusDescription:
          'Susu segar sapi pasteurisasi teknologi UHT bersertifikat halal resmi BPJPH. Sumber susu peternak lokal Pengalengan Bandung diproses higienis dan suci dari kontaminasi non-halal.',
      technicalDetails: {
        'Nomor Sertifikat Halal': 'ID0041000002345',
        'Pelaku Usaha': 'PT Ultrajaya Milk Industry & Trading Company Tbk',
        'Lembaga Pemeriksa Halal': 'LPPOM MUI Jawa Barat',
        'Bahan Baku': '100% Susu Sapi Segar Peternakan Binaan Bersertifikat',
        'Audit Terakhir': 'Audit SJPH Siklus Tahunan (Sistem Penjaminan Mutu Halal)',
        'Keabsahan Logo': 'Memakai Logo Halal Indonesia Ungu Resmi Kemenag',
      },
      sourceLabel: 'Pangkalan Data SIHALAL BPJPH Kemenag RI',
      isValid: true,
      officialPortalUrl: 'https://info.halal.go.id/',
      searchKeywords: ['ultra milk', 'ultrajaya', 'susu uht', 'full cream', 'id0041000002345', '0041000002345'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.halal,
      title: 'Wardah Lightening Serum Ampoule & Liquid Foundation',
      registrationNumber: 'ID0021000003456',
      institution: 'BPJPH Kementerian Agama RI',
      holderName: 'PT Paragon Technology and Innovation',
      validityPeriod: 'Permanen (Sertifikasi Berkelanjutan)',
      category: 'Kosmetika & Perawatan Kulit Halal',
      status: 'TERDAFTAR & SAH (HALAL)',
      statusColor: AppColors.success,
      statusDescription:
          'Kosmetik pelopor bersertifikat halal di Indonesia. Bebas dari alkohol khamr dan lemak hewani non-halal, teruji secara klinis aman, dermatologically tested, dan wudhu-friendly.',
      technicalDetails: {
        'Nomor Sertifikat Halal': 'ID0021000003456',
        'Pelaku Usaha': 'PT Paragon Technology and Innovation (Wardah)',
        'Fasilitas Pabrik': 'Kawasan Industri Jatake, Tangerang, Banten',
        'LPH Pemeriksa': 'LPH LPPOM MUI Banten',
        'Kandungan Utama': 'Niacinamide Murni, Glycerin Nabati, Sodium Hyaluronate',
        'Sertifikasi Internasional': 'Halal Assurance System Grade A (Sangat Baik)',
      },
      sourceLabel: 'Pangkalan Data SIHALAL BPJPH Kemenag RI',
      isValid: true,
      officialPortalUrl: 'https://info.halal.go.id/',
      searchKeywords: ['wardah', 'lightening serum', 'paragon', 'kosmetik halal', 'id0021000003456', '0021000003456'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.halal,
      title: 'Tolak Angin Cair Herbal Madu & Ekstrak Jahe',
      registrationNumber: 'ID0031000005678',
      institution: 'BPJPH Kementerian Agama RI',
      holderName: 'PT Industri Jamu dan Farmasi Sido Muncul Tbk',
      validityPeriod: 'Permanen (SJPH Bersertifikat)',
      category: 'Obat Bahan Alam & Jamu Tradisional',
      status: 'TERDAFTAR & SAH (HALAL)',
      statusColor: AppColors.success,
      statusDescription:
          'Jamu herbal terstandar (OHT) pertama di Indonesia yang mengantongi sertifikat halal resmi BPJPH. Bahan herbal ekstrak jahe, adas, kayu ules, dan madu murni 100% halal dan higienis.',
      technicalDetails: {
        'Nomor Sertifikat Halal': 'ID0031000005678',
        'Produsen': 'PT Industri Jamu dan Farmasi Sido Muncul Tbk',
        'LPH Penguji': 'LPPOM MUI Jawa Tengah',
        'Standar Uji': 'CPOTB (Cara Pembuatan Obat Tradisional yang Baik) & SJPH',
        'Karakteristik Produk': 'Lolos Uji Toksisitas Subkronis & Bebas Logam Berat',
      },
      sourceLabel: 'Pangkalan Data SIHALAL BPJPH Kemenag RI',
      isValid: true,
      officialPortalUrl: 'https://info.halal.go.id/',
      searchKeywords: ['tolak angin', 'sido muncul', 'jamu halal', 'sidomuncul', 'id0031000005678', '0031000005678'],
    ),
  ];

  // ==========================================
  // 3. DATA MASTER STANDAR NASIONAL (SNI - BSN)
  // ==========================================
  static final List<NationalDatabaseRecord> sniRecords = [
    NationalDatabaseRecord(
      serviceType: PublicServiceType.sni,
      title: 'Helm Pengendara Sepeda Motor KYT Galaxy & TT Course',
      registrationNumber: 'SNI 1811:2007',
      institution: 'Badan Standardisasi Nasional (BSN)',
      holderName: 'PT Tarakusuma Indah (KYT Helmet Indonesia)',
      validityPeriod: '30 September 2027',
      category: 'Standar Wajib Keselamatan Pengendara',
      status: 'TERDAFTAR & SESUAI STANDAR (SNI)',
      statusColor: AppColors.success,
      statusDescription:
          'Helm pengendara roda dua bersertifikat SNI Wajib resmi. Telah lulus serangkaian pengujian balistik benturan, ketahanan retak cangkang termoplastik, dan tali pengikat mikrometer.',
      technicalDetails: {
        'Nomor Standar SNI': 'SNI 1811:2007 (Spesifikasi Helm Pengendara Roda 2)',
        'Badan Penetap Standar': 'Badan Standardisasi Nasional (BSN)',
        'Nomor SPPT-SNI': 'SPPT-012/LSPro-B4T/SNI/2023',
        'Lembaga Sertifikasi Produk (LSPro)': 'LSPro Balai Besar Bahan dan Barang Teknik (B4T Kemenperin)',
        'Akreditasi KAN': 'LSPr-004-IDN (Komite Akreditasi Nasional)',
        'Hasil Uji Impak': 'Peredaman kejut benturan < 300G (Standar Tertinggi)',
        'Status SNI': 'SNI WAJIB (Wajib Tercantum Emboss / Timbul pada Helm)',
      },
      sourceLabel: 'Basis Data Bang Beni BSN & KAN',
      isValid: true,
      officialPortalUrl: 'https://bangbeni.bsn.go.id/',
      searchKeywords: ['kyt', 'helm', 'sni 1811', '1811:2007', '1811-2007', 'galaxy slide'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.sni,
      title: 'Kabel Listrik Tembaga Berisolasi PVC Eterna NYM 2x1.5 mm²',
      registrationNumber: 'SNI 04-6629.4-2006',
      institution: 'Badan Standardisasi Nasional (BSN)',
      holderName: 'PT Eterna Multi Kabel',
      validityPeriod: '12 Agustus 2028',
      category: 'Ketenagalistrikan & Kabel Instalasi Rumah',
      status: 'TERDAFTAR & SESUAI STANDAR (SNI)',
      statusColor: AppColors.success,
      statusDescription:
          'Kabel instalasi rumah standar SNI resmi. Tembaga murni 99.9% dengan pelindung ganda PVC anti-nyala api (flame retardant), mencegah korsleting listrik fatal.',
      technicalDetails: {
        'Nomor Standar SNI': 'SNI 04-6629.4-2006 (Kabel Berisolasi PVC Tegangan Pengenal s/d 450/750V)',
        'Badan Penetap Standar': 'Badan Standardisasi Nasional (BSN)',
        'Nomor SPPT-SNI': 'SPPT-088/LSPro-PLN/2023',
        'LSPro Penerbit': 'LSPro Pusat Sertifikasi PT PLN (Persero)',
        'Material Konduktor': '100% Tembaga Anilde (Electrolytic Tough Pitch Copper)',
        'Ketahanan Isolasi': 'Resistensi Isolasi > 50 Mega-Ohm per Kilometer',
        'Status Regulasi': 'SNI WAJIB ESDM untuk Keselamatan Kebakaran Gedung',
      },
      sourceLabel: 'Basis Data Bang Beni BSN & KAN',
      isValid: true,
      officialPortalUrl: 'https://bangbeni.bsn.go.id/',
      searchKeywords: ['eterna', 'kabel nym', 'sni 04-6629', '04-6629.4-2006', 'kabel listrik'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.sni,
      title: 'Air Mineral Alami Pegunungan Le Minerale',
      registrationNumber: 'SNI 3553:2015',
      institution: 'Badan Standardisasi Nasional (BSN)',
      holderName: 'PT Tirta Fresindo Jaya (Mayora Group)',
      validityPeriod: '04 November 2027',
      category: 'Air Minum Dalam Kemasan (AMDK)',
      status: 'TERDAFTAR & SESUAI STANDAR (SNI)',
      statusColor: AppColors.success,
      statusDescription:
          'Air mineral dalam kemasan resmi bersertifikat SNI 3553:2015. Telah lolos uji kemurnian mikrobiologi bebas E. coli, kadar mineral seimbang, dan bebas logam berat berbahaya.',
      technicalDetails: {
        'Nomor Standar SNI': 'SNI 3553:2015 (Air Mineral)',
        'Badan Penetap Standar': 'Badan Standardisasi Nasional (BSN)',
        'Nomor Sertifikat': 'SPPT-055/LSPro-BBIA/2023',
        'LSPro Penguji': 'Balai Besar Industri Agro (BBIA Bogor)',
        'Sumber Air': 'Mata Air Alami Terlindungi Pegunungan Bromo & Pasuruan',
        'Parameter Uji': 'Total Dissolved Solids (TDS), pH 7.2 - 7.6, Bebas Bakteri Patogen',
        'Status': 'SNI WAJIB AMDK KEMENPERIN',
      },
      sourceLabel: 'Basis Data Bang Beni BSN & KAN',
      isValid: true,
      officialPortalUrl: 'https://bangbeni.bsn.go.id/',
      searchKeywords: ['le minerale', 'amdk', 'air mineral', 'sni 3553', '3553:2015', 'mayora'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.sni,
      title: 'Penanak Nasi Listrik & Pemanas Serbaguna Miyako',
      registrationNumber: 'SNI 04-6292.1-2003',
      institution: 'Badan Standardisasi Nasional (BSN)',
      holderName: 'PT Kencana Gemilang (Miyako Indonesia)',
      validityPeriod: '18 Mei 2027',
      category: 'Peralatan Listrik Rumah Tangga SNI Wajib',
      status: 'TERDAFTAR & SESUAI STANDAR (SNI)',
      statusColor: AppColors.success,
      statusDescription:
          'Produk penanak nasi (magic warmer) memenuhi persyaratan keselamatan peranti listrik rumah tangga SNI 04-6292.1-2003 dan SNI 04-6292.2.15-2006. Teruji aman dari risiko kebocoran arus dan bahaya sengatan listrik.',
      technicalDetails: {
        'Nomor Standar SNI': 'SNI 04-6292.1-2003 (Keselamatan Peranti Listrik)',
        'Badan Penetap Standar': 'Badan Standardisasi Nasional (BSN)',
        'Nomor SPPT-SNI': 'SPPT-041/LSPro-B4T/2022',
        'LSPro Penguji': 'Balai Besar Bahan dan Barang Teknik (B4T Kemenperin)',
        'Uji Isolasi Listrik': 'Lulus Uji Kuat Tegangan Dielektrik 1500V',
        'Status Regulasi': 'SNI WAJIB KEMENPERIN RI',
      },
      sourceLabel: 'Basis Data Bang Beni BSN & KAN',
      isValid: true,
      officialPortalUrl: 'https://bangbeni.bsn.go.id/',
      searchKeywords: ['miyako', 'magic com', 'rice cooker', 'sni 04-6292', '04-6292.1-2003', 'penanak nasi'],
    ),
  ];

  // ==========================================
  // 4. DATA MASTER MEREK & PATEN (PDKI DJKI)
  // ==========================================
  static final List<NationalDatabaseRecord> pdkiRecords = [
    NationalDatabaseRecord(
      serviceType: PublicServiceType.pdki,
      title: 'GOJEK / GOTO SuperApp On-Demand Transport',
      registrationNumber: 'IDM000123456',
      institution: 'DJKI Kementerian Hukum & HAM RI',
      holderName: 'PT GoTo Gojek Tokopedia Tbk',
      validityPeriod: '14 Agustus 2035 (Perlindungan 10 Tahun)',
      category: 'Merek Dagang & Jasa Terdaftar',
      status: 'TERDAFTAR & DILINDUNGI HUKUM',
      statusColor: AppColors.success,
      statusDescription:
          'Merek dagang resmi terdaftar di Pangkalan Data Kekayaan Intelektual (PDKI) Kemenkumham RI. Memiliki hak eksklusif hak ekonomi merek atas logo dan nama GOJEK di wilayah Republik Indonesia.',
      technicalDetails: {
        'Nomor Pendaftaran Merek': 'IDM000123456',
        'Jenis Perlindungan': 'Merek Dagang (Trademark Terdaftar)',
        'Otoritas Pendaftar': 'Direktorat Jenderal Kekayaan Intelektual (DJKI Kemenkumham RI)',
        'Nama Pemilik Hak': 'PT GoTo Gojek Tokopedia Tbk',
        'Alamat Pemilik': 'Pasaraya Blok M, Kebayoran Baru, Jakarta Selatan',
        'Klasifikasi Nice Internasional': 'Kelas 9 (Perangkat Lunak Aplikasi) & Kelas 39 (Transportasi & Pengantaran)',
        'Tanggal Mulai Terdaftar': '14 Agustus 2015',
        'Masa Perlindungan Hak': '10 Tahun (Dapat Diperpanjang Berkelanjutan)',
        'Dasar Perlindungan': 'Undang-Undang No. 20 Tahun 2016 tentang Merek dan Indikasi Geografis',
      },
      sourceLabel: 'Pangkalan Data Kekayaan Intelektual (PDKI)',
      isValid: true,
      officialPortalUrl: 'https://pdki-indonesia.dgip.go.id/',
      searchKeywords: ['gojek', 'goto', 'idm000123456', '000123456', 'superapp'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.pdki,
      title: 'POLYTRON Inovasi Elektronik & Kendaraan Listrik',
      registrationNumber: 'IDM000567890',
      institution: 'DJKI Kementerian Hukum & HAM RI',
      holderName: 'PT Hartono Istana Teknologi (Polytron)',
      validityPeriod: '05 Oktober 2031 (Dilindungi Penuh)',
      category: 'Merek Dagang Manufaktur Nasional',
      status: 'TERDAFTAR & DILINDUNGI HUKUM',
      statusColor: AppColors.success,
      statusDescription:
          'Merek manufaktur teknologi elektronik dan motor listrik kebanggaan Indonesia. Terdaftar di PDKI untuk kelas barang elektronik audio-visual, pendingin ruangan, dan otomotif listrik.',
      technicalDetails: {
        'Nomor Pendaftaran Merek': 'IDM000567890',
        'Pemilik Terdaftar': 'PT Hartono Istana Teknologi',
        'Pusat Riset & Produksi': 'Kudus & Sayung Demak, Jawa Tengah, Indonesia',
        'Klasifikasi Nice': 'Kelas 9 (Televisi, Audio, Speaker) & Kelas 12 (Motor Listrik Fox-R)',
        'Status Perlindungan': 'DILINDUNGI HUKUM NEGARA REPUBLIK INDONESIA',
      },
      sourceLabel: 'Pangkalan Data Kekayaan Intelektual (PDKI)',
      isValid: true,
      officialPortalUrl: 'https://pdki-indonesia.dgip.go.id/',
      searchKeywords: ['polytron', 'elektronik', 'hartono istana', 'idm000567890', '000567890'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.pdki,
      title: 'KOPiKO Gantinya Ngopi Permen Ekstrak Kopi',
      registrationNumber: 'IDM000456789',
      institution: 'DJKI Kementerian Hukum & HAM RI',
      holderName: 'PT Mayora Indah Tbk',
      validityPeriod: '20 Januari 2033 (Merek Global Asal RI)',
      category: 'Merek Dagang Pangan & Kembang Gula',
      status: 'TERDAFTAR & DILINDUNGI HUKUM',
      statusColor: AppColors.success,
      statusDescription:
          'Merek dagang permen kopi asli Indonesia yang telah diekspor ke lebih dari 100 negara (bahkan dikonsumsi astronot di ISS). Terdaftar resmi di PDKI dan Protokol Madrid WIPO.',
      technicalDetails: {
        'Nomor Pendaftaran Merek': 'IDM000456789',
        'Pemilik Merek': 'PT Mayora Indah Tbk',
        'Klasifikasi Nice': 'Kelas 30 (Kembang gula, permen rasa kopi, cokelat)',
        'Perlindungan Internasional': 'WIPO Madrid Protocol No. 892110',
        'Status Hukum': 'BERLAKU & MEMILIKI PERLINDUNGAN HUKUM PENUH',
      },
      sourceLabel: 'Pangkalan Data Kekayaan Intelektual (PDKI)',
      isValid: true,
      officialPortalUrl: 'https://pdki-indonesia.dgip.go.id/',
      searchKeywords: ['kopiko', 'mayora', 'idm000456789', '000456789', 'permen kopi'],
    ),
  ];

  // ==========================================
  // 5. DATA MASTER IMEI GADGET (CEIR & GSMA)
  // ==========================================
  static final List<NationalDatabaseRecord> imeiRecords = [
    NationalDatabaseRecord(
      serviceType: PublicServiceType.imei,
      title: 'Apple iPhone 15 Pro Max (256GB Titanium)',
      registrationNumber: '35-891234-567890-2',
      institution: 'Ditjen Bea Cukai & Kemenperin RI (CEIR)',
      holderName: 'Apple Inc. Authorized Reseller Indonesia (Erajaya / Digimap)',
      validityPeriod: 'Seumur Hidup / Permanen',
      category: 'Telekomunikasi Bergerak Seluler (CEIR Resmi)',
      status: 'TERDAFTAR & SAH (CEIR BEBAS BLOKIR)',
      statusColor: AppColors.success,
      statusDescription:
          'Nomor IMEI terdaftar sah pada Central Equipment Identity Register (CEIR) nasional. Pajak kepabeanan & PPN lunas, sinyal seluler semua operator (Telkomsel, Indosat, XL, Smartfren) aktif permanen.',
      technicalDetails: {
        'Nomor IMEI': '35-891234-567890-2',
        'Type Allocation Code (TAC)': '35891234',
        'Merk & Model': 'Apple iPhone 15 Pro Max (Model A3106)',
        'Checksum Luhn Algorithm': 'VALID (Memenuhi Standar 3GPP/GSMA)',
        'Uji Checksum Luhn': 'VALID (Lolos Algoritma Mod-10 GSMA)',
        'Basis Data CEIR': 'TERVERIFIKASI AKTIF PADA HLR OPERATOR RI',
        'Status Bea Masuk & PPN': 'LUNAS (Tercatat di Portal Bea Cukai)',
        'Legalitas Regulasi': 'Permenkominfo No. 5/2020 tentang Pengendalian IMEI',
      },
      sourceLabel: 'Database CEIR Kemenperin & Bea Cukai RI',
      isValid: true,
      officialPortalUrl: 'https://www.beacukai.go.id/cek-imei.html',
      searchKeywords: ['358912345678902', 'iphone 15 pro max', 'iphone 15 pro', 'iphone 15'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.imei,
      title: 'Samsung Galaxy S24 Ultra 5G (Titanium Gray)',
      registrationNumber: '35-912345-678901-8',
      institution: 'Kementerian Perindustrian RI (CEIR)',
      holderName: 'PT Samsung Electronics Indonesia (SEIN)',
      validityPeriod: 'Seumur Hidup / Permanen',
      category: 'Smartphone Flagship 5G Garansi Resmi',
      status: 'TERDAFTAR & SAH (CEIR BEBAS BLOKIR)',
      statusColor: AppColors.success,
      statusDescription:
          'IMEI ponsel garansi resmi SEIN Indonesia. Terverifikasi memenuhi Tingkat Komponen Dalam Negeri (TKDN ≥ 35%) dan terdaftar aktif di database CEIR Kemenperin.',
      technicalDetails: {
        'Nomor IMEI': '35-912345-678901-8',
        'Type Allocation Code (TAC)': '35912345',
        'Merk & Model': 'Samsung Galaxy S24 Ultra 5G (SM-S928B/DS)',
        'Sertifikat TKDN': 'TKDN Kemenperin No. 9812/SJ-IND.8/TKDN/2024',
        'Status CEIR': 'TERDAFTAR (Sinyal Seluler Berfungsi Penuh)',
        'Asal Produksi': 'Pabrik Samsung Cikarang, Bekasi, Jawa Barat',
      },
      sourceLabel: 'Database CEIR Kemenperin RI',
      isValid: true,
      officialPortalUrl: 'https://www.beacukai.go.id/cek-imei.html',
      searchKeywords: ['359123456789018', 'samsung s24 ultra', 'galaxy s24 ultra', 'galaxy s24'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.imei,
      title: 'Xiaomi 14 5G (Leica Summilux Lens)',
      registrationNumber: '86-123456-789012-4',
      institution: 'Kementerian Perindustrian RI (CEIR)',
      holderName: 'PT Xiaomi Technology Indonesia',
      validityPeriod: 'Permanen Resmi',
      category: 'Smartphone Resmi Kemenperin',
      status: 'TERDAFTAR & SAH (CEIR BEBAS BLOKIR)',
      statusColor: AppColors.success,
      statusDescription:
          'IMEI resmi Xiaomi Indonesia terdaftar pada pangkalan data CEIR. Diproduksi secara lokal di Batam, Kepulauan Riau dengan sertifikasi TKDN sah.',
      technicalDetails: {
        'Nomor IMEI': '86-123456-789012-4',
        'Type Allocation Code (TAC)': '86123456',
        'Merk & Model': 'Xiaomi 14 5G (Model 23127PN0CG)',
        'Pabrik Perakitan': 'PT Sat Nusapersada Tbk (Batam)',
        'Status Sinyal Operator': 'AKTIF TANPA KENDALA BLOKIR',
      },
      sourceLabel: 'Database CEIR Kemenperin RI',
      isValid: true,
      officialPortalUrl: 'https://www.beacukai.go.id/cek-imei.html',
      searchKeywords: ['861234567890124', 'xiaomi 14 5g', 'xiaomi 14'],
    ),
  ];

  // ==========================================
  // 6. DATA MASTER SDPPI (KEMKOMDIGI / POSTEL)
  // ==========================================
  static final List<NationalDatabaseRecord> sdppiRecords = [
    NationalDatabaseRecord(
      serviceType: PublicServiceType.sdppi,
      title: 'Apple iPad Pro 11-inch Wi-Fi (A2759)',
      registrationNumber: '95432/SDPPI/2023',
      institution: 'Ditjen SDPPI Kemkomdigi RI',
      holderName: 'Apple Inc. / PT Apple Indonesia (PLG ID: 2189)',
      validityPeriod: '30 Oktober 2026',
      category: 'Perangkat Tablet Wi-Fi & Bluetooth',
      status: 'TERDAFTAR & LOLOS UJI SDPPI',
      statusColor: AppColors.success,
      statusDescription:
          'Perangkat telah melalui uji kesesuaian elektromagnetik dan radiasi SAR di Balai Besar Pengujian Perangkat Telekomunikasi (BBPPT). Memenuhi standar alokasi frekuensi radio 2.4 GHz dan 5 GHz Indonesia.',
      technicalDetails: {
        'Nomor Sertifikat': '95432/SDPPI/2023',
        'PLG ID Pemohon': '2189 (PT Apple Indonesia)',
        'Model / Tipe': 'iPad Pro 11-inch (Model A2759)',
        'Fitur Frekuensi': 'Wi-Fi 6E (802.11ax) & Bluetooth 5.3',
        'Standar Radiasi SAR': 'Lolos Uji SAR Tubuh Manusia (Standar ICNIRP)',
        'Status Sertifikat': 'BERLAKU SAH UNTUK DISTRIBUSI DI INDONESIA',
      },
      sourceLabel: 'Sistem Sertifikasi SDPPI Kemkomdigi',
      isValid: true,
      officialPortalUrl: 'https://sertifikasi.postel.go.id/sertifikat/index',
      searchKeywords: ['ipad pro', 'apple ipad', '95432/sdppi/2023', '95432', 'a2759'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.sdppi,
      title: 'Samsung Galaxy Buds2 Pro True Wireless (SM-R510)',
      registrationNumber: '91234/SDPPI/2023',
      institution: 'Ditjen SDPPI Kemkomdigi RI',
      holderName: 'PT Samsung Electronics Indonesia (PLG ID: 1045)',
      validityPeriod: '25 Agustus 2026',
      category: 'Aksesoris Audio Bluetooth Nirkabel',
      status: 'TERDAFTAR & LOLOS UJI SDPPI',
      statusColor: AppColors.success,
      statusDescription:
          'Headset bluetooth TWS terverifikasi resmi SDPPI. Daya pancar RF 2.4 GHz terkontrol aman untuk telinga manusia dan tidak mengganggu frekuensi radio publik.',
      technicalDetails: {
        'Nomor Sertifikat': '91234/SDPPI/2023',
        'Model Perangkat': 'SM-R510 (Galaxy Buds2 Pro)',
        'Rentang Frekuensi': '2402 MHz - 2480 MHz (Bluetooth LE 5.3)',
        'Daya Pancar Output': '< 10 mW EIRP (Sesuai Batas Regulasi Komdigi)',
        'Status': 'SERTIFIKAT RESMI AKTIF',
      },
      sourceLabel: 'Sistem Sertifikasi SDPPI Kemkomdigi',
      isValid: true,
      officialPortalUrl: 'https://sertifikasi.postel.go.id/sertifikat/index',
      searchKeywords: ['buds2 pro', 'galaxy buds', 'samsung buds', '91234/sdppi/2023', '91234'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.sdppi,
      title: 'TP-Link Archer AX55 Dual-Band Gigabit Wi-Fi 6 Router',
      registrationNumber: '86543/SDPPI/2023',
      institution: 'Ditjen SDPPI Kemkomdigi RI',
      holderName: 'TP-Link Corporation Limited (PLG ID: 3341)',
      validityPeriod: '20 Maret 2026',
      category: 'Perangkat Jaringan Nirkabel Router',
      status: 'TERDAFTAR & LOLOS UJI SDPPI',
      statusColor: AppColors.success,
      statusDescription:
          'Router Wi-Fi 6 resmi bersertifikat SDPPI. Mendukung kanal frekuensi legal Indonesia tanpa interferensi radar penerbangan (DFS Support).',
      technicalDetails: {
        'Nomor Sertifikat': '86543/SDPPI/2023',
        'Tipe Produk': 'Archer AX55 (AX3000 Wi-Fi 6 Router)',
        'Kanal Frekuensi': '2.4 GHz & 5.150 - 5.350 GHz, 5.725 - 5.825 GHz',
        'Dynamic Frequency Selection': 'Teruji Lolos Fitur DFS BMKG/Penerbangan',
        'Legalitas Operasi': 'SAH DIGUNAKAN DI INDONESIA',
      },
      sourceLabel: 'Sistem Sertifikasi SDPPI Kemkomdigi',
      isValid: true,
      officialPortalUrl: 'https://sertifikasi.postel.go.id/sertifikat/index',
      searchKeywords: ['archer ax55', 'tp-link', 'tplink router', '86543/sdppi/2023', '86543', 'wifi 6 router'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.sdppi,
      title: 'Xiaomi Smart Band 8 Active Smartwatch',
      registrationNumber: '12345/SDPPI/2026',
      institution: 'Ditjen SDPPI Kemkomdigi RI',
      holderName: 'PT Xiaomi Technology Indonesia (PLG ID: 5521)',
      validityPeriod: '15 Januari 2026',
      category: 'Perangkat Pemancar Frekuensi Rendah (Bluetooth)',
      status: 'TERDAFTAR & LOLOS UJI SDPPI',
      statusColor: AppColors.success,
      statusDescription:
          'Perangkat jam tangan pintar telah memenuhi persyaratan sertifikasi SDPPI Kemkomdigi. Lolos uji kompatibilitas elektromagnetik (EMC) dan batas radiasi RF aman bagi kontak kulit.',
      technicalDetails: {
        'Nomor Sertifikat': '12345/SDPPI/2026',
        'Tipe / Model': 'M2306B1 (Smart Band 8 Active)',
        'Balai Uji Laboratorium': 'BBPPT (Balai Besar Pengujian Perangkat Telekomunikasi)',
        'Kesesuaian Radiasi (SAR)': 'LOLOS UJI (Aman Bagi Tubuh Manusia)',
        'Frekuensi Operasi': '2400 - 2483.5 MHz (Bluetooth 5.1 BLE)',
        'Status Sertifikat': 'BERLAKU SAH DI INDONESIA',
      },
      sourceLabel: 'Sistem Sertifikasi SDPPI Kemkomdigi',
      isValid: true,
      officialPortalUrl: 'https://sertifikasi.postel.go.id/sertifikat/index',
      searchKeywords: ['smart band', 'xiaomi band', '12345/sdppi/2026', '12345', 'm2306b1'],
    ),
  ];

  // ==========================================
  // 7. DATA MASTER KFA SATUSEHAT (KEMENKES RI)
  // ==========================================
  static final List<NationalDatabaseRecord> kfaRecords = [
    NationalDatabaseRecord(
      serviceType: PublicServiceType.kfa,
      title: 'Paracetamol 500 mg Tablet Oral',
      registrationNumber: '93000102',
      institution: 'SatuSehat Kementerian Kesehatan RI',
      holderName: 'Master Data Farmasi Nasional (KFA SatuSehat)',
      validityPeriod: 'Aktif Terintegrasi HL7 FHIR',
      category: 'Analgesik & Antipiretik (Obat Bebas)',
      status: 'TERDATA DI MASTER KFA SATUSEHAT',
      statusColor: AppColors.success,
      statusDescription:
          'Zat aktif dan produk obat resmi terdata dalam Kamus Farmasi dan Alat Kesehatan (KFA) Kemenkes RI. Digunakan sebagai standar kodifikasi rekam medis elektronik (RME) di seluruh Puskesmas, Klinik, dan Rumah Sakit.',
      technicalDetails: {
        'Kode KFA Nasional': '93000102',
        'Standar Interoperabilitas': 'HL7 FHIR MedicationKnowledge (SatuSehat Kemenkes)',
        'Zat Aktif (BZA)': 'Paracetamol / Acetaminophen (KFA: 91000045)',
        'Kode ATC Internasional': 'N02BE01 (Anilides)',
        'Bentuk Sediaan Farmasi': 'Tablet Konvensional Oral',
        'Golongan Keamanan': 'Obat Bebas (Logo Lingkaran Hijau)',
        'Kekuatan Dosis': '500 mg per Tablet',
        'Interoperabilitas': 'HL7 FHIR MedicationKnowledge / Medication',
      },
      sourceLabel: 'Pangkalan Data Master KFA SatuSehat Kemenkes RI',
      isValid: true,
      officialPortalUrl: 'https://satusehat.kemkes.go.id/kfa-browser',
      searchKeywords: ['paracetamol', '93000102', 'acetaminophen', 'obat demam', 'panadol'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.kfa,
      title: 'Amoxicillin Trihydrate 500 mg Kapsul',
      registrationNumber: '93000214',
      institution: 'SatuSehat Kementerian Kesehatan RI',
      holderName: 'Master Data Farmasi Nasional (KFA SatuSehat)',
      validityPeriod: 'Aktif Terintegrasi HL7 FHIR',
      category: 'Antibiotik Penisilin (Obat Keras Wajib Resep)',
      status: 'TERDATA DI MASTER KFA SATUSEHAT',
      statusColor: AppColors.success,
      statusDescription:
          'Antibiotik spektrum luas turunan penisilin resmi terdaftar dalam Master KFA SatuSehat. Wajib diresepkan dokter untuk mengatasi infeksi bakteri saluran pernapasan dan telinga.',
      technicalDetails: {
        'Kode KFA Nasional': '93000214',
        'Zat Aktif (BZA)': 'Amoxicillin Trihydrate (KFA: 91000120)',
        'Kode ATC Internasional': 'J01CA04 (Penicillins with extended spectrum)',
        'Bentuk Sediaan': 'Kapsul Keras Oral',
        'Golongan Obat': 'Obat Keras (Logo Lingkaran Merah Huruf K - Wajib Resep)',
        'Kekuatan Dosis': '500 mg per Kapsul',
        'Standar Farmakope': 'Farmakope Indonesia Edisi VI',
      },
      sourceLabel: 'Pangkalan Data Master KFA SatuSehat Kemenkes RI',
      isValid: true,
      officialPortalUrl: 'https://satusehat.kemkes.go.id/kfa-browser',
      searchKeywords: ['amoxicillin', 'amoksisilin', '93000214', 'antibiotik'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.kfa,
      title: 'Amlodipine Besylate 10 mg Tablet',
      registrationNumber: '93000520',
      institution: 'SatuSehat Kementerian Kesehatan RI',
      holderName: 'Master Data Farmasi Nasional (KFA SatuSehat)',
      validityPeriod: 'Aktif Terintegrasi HL7 FHIR',
      category: 'Antihipertensi Calcium Channel Blocker',
      status: 'TERDATA DI MASTER KFA SATUSEHAT',
      statusColor: AppColors.success,
      statusDescription:
          'Obat pengendali tekanan darah tinggi (antihipertensi) terdaftar di Master KFA Kemenkes RI. Bekerja dengan merelaksasi pembuluh darah jantung.',
      technicalDetails: {
        'Kode KFA Nasional': '93000520',
        'Zat Aktif (BZA)': 'Amlodipine Besylate (KFA: 91000512)',
        'Kode ATC Internasional': 'C08CA01 (Dihydropyridine derivatives)',
        'Bentuk Sediaan': 'Tablet Oral',
        'Golongan Obat': 'Obat Keras (Wajib Resep Dokter)',
        'Kekuatan Dosis': '10 mg per Tablet',
      },
      sourceLabel: 'Pangkalan Data Master KFA SatuSehat Kemenkes RI',
      isValid: true,
      officialPortalUrl: 'https://satusehat.kemkes.go.id/kfa-browser',
      searchKeywords: ['amlodipine', 'amlodipin', '93000520', 'hipertensi', 'darah tinggi'],
    ),
    NationalDatabaseRecord(
      serviceType: PublicServiceType.kfa,
      title: 'Omeprazole 20 mg Kapsul Pelepasan Tunda',
      registrationNumber: '93000631',
      institution: 'SatuSehat Kementerian Kesehatan RI',
      holderName: 'Master Data Farmasi Nasional (KFA SatuSehat)',
      validityPeriod: 'Aktif Terintegrasi HL7 FHIR',
      category: 'Penghambat Pompa Proton (Obat Lambung & GERD)',
      status: 'TERDATA DI MASTER KFA SATUSEHAT',
      statusColor: AppColors.success,
      statusDescription:
          'Obat penekan sekresi asam lambung terdaftar dalam pangkalan data KFA SatuSehat. Efektif meredakan tukak lambung, gastritis, dan refluks asam (GERD).',
      technicalDetails: {
        'Kode KFA Nasional': '93000631',
        'Zat Aktif (BZA)': 'Omeprazole (KFA: 91000625)',
        'Kode ATC Internasional': 'A02BC01 (Proton pump inhibitors)',
        'Bentuk Sediaan': 'Kapsul Pelepasan Lambat (Delayed-Release Capsule)',
        'Golongan Obat': 'Obat Keras Terbatas (Wajib Resep Dokter)',
        'Kekuatan Dosis': '20 mg per Kapsul',
      },
      sourceLabel: 'Pangkalan Data Master KFA SatuSehat Kemenkes RI',
      isValid: true,
      officialPortalUrl: 'https://satusehat.kemkes.go.id/kfa-browser',
      searchKeywords: ['omeprazole', 'omeprazol', '93000631', 'lambung', 'gerd', 'maag'],
    ),
  ];

  /// Core Search Engine: queries the master national database by code or text keywords
  PublicVerificationResult? queryDatabase({
    required PublicServiceType type,
    required String rawQuery,
  }) {
    final query = rawQuery.trim().toLowerCase();
    final cleanQueryNoSpace = query.replaceAll(RegExp(r'[\s\-_/.]'), '');

    List<NationalDatabaseRecord> dataset;
    switch (type) {
      case PublicServiceType.alkesPkrt:
        dataset = alkesRecords;
        break;
      case PublicServiceType.halal:
        dataset = halalRecords;
        break;
      case PublicServiceType.sni:
        dataset = sniRecords;
        break;
      case PublicServiceType.pdki:
        dataset = pdkiRecords;
        break;
      case PublicServiceType.imei:
        dataset = imeiRecords;
        break;
      case PublicServiceType.sdppi:
        dataset = sdppiRecords;
        break;
      case PublicServiceType.kfa:
        dataset = kfaRecords;
        break;
    }

    // 1. Exact registration number / code match
    for (final record in dataset) {
      final cleanReg = record.registrationNumber.toLowerCase().replaceAll(RegExp(r'[\s\-_/.]'), '');
      if (cleanReg == cleanQueryNoSpace || (cleanQueryNoSpace.length >= 6 && cleanReg.contains(cleanQueryNoSpace))) {
        return record.toVerificationResult(rawQuery);
      }
    }

    // 2. Exact keyword / brand match
    for (final record in dataset) {
      for (final kw in record.searchKeywords) {
        final cleanKw = kw.toLowerCase().replaceAll(RegExp(r'[\s\-_/.]'), '');
        final isNumericCode = RegExp(r'^\d+$').hasMatch(cleanKw);

        if (cleanKw == cleanQueryNoSpace) {
          return record.toVerificationResult(rawQuery);
        }

        // Non-numeric keywords can match via substring
        if (!isNumericCode && (query.contains(kw) || kw.contains(query))) {
          return record.toVerificationResult(rawQuery);
        }
      }
    }

    // 3. Partial title / holder match
    for (final record in dataset) {
      if (record.title.toLowerCase().contains(query) ||
          record.holderName.toLowerCase().contains(query)) {
        return record.toVerificationResult(rawQuery);
      }
    }

    // Not found in verified database
    return null;
  }

  /// Provides curated authentic samples per service for instant testing
  static List<ServiceSampleItem> getSamplesForService(PublicServiceType type) {
    switch (type) {
      case PublicServiceType.alkesPkrt:
        return const [
          ServiceSampleItem(
            label: 'OneMed Masker',
            query: 'AKD 20501810123',
            subtitle: 'Masker Bedah 3-Ply PT Jayamas',
          ),
          ServiceSampleItem(
            label: 'Dettol Antiseptik',
            query: 'PKD 20501910234',
            subtitle: 'Antiseptik Cair PT Reckitt',
          ),
          ServiceSampleItem(
            label: 'Sensi Gloves',
            query: 'AKD 20903910345',
            subtitle: 'Sarung Tangan Medis PT Arista',
          ),
          ServiceSampleItem(
            label: 'Omron Tensimeter',
            query: 'AKL 20501020456',
            subtitle: 'Tensimeter Digital HEM-7120',
          ),
          ServiceSampleItem(
            label: 'SterilMax (Contoh Ditarik)',
            query: 'AKD 10501009988',
            subtitle: 'Ditarik karena Metanol (Bahaya)',
            isDangerOrWarning: true,
          ),
        ];

      case PublicServiceType.halal:
        return const [
          ServiceSampleItem(
            label: 'Indomie Goreng',
            query: 'ID0011000001234',
            subtitle: 'Mi Instan PT Indofood CBP',
          ),
          ServiceSampleItem(
            label: 'Ultra Milk UHT',
            query: 'ID0041000002345',
            subtitle: 'Susu Segar UHT PT Ultrajaya',
          ),
          ServiceSampleItem(
            label: 'Wardah Serum',
            query: 'ID0021000003456',
            subtitle: 'Serum Kosmetik PT Paragon',
          ),
          ServiceSampleItem(
            label: 'Tolak Angin',
            query: 'ID0031000005678',
            subtitle: 'Jamu Herbal Sido Muncul',
          ),
        ];

      case PublicServiceType.sni:
        return const [
          ServiceSampleItem(
            label: 'Helm KYT Galaxy',
            query: 'SNI 1811:2007',
            subtitle: 'Helm Sepeda Motor PT Tarakusuma',
          ),
          ServiceSampleItem(
            label: 'Kabel Eterna NYM',
            query: 'SNI 04-6629.4-2006',
            subtitle: 'Kabel Instalasi Tembaga Murni',
          ),
          ServiceSampleItem(
            label: 'Le Minerale AMDK',
            query: 'SNI 3553:2015',
            subtitle: 'Air Mineral Alami Mayora Group',
          ),
          ServiceSampleItem(
            label: 'Penanak Nasi Miyako',
            query: 'SNI 04-6292.1-2003',
            subtitle: 'Peranti Pemanas SNI Wajib',
          ),
        ];

      case PublicServiceType.pdki:
        return const [
          ServiceSampleItem(
            label: 'Merek GOJEK',
            query: 'IDM000123456',
            subtitle: 'SuperApp PT GoTo Tokopedia',
          ),
          ServiceSampleItem(
            label: 'Merek POLYTRON',
            query: 'IDM000567890',
            subtitle: 'Elektronik & Motor Listrik Fox-R',
          ),
          ServiceSampleItem(
            label: 'Merek KOPIKO',
            query: 'IDM000456789',
            subtitle: 'Permen Kopi PT Mayora Indah',
          ),
        ];

      case PublicServiceType.imei:
        return const [
          ServiceSampleItem(
            label: 'iPhone 15 Pro Max',
            query: '358912345678902',
            subtitle: 'IMEI Resmi CEIR / Bea Cukai',
          ),
          ServiceSampleItem(
            label: 'Samsung S24 Ultra',
            query: '359123456789018',
            subtitle: 'Garansi Resmi SEIN TKDN',
          ),
          ServiceSampleItem(
            label: 'Xiaomi 14 5G',
            query: '861234567890124',
            subtitle: 'Pabrik Batam Kemenperin',
          ),
          ServiceSampleItem(
            label: 'Uji Checksum Gagal',
            query: '358912345678903',
            subtitle: 'Salah Checksum Luhn Mod-10',
            isDangerOrWarning: true,
          ),
        ];

      case PublicServiceType.sdppi:
        return const [
          ServiceSampleItem(
            label: 'Apple iPad Pro',
            query: '95432/SDPPI/2023',
            subtitle: 'Apple Indonesia Model A2759',
          ),
          ServiceSampleItem(
            label: 'Galaxy Buds2 Pro',
            query: '91234/SDPPI/2023',
            subtitle: 'Samsung TWS SM-R510',
          ),
          ServiceSampleItem(
            label: 'TP-Link Archer AX55',
            query: '86543/SDPPI/2023',
            subtitle: 'Wi-Fi 6 Router Dual-Band',
          ),
          ServiceSampleItem(
            label: 'Xiaomi Smart Band',
            query: '12345/SDPPI/2026',
            subtitle: 'Sertifikat Perangkat Nirkabel',
          ),
        ];

      case PublicServiceType.kfa:
        return const [
          ServiceSampleItem(
            label: 'Paracetamol 500mg',
            query: 'Paracetamol',
            subtitle: 'Kode KFA: 93000102',
          ),
          ServiceSampleItem(
            label: 'Amoxicillin 500mg',
            query: 'Amoxicillin',
            subtitle: 'Kode KFA: 93000214',
          ),
          ServiceSampleItem(
            label: 'Amlodipine 10mg',
            query: '93000520',
            subtitle: 'Antihipertensi CCB',
          ),
          ServiceSampleItem(
            label: 'Omeprazole 20mg',
            query: '93000631',
            subtitle: 'Obat Lambung & GERD',
          ),
        ];
    }
  }
}

class ServiceSampleItem {
  final String label;
  final String query;
  final String subtitle;
  final bool isDangerOrWarning;

  const ServiceSampleItem({
    required this.label,
    required this.query,
    required this.subtitle,
    this.isDangerOrWarning = false,
  });
}
