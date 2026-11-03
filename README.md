# CekBPOM — Aplikasi Cek Keaslian Produk BPOM, Sertifikasi Halal & Legalitas Merek HKI

[![Flutter](https://img.shields.io/badge/Flutter-3.41.7-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11.5-0175C2?logo=dart)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://www.android.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Unit%20Tests-38%2F38%20Passed-brightgreen)](test)
[![Release](https://img.shields.io/badge/Version-1.3.0%2B4-orange.svg)](https://github.com/codewithtama/CekBPOM/releases)

**CekBPOM** adalah aplikasi Android berbasis Flutter yang dirancang untuk melindungi konsumen Indonesia dalam memverifikasi keaslian, keamanan, kehalalan, dan legalitas merek dari produk obat, kosmetik, jamu/obat tradisional, suplemen kesehatan, dan makanan/minuman olahan. 

Aplikasi terhubung langsung ke pangkalan data resmi nasional secara *real-time* tanpa data mock, didukung arsitektur *dual-fallback scraper*, analisis keamanan bahan berbahaya, pelacak kedaluwarsa PAO, serta sistem pembaruan aplikasi langsung (*Over-The-Air / OTA Updates*).

---

## Fitur Utama

### 1. Pindai Barcode Multi-Format & Galeri
- Pemindai kamera berkecepatan tinggi dengan auto-focus dan kontrol torch (lampu senter) untuk barcode 1D (EAN-13, EAN-8, UPC) serta QR Code 2D.
- **Zoom Multiplier (1.0x, 2.0x, 3.0x)** untuk memindai kode berukuran kecil atau dari jarak jauh.
- Dukungan pemindaian langsung dari **Galeri Foto** untuk tangkapan layar kemasan produk.
- Normalisasi cerdas format GS1 Application Identifier (AI 90) dan FNC1 separator.

### 2. Pindai Teks OCR (Optical Character Recognition)
- Pemindai berbasis *machine learning on-device* menggunakan Google ML Kit Text Recognition.
- Mendeteksi dan mengekstrak nomor registrasi BPOM (contoh: `NA18210100001`, `MD 231409001001`, `TR 203640101`) langsung dari label kemasan fisik tanpa perlu mengetik manual.

### 3. Pengecekan Database BPOM Real-Time & Fallback Scraper
- Permintaan otomatis ke API publik BPOM.
- **Sistem Fallback Web Scraper Mandiri**: Jika API utama BPOM lambat atau mengalami *Rate Limit / Down*, aplikasi secara dinamis mengambil *session cookie* dan *CSRF token* dari portal web `cekbpom.pom.go.id` lalu melakukan kueri DataTables resmi.
- Informasi lengkap yang disajikan:
  - Nomor registrasi resmi BPOM & status masa berlaku
  - Nama produk, merk dagang, dan kategori produk
  - Nama dan alamat produsen / pendaftar / importir
  - Bentuk sediaan dan jenis kemasan
  - Tanggal terbit izin edar dan tanggal kedaluwarsa
  - Komposisi bahan aktif / formula bahan lengkap

### 4. Sistem Indikator Status Keamanan
- **Hijau (AMAN):** Produk terdaftar secara resmi dan izin edar aktif berlaku.
- **Kuning (KEDALUWARSA / PERLU DICEK):** Izin edar telah habis masa berlakunya atau membutuhkan pengecekan rincian lebih lanjut.
- **Merah (TIDAK TERDAFTAR):** Data produk tidak ditemukan pada database BPOM (indikasi produk ilegal atau tiruan).

### 5. Cek Sertifikat Halal Indonesia (BPJPH Kemenag RI)
- Pencarian resmi pangkalan data sertifikat halal Badan Penyelenggara Jaminan Produk Halal (BPJPH) Kementerian Agama RI.
- Pencarian fleksibel berdasarkan nama produk, nama pelaku usaha / pabrik, atau nomor sertifikat halal.
- Kartu verifikasi halal otomatis pada setiap halaman detail produk BPOM yang di-scan.

### 6. Cek Legalitas Merek & HKI Terdaftar (DJKI Kemenkumham RI)
- Pencarian status pendaftaran Hak Kekayaan Intelektual (HKI / Hak Merek Dagang) nasional melalui pangkalan data DJKI Kemenkumham RI via `haki.id`.
- Menampilkan logo visual merek terdaftar langsung dari arsip resmi DJKI.
- Informasi detail pendaftaran:
  - Nomor Pendaftaran HKI (`IDM...`) dan Nomor Permohonan (`DID...`)
  - Status pendaftaran resmi (`(TM) Didaftar`)
  - Tanggal pendaftaran dan masa perlindungan hukum 10 tahun
  - Nama pemilik hak merek dan alamat domisili pemohon
  - Klasifikasi Nice internasional (Kelas 3 Kosmetik/Skincare, Kelas 5 Farmasi/Obat, Kelas 29/30 Pangan Olahan, Kelas 32 Minuman, Kelas 35 Retail, dll.)
  - Rincian barang dan jasa yang dilindungi hukum
- Fitur salin nomor registrasi, bagikan informasi merek, dan tautan langsung ke portal resmi PDKI Indonesia.
- Tombol integrasi verifikasi merek langsung dari halaman hasil scan produk BPOM.

### 7. Analisis Keamanan Bahan Kimia & Konflik Bahan (Ingredients Analyzer)
- **Deteksi Bahan Berbahaya & Ilegal:** Mendeteksi otomatis zat toksik terlarang (Merkuri, Hidrokuinon, Asam Retinoat dosis keras, Steroid, Pewarna Karsinogenik K3/K10, Timbal).
- **Deteksi Risiko Kehamilan & Menyusui:** Mengidentifikasi zat berisiko untuk ibu hamil/menyusui (Retinoid oral/topikal kuat, BHA konsentrasi tinggi, Salicylic Acid pekat, Formaldehyde, Arbutin dosis tinggi).
- **Deteksi Pemicu Jerawat Jamur (Fungal Acne / Malassezia Triggers):** Mendeteksi asam lemak rantai ester, minyak hewani/nabati tertentu, dan polisorbat.
- **Deteksi Alergen Wewangian & Alkohol Pengering:** Memeriksa keberadaan Fragrance, Essential Oils sensitif, serta Denatured Alcohol / SD Alcohol.
- **Deteksi Benturan Bahan Aktif (Cross-Product Conflict):** Memperingatkan jika produk kosmetik mengandung bahan aktif yang tidak boleh digunakan bersamaan dengan produk lain (misal: Retinol + AHA/BHA, Retinol + Pure Vitamin C dosis tinggi).

### 8. Pelacak Kedaluwarsa PAO (Period After Opening)
- Fitur pelacak masa simpan produk setelah segel dibuka (contoh: 6M, 12M, 24M).
- Menyimpan tanggal produk dibuka dan menghitung hari tersisa sebelum formula produk rusak atau kehilangan efektivitasnya.

### 9. Riwayat Offline & Cache Cerdas (Hive Database)
- Semua riwayat pemindaian disimpan secara lokal di perangkat menggunakan basis data NoSQL **Hive**.
- Ketika perangkat offline tanpa sinyal internet, data produk yang pernah di-scan tetap dapat dibuka dan ditinjau secara instan.

### 10. Pembaruan Aplikasi Otomatis (In-App OTA Updates)
- Terintegrasi dengan GitHub Releases API (`codewithtama/CekBPOM`).
- Pengecekan versi baru secara hening saat peluncuran aplikasi.
- Dialog pembaruan otomatis yang menampilkan nomor versi, tanggal rilis, catatan perubahan (*release notes*), dan ukuran file.
- Pengunduhan APK pembaruan dan pemasangan langsung di dalam aplikasi (OTA) dengan pemilihan file APK yang sesuai dengan arsitektur CPU perangkat (*arm64-v8a*, *armeabi-v7a*, *universal*).

---

## Arsitektur & Struktur Proyek

Proyek ini dibangun mengikuti prinsip arsitektur fitur (*feature-first*) dengan pemisahan lapisan data, logika bisnis, dan antarmuka pengguna:

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart      # Endpoint BPOM, BPJPH Halal, dan HKI DJKI
│   │   └── app_colors.dart         # Token warna desain Material 3
│   └── utils/
│       ├── barcode_parser.dart     # Ekstraksi GS1, AIM, dan validasi registrasi BPOM
│       ├── ingredients_analyzer.dart # Mesin analisis kandungan & bahan berbahaya
│       └── version_comparator.dart # Parser dan pembanding semver pembaruan OTA
├── data/
│   ├── models/
│   │   ├── app_update_info.dart    # Model payload rilis GitHub & selektor ABI APK
│   │   ├── halal_product_model.dart # Model sertifikat halal BPJPH
│   │   ├── pao_item_model.dart     # Model pelacak Period After Opening
│   │   ├── product_model.dart      # Model produk BPOM lengkap
│   │   └── trademark_model.dart    # Model merek dagang HKI DJKI Kemenkumham
│   └── services/
│       ├── bpom_api_service.dart   # Service kueri BPOM + fallback scraper
│       ├── haki_service.dart       # Service kueri merek dagang HKI
│       ├── halal_service.dart      # Service kueri sertifikat halal BPJPH
│       ├── history_service.dart    # Penyimpanan lokal Hive
│       └── update_service.dart     # Service pengecekan rilis & eksekusi OTA
└── presentation/
    ├── providers/                  # State management Riverpod
    │   ├── halal_search_provider.dart
    │   ├── history_provider.dart
    │   ├── pao_provider.dart
    │   ├── scan_provider.dart
    │   ├── search_provider.dart
    │   ├── trademark_provider.dart
    │   └── update_provider.dart
    ├── screens/                    # Halaman antarmuka pengguna (UI)
    │   ├── about_screen.dart
    │   ├── halal_search_screen.dart
    │   ├── history_screen.dart
    │   ├── home_screen.dart
    │   ├── info_screen.dart
    │   ├── ocr_scanner_screen.dart
    │   ├── result_screen.dart
    │   ├── scanner_screen.dart
    │   ├── search_screen.dart
    │   ├── settings_screen.dart
    │   └── trademark_search_screen.dart
    └── widgets/                    # Komponen UI modular
        ├── ingredients_analysis_dialog.dart
        ├── pao_setup_sheet.dart
        ├── product_card.dart
        ├── status_badge.dart
        └── update_dialog.dart
```

---

## Panduan Instalasi & Pengembangan

### Prasyarat
- **Flutter SDK**: `^3.41.7` (channel stable)
- **Dart SDK**: `^3.11.5`
- **Android SDK**: `compileSdk 36`, `targetSdk 34`, `minSdk 21`
- **JDK**: Java 17

### 1. Kloning Repositori
```bash
git clone https://github.com/codewithtama/CekBPOM.git
cd CekBPOM
```

### 2. Pasang Dependensi
```bash
flutter pub get
```

### 3. Jalankan Pengujian Unit & Analisis Statis
Proyek ini memiliki standar strict analysis tanpa peringatan (zero warnings):
```bash
# Analisis statis kode
dart analyze lib test

# Menjalankan seluruh test suite (38 unit tests)
flutter test
```

### 4. Jalankan Aplikasi pada Perangkat / Emulator
```bash
flutter run
```

### 5. Kompilasi APK Produksi

#### Kompilasi Universal APK:
```bash
flutter build apk --release
```

#### Kompilasi Split per ABI (Ukuran APK Ringkas untuk Distribusi):
```bash
flutter build apk --split-per-abi --release
```
Hasil build berada di direktori `build/app/outputs/flutter-apk/`:
- `app-arm64-v8a-release.apk` (Perangkat Android 64-bit modern)
- `app-armeabi-v7a-release.apk` (Perangkat Android 32-bit)
- `app-x86_64-release.apk` (Emulator PC / ChromeOS)

---

## Otomatisasi CI/CD & Rilis GitHub

Alur kerja GitHub Actions terkonfigurasi di [`.github/workflows/release.yml`](.github/workflows/release.yml). Setiap kali tag versi baru di-push (misal `v1.3.0`), GitHub Actions akan:
1. Memvalidasi kode dengan `flutter analyze` dan `flutter test`.
2. Mengompilasi APK universal serta APK split per arsitektur CPU.
3. Membuat GitHub Release publik dan melampirkan seluruh aset installer APK secara otomatis.
4. Aplikasi klien yang aktif di tangan pengguna akan mendeteksi rilis tersebut dan menawarkan dialog pembaruan in-app OTA.

---

## Lisensi & Batasan Tanggung Jawab

- **Lisensi**: Didistribusikan di bawah lisensi [MIT](LICENSE).
- **Disclaimer**: Aplikasi ini dikembangkan secara independen oleh komunitas dan masyarakat untuk kepentingan keterbukaan informasi publik perlindungan konsumen. Seluruh data izin edar BPOM, sertifikat halal BPJPH, dan merek terdaftar HKI bersumber langsung dari data publik pangkalan data resmi lembaga terkait (BPOM RI, BPJPH Kemenag RI, dan DJKI Kemenkumham RI).
