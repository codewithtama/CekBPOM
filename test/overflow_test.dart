import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/data/models/product_model.dart';
import 'package:cekbpom/data/models/public_service_model.dart';
import 'package:cekbpom/data/models/public_verification_result.dart';
import 'package:cekbpom/data/models/scan_history_model.dart';
import 'package:cekbpom/presentation/providers/history_provider.dart';
import 'package:cekbpom/presentation/providers/settings_provider.dart';
import 'package:cekbpom/presentation/screens/home_screen.dart';
import 'package:cekbpom/presentation/screens/public_verification_screen.dart';
import 'package:cekbpom/presentation/screens/about_screen.dart';
import 'package:cekbpom/presentation/widgets/product_card.dart';
import 'package:cekbpom/presentation/widgets/public_verification_result_card.dart';

class _MockHistoryNotifier extends StateNotifier<List<ScanHistoryModel>>
    implements HistoryNotifier {
  _MockHistoryNotifier() : super([]);

  @override
  void loadHistory() {}

  @override
  Future<void> addHistory(dynamic product) async {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> deleteItem(dynamic key) async {}
}

class _MockSettingsNotifier extends StateNotifier<AppSettings>
    implements SettingsNotifier {
  _MockSettingsNotifier()
      : super(AppSettings(enableVibration: true, enableSound: true));

  @override
  Future<void> toggleSound(bool value) async {}

  @override
  Future<void> toggleVibration(bool value) async {}
}

void main() {
  final testDevices = [
    const Size(320, 600), // Very narrow screen (small Android/iPhone SE 1st gen)
    const Size(360, 800), // Standard Android screen
    const Size(412, 915), // Large Android flagship
  ];

  final textScales = [
    1.0,
    1.4,
    1.8,
  ];

  group('ZERO OVERFLOW POLICY Verification Suite', () {
    for (final size in testDevices) {
      for (final scale in textScales) {
        testWidgets(
          'HomeScreen has ZERO overflow at ${size.width}x${size.height} with scale ${scale}x',
          (tester) async {
            tester.view.physicalSize = Size(size.width * 2, size.height * 2);
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  historyProvider.overrideWith((ref) => _MockHistoryNotifier()),
                  settingsProvider
                      .overrideWith((ref) => _MockSettingsNotifier()),
                ],
                child: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: const MaterialApp(
                    home: Scaffold(body: HomeScreen()),
                  ),
                ),
              ),
            );

            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets(
          'PublicVerificationScreen has ZERO overflow at ${size.width}px with scale ${scale}x',
          (tester) async {
            tester.view.physicalSize = Size(size.width * 2, size.height * 2);
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  historyProvider.overrideWith((ref) => _MockHistoryNotifier()),
                ],
                child: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: const MaterialApp(
                    home: PublicVerificationScreen(
                      initialService: PublicServiceType.imei,
                    ),
                  ),
                ),
              ),
            );

            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets(
          'AboutScreen has ZERO overflow at ${size.width}px with scale ${scale}x',
          (tester) async {
            tester.view.physicalSize = Size(size.width * 2, size.height * 2);
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(
                  size: size,
                  textScaler: TextScaler.linear(scale),
                ),
                child: const MaterialApp(
                  home: AboutScreen(),
                ),
              ),
            );

            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets(
          'PublicVerificationResultCard has ZERO overflow at ${size.width}px with scale ${scale}x',
          (tester) async {
            tester.view.physicalSize = Size(size.width * 2, size.height * 2);
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            final testResult = PublicVerificationResult(
              serviceType: PublicServiceType.imei,
              queryCode: '358912345678902',
              title: 'Apple iPhone 15 Pro Max (256GB Titanium)',
              registrationNumber: '35-891234-567890-2',
              institution:
                  'Direktorat Jenderal Bea dan Cukai & Kementerian Perindustrian Republik Indonesia',
              holderName: 'Apple Inc. Authorized Reseller Indonesia',
              validityPeriod: 'Seumur Hidup / Permanen',
              category: 'Telekomunikasi Bergerak Seluler',
              status: 'TERDAFTAR & SAH',
              statusColor: Colors.green,
              statusDescription:
                  'Nomor IMEI telah lolos uji checksum Luhn dan terdaftar secara sah di sistem CEIR nasional.',
              technicalDetails: const {
                'Nomor IMEI': '35-891234-567890-2',
                'Type Allocation Code (TAC)': '35891234',
                'Merk & Model Terdeteksi': 'Apple iPhone 15 Pro Max',
                'Checksum Luhn Algorithm': 'VALID (Standar 3GPP/GSMA)',
                'Status Database CEIR': 'TERDAFTAR (Sinyal Seluler Bebas Blokir)',
                'Pajak & Bea Masuk': 'TERVERIFIKASI LUNAS KEPABEANAN',
                'Dasar Aturan Hukum': 'Permenkominfo No. 5/2020',
              },
              verifiedAt: DateTime.now(),
              sourceLabel: 'Database CEIR Bea Cukai & Kemenperin RI',
              isValid: true,
              officialPortalUrl: 'https://www.beacukai.go.id/cek-imei.html',
            );

            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  historyProvider.overrideWith((ref) => _MockHistoryNotifier()),
                ],
                child: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: MaterialApp(
                    home: Scaffold(
                      body: SingleChildScrollView(
                        child: PublicVerificationResultCard(result: testResult),
                      ),
                    ),
                  ),
                ),
              ),
            );

            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets(
          'ProductCard has ZERO overflow with extreme length content at ${size.width}px scale ${scale}x',
          (tester) async {
            tester.view.physicalSize = Size(size.width * 2, size.height * 2);
            tester.view.devicePixelRatio = 2.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            final longProduct = ProductModel(
              productId: '999999',
              registrationNumber: 'POM NA18260102268',
              name:
                  'SERUM PENCERAH WAJAH INTENSIF EKSTRAK ALAMI HERBAL MULTIVITAMIN KOMPLEKS BPOM',
              brand: 'ULTRA PREMIUM GLOW BEAUTY DERMATOLOGY',
              package: 'Botol Kaca Dropper Pipet 50 ml dalam Kemasan Dus Karton',
              form: 'Cairan Kental Transparan Bening',
              manufacturer:
                  'PT COSMECEUTICAL INDONESIA MAKMUR SENTOSA JAYA ABADI',
              status: 'Berlaku',
              expiredDate: '2028-12-31',
              registeredDate: '2026-01-15',
              category: 'KOSMETIKA PERAWATAN KULIT WAJAH EKSTERNAL',
              ingredients:
                  'Aqua, Niacinamide, Glycerin, Butylene Glycol, Alpha Arbutin, Sodium Hyaluronate, Phenoxyethanol, Ethylhexylglycerin.',
              isFound: true,
            );

            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  historyProvider.overrideWith((ref) => _MockHistoryNotifier()),
                ],
                child: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: MaterialApp(
                    home: Scaffold(
                      body: SingleChildScrollView(
                        child: ProductCard(
                          product: longProduct,
                          sourceLabel:
                              'Basis Data Resmi Web BPOM Republik Indonesia',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );

            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });
}
