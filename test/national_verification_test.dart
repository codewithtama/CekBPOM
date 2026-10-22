import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/data/models/public_service_model.dart';
import 'package:cekbpom/data/services/national_verification_service.dart';

void main() {
  late NationalVerificationService service;

  setUp(() {
    service = NationalVerificationService();
  });

  group('NationalVerificationService In-App Verification Tests', () {
    test('1. Alkes & PKRT verifies AKD and AKL in-app', () async {
      final resultAkd = await service.verify(
        type: PublicServiceType.alkesPkrt,
        query: 'AKD 20501810123',
      );

      expect(resultAkd.isValid, isTrue);
      expect(resultAkd.status, contains('TERDAFTAR'));
      expect(resultAkd.technicalDetails['Kategori Layanan'], contains('Dalam Negeri'));
      expect(resultAkd.technicalDetails['Klasifikasi Risiko'], contains('Kelas B'));

      final productModel = resultAkd.toProductModel();
      expect(productModel.isFound, isTrue);
      expect(productModel.safetyStatus, 'AMAN');
    });

    test('2. Halal BPJPH verifies ID and product queries in-app', () async {
      final resultHalal = await service.verify(
        type: PublicServiceType.halal,
        query: 'ID0011000001234',
      );

      expect(resultHalal.isValid, isTrue);
      expect(resultHalal.status, contains('HALAL'));
      expect(resultHalal.institution, contains('BPJPH'));
      expect(resultHalal.technicalDetails['Otoritas Penerbit'], contains('BPJPH'));
    });

    test('3. SNI verifies standard codes in-app', () async {
      final resultSni = await service.verify(
        type: PublicServiceType.sni,
        query: 'SNI 04-6292.1-2003',
      );

      expect(resultSni.isValid, isTrue);
      expect(resultSni.status, contains('SNI'));
      expect(resultSni.institution, contains('BSN'));
      expect(resultSni.technicalDetails['Badan Penetap Standar'], contains('BSN'));
    });

    test('4. PDKI Merek verifies trademark in-app', () async {
      final resultPdki = await service.verify(
        type: PublicServiceType.pdki,
        query: 'IDM000123456',
      );

      expect(resultPdki.isValid, isTrue);
      expect(resultPdki.status, contains('TERDAFTAR'));
      expect(resultPdki.technicalDetails['Jenis Perlindungan'], contains('Merek Dagang'));
      expect(resultPdki.technicalDetails['Otoritas Pendaftar'], contains('DJKI'));
    });

    test('5. IMEI verifies valid Luhn checksum and rejects invalid Luhn in-app', () async {
      // Valid IMEI: 358912345678902 (Luhn sum = 70 % 10 == 0)
      final validResult = await service.verify(
        type: PublicServiceType.imei,
        query: '358912345678902',
      );

      expect(validResult.isValid, isTrue);
      expect(validResult.status, 'TERDAFTAR & SAH');
      expect(validResult.technicalDetails['Checksum Luhn Algorithm'], contains('VALID'));
      expect(validResult.technicalDetails['Merk & Model Terdeteksi'], contains('Apple iPhone'));
      expect(validResult.technicalDetails['Status Database CEIR'], contains('TERDAFTAR'));

      // Invalid IMEI: 358912345678903 (Wrong check digit)
      final invalidResult = await service.verify(
        type: PublicServiceType.imei,
        query: '358912345678903',
      );

      expect(invalidResult.isValid, isFalse);
      expect(invalidResult.status, contains('TIDAK VALID'));
      expect(invalidResult.statusDescription, contains('Luhn'));
    });

    test('6. SDPPI verifies telecommunication certification in-app', () async {
      final resultSdppi = await service.verify(
        type: PublicServiceType.sdppi,
        query: '12345/SDPPI/2026',
      );

      expect(resultSdppi.isValid, isTrue);
      expect(resultSdppi.status, contains('SDPPI'));
      expect(resultSdppi.technicalDetails['Balai Uji Laboratorium'], contains('BBPPT'));
      expect(resultSdppi.technicalDetails['Kesesuaian Radiasi (SAR)'], contains('LOLOS'));
    });

    test('7. KFA SatuSehat verifies drug master catalog in-app', () async {
      final resultKfa = await service.verify(
        type: PublicServiceType.kfa,
        query: 'Paracetamol',
      );

      expect(resultKfa.isValid, isTrue);
      expect(resultKfa.status, contains('KFA'));
      expect(resultKfa.institution, contains('SatuSehat'));
      expect(resultKfa.technicalDetails['Standar Interoperabilitas'], contains('HL7 FHIR'));
    });
  });
}
