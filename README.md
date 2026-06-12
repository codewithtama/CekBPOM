# CekBPOM — Aplikasi Cek Keaslian & Keamanan Produk BPOM

Aplikasi Android berbasis Flutter untuk cek keaslian produk kosmetik, obat, jamu, suplemen, dan makanan olahan langsung dari database resmi BPOM RI. Tinggal scan barcode produk atau input nomor registrasinya secara manual, status keamanannya langsung kelihatan.

Aplikasi ini dibuat siap dideploy ke produksi tanpa menggunakan data mock (no mock data) dan langsung melakukan scraping dari web portal resmi BPOM jika API publik mereka sedang lambat atau down.

---

## Fitur Utama

- **Pindai Barcode (Kamera & Galeri)**
  - Kamera pemindai cepat untuk barcode biasa (EAN-13, EAN-8) atau QR Code menggunakan library `mobile_scanner`.
  - Tombol **Zoom Multiplier (1.0x, 2.0x, 3.0x)** untuk memudahkan pemindaian jika barcode terlalu kecil atau posisinya jauh dari kamera.
  - Fitur scan barcode dari **Galeri Foto** HP (menggunakan `image_picker`), sangat berguna jika Anda punya foto screenshot kemasan produk.
  - Tombol flash kamera (torch) untuk memindai di tempat gelap.

- **Pengecekan Database BPOM Real-time**
  - Aplikasi secara otomatis mencoba menghubungi API publik BPOM.
  - Jika API publik mati/RTO (sering terjadi), sistem otomatis menggunakan **fallback web scraper** ke `cekbpom.pom.go.id` dengan mengambil CSRF token dan session cookie secara dinamis via POST request.
  - Data yang ditampilkan sangat detail: Nama produk, merk, kategori, pendaftar/produsen, kemasan, tanggal registrasi, tanggal kedaluwarsa, hingga bahan kandungan (komposisi).

- **Sistem Indikator Status Warna**
  - **Hijau (AMAN):** Produk terdaftar secara resmi dan statusnya aktif.
  - **Kuning (KEDALUWARSA / CEK ULANG):** Produk terdaftar tetapi masa berlakunya sudah habis, atau membutuhkan perhatian khusus.
  - **Merah (TIDAK TERDAFTAR):** Data produk tidak ditemukan di database BPOM (indikasi produk palsu atau ilegal).

- **Menu Pengaturan (Settings)**
  - Switch untuk mengaktifkan/mematikan getar (vibe feedback) saat scan berhasil.
  - Switch untuk mengaktifkan/mematikan efek suara klik (beep click) saat barcode terdeteksi.
  - Tombol **Bersihkan Cache & Riwayat** untuk menghapus semua data pencarian offline dari perangkat.
  - Shortcut link resmi untuk pengaduan konsumen (ULPK BPOM), disclaimer hukum, syarat ketentuan, dan tentang aplikasi.

- **Riwayat & Cache Offline**
  - Menyimpan otomatis semua hasil pengecekan secara lokal menggunakan database **Hive**.
  - Jika Anda sedang offline (tidak ada sinyal internet), produk yang sudah pernah di-scan sebelumnya tetap bisa dibuka datanya dari cache lokal.

- **Edukasi & Portal Berita BPOM**
  - Panduan lengkap cara membaca kode registrasi BPOM (NA/MD/ML/TR/TI/DKL).
  - Berita terupdate yang di-scrape langsung dari web portal berita `pom.go.id/berita` (informasi recall produk merkuri, sirup EG, press release, dll).

---

## Cara Menjalankan Projek

### Prasyarat
- Flutter SDK (versi stable terbaru)
- Android SDK (minSdk 21, compileSdk 36)

### 1. Ambil Dependensi
```bash
flutter pub get
```

### 2. Generate Hive Adapters
Jalankan build runner untuk membuat file serializer database lokal (g.dart):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run ke Device / Emulator
Pastikan handphone atau emulator sudah tercolok dan terbaca, lalu jalankan:
```bash
flutter run
```

### 4. Build APK Release
Untuk membuat paket installer APK versi rilis yang siap dipublikasikan:
```bash
flutter build apk --release
```

---

## Catatan Teknis / Troubleshooting
- **SSL Bypass**: Portal resmi BPOM seringkali memicu error sertifikat SSL (`unable to get local issuer certificate`) di perangkat native. Kami telah mengonfigurasi `badCertificateCallback` pada Dio HTTP adapter agar request tetap berjalan mulus.
- **Android 11 Package Queries**: Kami menambahkan deklarasi tag `<queries>` untuk skema `http` dan `https` di dalam `AndroidManifest.xml` agar plugin `url_launcher` tidak error/blank saat membuka tautan eksternal di Android versi baru.
