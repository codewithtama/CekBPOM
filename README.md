# CekBPOM — Product Authenticity Checker

**CekBPOM** is a high-performance, premium-designed Flutter Android application that verifies Indonesian product authenticity by querying the BPOM (Badan Pengawas Obat dan Makanan) database. 

With this application, users can scan product barcodes or input registration numbers manually to determine if a product (cosmetics, food, medicine, traditional herbs, or health supplements) is officially registered, expired, or potentially counterfeit.

---

## 🌟 Key Features

1. **Barcode Scanner**
   - Live camera scanning using the `mobile_scanner` library.
   - Supports EAN-13, EAN-8, QR Code, and Code128 formats.
   - Flashlight toggle support.
   - Fast manual entry fallback for codes that are scratched or unreadable.

2. **Real-time BPOM Product Lookup**
   - Automatically queries the primary BPOM public API.
   - Features a robust, dynamic scraping fallback to the official `cekbpom.pom.go.id/produk-dt/all` POST endpoint when the primary API is down.
   - Captures product registration data, status (active/expired), manufacturer details, packaging details, and active ingredients.

3. **Color-coded Safety Status Card**
   - **Green Badge (AMAN):** Registered and active product.
   - **Yellow/Orange Badge (PERLU DICEK / KEDALUWARSA):** Registered but expired, or requiring caution.
   - **Red Badge (TIDAK TERDAFTAR):** Missing from the BPOM database (potentially fake/unregistered).

4. **Persistent Scanning History**
   - Saves all scanned items offline using `hive` local database storage.
   - Dynamic search filter within history list.
   - Counter badge indicator in the bottom navigation tab.
   - Clear individual items or purge history completely.

5. **Information & Educational Portal**
   - "Cara Baca Kemasan": illustrated step-by-step guides on reading BPOM codes (NA/NB/NC cosmetics, MD/ML foods, TR/TI traditional medicines, etc.).
   - "Produk Berbahaya": Dynamic news scraper that fetches and parses the latest press releases, toxic cosmetics reports, recall logs, and official warnings directly from the BPOM Portal (pom.go.id/berita), with an offline fallback cache.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** Flutter (Dart) - Compiled for Android (minSdk 21, targetSdk 34, compileSdk 36)
- **State Management:** Riverpod (`flutter_riverpod` + `StateNotifier`)
- **HTTP client:** Dio
- **Local Database:** Hive + Hive Flutter
- **UI & Animation:** Material 3 Custom Theme, Google Fonts (Plus Jakarta Sans & Lexend), Shimmer, Lottie, and Screenshot sharing.
- **Project Structure:** Clean Architecture split by layers:
  ```
  lib/
  ├── main.dart
  ├── app.dart
  ├── core/
  │   ├── constants/       # API endpoints, colors, layout tokens
  │   ├── theme/           # App-wide Material 3 theme & Google Fonts
  │   └── utils/           # Barcode parser, connectivity helper
  ├── data/
  │   ├── models/          # Product and History domain models (Hive annotated)
  │   ├── repositories/    # BPOM repository coordinating API & cache
  │   └── services/        # Dio APIs and local Hive service
  └── presentation/
      ├── screens/         # Home, Scanner, Result, History, and Info screens
      ├── widgets/         # Status badges, product cards, list tiles, shimmer overlays
      └── providers/       # Riverpod state managers
  ```

---

## 🚀 How to Run the Project

### Prerequisites
- Flutter SDK (Channel stable, version 3.19.0+)
- Android SDK installed (Target 34, compile 36)

### 1. Resolve Dependencies
```bash
flutter pub get
```

### 2. Generate Hive Adapters
Run build runner to generate the database serialization files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run on Device / Emulator
Ensure your emulator (e.g. Pixel 10 API 30+) is booted, then run:
```bash
flutter run
```

### 4. Build Release APK
To package the app for installation:
```bash
flutter build apk --release
```

---

## 🔒 Disclaimer
This app is an independent product verification tool and has no official affiliation with the Food and Drug Authority of the Republic of Indonesia (Badan Pengawas Obat dan Makanan RI). All data displayed is queried in real-time from the public search portal.
