# CekBPOM — Agent Prompt

You are an expert Flutter/Android developer. Build a complete Android application called **"CekBPOM"** — a product authenticity checker that verifies Indonesian products against the BPOM (Badan Pengawas Obat dan Makanan) database.

---

## PROJECT OVERVIEW

| Field | Value |
|---|---|
| App Name | CekBPOM |
| Package | com.cekbpom.app |
| Platform | Android (Flutter) |
| Min SDK | 21 (Android 5.0) |
| Target SDK | 34 |

---

## CORE FEATURES

### 1. Barcode Scanner
- Use `mobile_scanner` package for camera-based barcode scanning
- Support formats: EAN-13, EAN-8, QR Code, Code128
- Flashlight toggle during scan
- Manual input fallback (ketik nomor registrasi BPOM manual)

### 2. BPOM Product Lookup
- Hit BPOM public API: `https://api-cekbpom.pom.go.id/api/produk/nomor_notif/{nomor}`
- Also support: `https://cekbpom.pom.go.id/` web scraping fallback if API unavailable
- Parse and display:
  - Nama Produk
  - Nama Pendaftar / Produsen
  - Nomor Registrasi
  - Jenis Produk (Obat, Kosmetik, Pangan Olahan, dll)
  - Status Registrasi (AKTIF / TIDAK AKTIF / TIDAK DITEMUKAN)
  - Tanggal Registrasi & Expired

### 3. Result Screen
- GREEN card = produk terdaftar & aktif
- YELLOW card = terdaftar tapi expired/tidak aktif
- RED card = tidak ditemukan di database BPOM (potensial palsu)
- Tampilkan detail lengkap produk
- Tombol "Laporkan Produk" (buka link pengaduan BPOM)
- Tombol "Bagikan Hasil" (share screenshot hasil cek)

### 4. Riwayat Scan
- Simpan history scan lokal pakai `hive` atau `shared_preferences`
- Tampilkan: nama produk, status, tanggal scan, thumbnail barcode
- Bisa delete per item atau clear all
- Badge counter di bottom nav

### 5. Informasi & Edukasi
- Tab "Cara Baca Kemasan" — panduan singkat cara cek nomor BPOM di kemasan
- Tab "Produk Berbahaya Terkini" — feed dari RSS/web BPOM (pom.go.id/berita)
- Static fallback content jika offline

---

## TECH STACK

| Layer | Package |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod |
| HTTP | dio |
| Scanner | mobile_scanner |
| Local Storage | hive + hive_flutter |
| UI | Material 3 custom theme |
| Share | share_plus |
| Screenshot | screenshot |
| Connectivity | connectivity_plus |

---

## FILE STRUCTURE

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_colors.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── barcode_parser.dart
│       └── connectivity_helper.dart
├── data/
│   ├── models/
│   │   ├── product_model.dart
│   │   └── scan_history_model.dart
│   ├── repositories/
│   │   └── bpom_repository.dart
│   └── services/
│       ├── bpom_api_service.dart
│       └── history_service.dart
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── scanner_screen.dart
│   │   ├── result_screen.dart
│   │   ├── history_screen.dart
│   │   └── info_screen.dart
│   ├── widgets/
│   │   ├── product_card.dart
│   │   ├── status_badge.dart
│   │   ├── scan_history_tile.dart
│   │   └── loading_overlay.dart
│   └── providers/
│       ├── scan_provider.dart
│       └── history_provider.dart
```

---

## UI/UX DESIGN

### Color Palette

| Token | Hex | Penggunaan |
|---|---|---|
| Primary | `#0066CC` | Biru kepercayaan, mirip warna resmi BPOM |
| Success | `#2E7D32` | Hijau untuk produk aman |
| Warning | `#F57F17` | Kuning untuk produk expired |
| Danger | `#C62828` | Merah untuk produk tidak terdaftar |
| Background | `#F5F7FA` | Background utama |
| Surface | `#FFFFFF` | Card dan panel |

### Navigation
- Bottom Navigation Bar dengan 4 tab: **Scan, Riwayat, Info, Tentang**
- Home screen berisi tombol besar "Mulai Scan" + shortcut input manual

### Scan Screen
- Full screen camera preview
- Animated scanning line (atas ke bawah)
- Overlay kotak target scan di tengah
- Tombol flash di pojok kanan atas
- Tombol "Input Manual" di bagian bawah

### Result Screen
- Animated card muncul dari bawah (slide-up)
- Status badge besar di bagian atas (AMAN / PERLU DICEK / TIDAK TERDAFTAR)
- Detail produk dalam list tile
- CTA buttons di bagian bawah

---

## ERROR HANDLING

| Kondisi | Handling |
|---|---|
| Timeout API | 10 detik, tampilkan pesan "Koneksi lambat, coba lagi" |
| Produk tidak ditemukan | Bedakan antara "tidak ada di database" vs "error koneksi" |
| Barcode tidak terbaca | Minta user input manual |
| Offline mode | Tampilkan hasil dari cache history jika nomor pernah dicek sebelumnya |

---

## PERMISSIONS (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

---

## pubspec.yaml DEPENDENCIES

```yaml
dependencies:
  flutter:
    sdk: flutter
  mobile_scanner: ^3.5.6
  dio: ^5.4.0
  riverpod: ^2.4.10
  flutter_riverpod: ^2.4.10
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  share_plus: ^7.2.1
  screenshot: ^2.1.0
  connectivity_plus: ^5.0.2
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^3.0.0
  intl: ^0.19.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

---

## BUILD INSTRUCTIONS

Bangun file per file sesuai urutan berikut. Jangan gabung semua dalam satu file. Setiap screen dan widget harus file terpisah.

1. Scaffold semua file sesuai struktur di atas
2. Mulai dari `bpom_api_service.dart` — implementasi hit API BPOM dan parsing response
3. Lanjut ke `product_model.dart` dan `scan_history_model.dart` dengan Hive adapter
4. Implementasi `scanner_screen.dart` dengan `mobile_scanner`
5. Implementasi `result_screen.dart` dengan animasi slide-up
6. Implementasi `history_screen.dart` dengan Hive box
7. Terakhir wiring semua di `app.dart` dan `main.dart`
8. Pastikan semua screen bisa diakses tanpa crash di Android emulator API 30+
