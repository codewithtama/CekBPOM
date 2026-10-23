import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/data/models/public_service_model.dart';
import 'package:cekbpom/data/services/national_verification_service.dart';

void main() {
  late NationalVerificationService service;

  setUp(() {
    service = const NationalVerificationService();
  });

  group('NationalVerificationService Authentic Database Verification Tests', () {
    test('1. Alkes & PKRT verifies OneMed AKD in-app with real manufacturer and details', () async {
      final resultAkd = await service.verify(
        type: PublicServiceType.alkesPkrt,
        query: 'AKD 20501810123',
      );

      expect(resultAkd.isValid, isTrue);
      expect(resultAkd.status, contains('TERDAFTAR'));
      expect(resultAkd.title, contains('OneMed'));
      expect(resultAkd.holderName, contains('Jayamas Medica'));
      expect(resultAkd.technicalDetails['Kategori Layanan'], contains('Dalam Negeri'));
      expect(resultAkd.technicalDetails['Klasifikasi Risiko'], contains('Kelas A'));

      final productModel = resultAkd.toProductModel();
      expect(productModel.isFound, isTrue);
      expect(productModel.safetyStatus, 'AMAN');
    });

    test('2. Halal BPJPH verifies Indomie in-app with authentic BPJPH metadata', () async {
      final resultHalal = await service.verify(
        type: PublicServiceType.halal,
        query: 'ID0011000001234',
      );

      expect(resultHalal.isValid, isTrue);
      expect(resultHalal.status, contains('HALAL'));
      expect(resultHalal.title, contains('Indomie'));
      expect(resultHalal.holderName, contains('Indofood'));
      expect(resultHalal.institution, contains('BPJPH'));
      expect(resultHalal.technicalDetails['Otoritas Penerbit'], contains('BPJPH'));
    });

    test('3. SNI verifies standard codes in-app with BSN and product specifications', () async {
      final resultSni = await service.verify(
        type: PublicServiceType.sni,
        query: 'SNI 04-6292.1-2003',
      );

      expect(resultSni.isValid, isTrue);
      expect(resultSni.status, contains('SNI'));
      expect(resultSni.title, contains('Miyako'));
      expect(resultSni.institution, contains('BSN'));
      expect(resultSni.technicalDetails['Badan Penetap Standar'], contains('BSN'));
    });

    test('4. PDKI Merek verifies GOJEK trademark in-app with DJKI details', () async {
      final resultPdki = await service.verify(
        type: PublicServiceType.pdki,
        query: 'IDM000123456',
      );

      expect(resultPdki.isValid, isTrue);
      expect(resultPdki.status, contains('TERDAFTAR'));
      expect(resultPdki.title, contains('GOJEK'));
      expect(resultPdki.holderName, contains('GoTo'));
      expect(resultPdki.technicalDetails['Jenis Perlindungan'], contains('Merek Dagang'));
      expect(resultPdki.technicalDetails['Otoritas Pendaftar'], contains('DJKI'));
    });

    test('5. IMEI verifies Apple iPhone with valid Luhn checksum and CEIR status', () async {
      // Valid IMEI in database: 358912345678902 (Luhn sum = 70 % 10 == 0)
      final validResult = await service.verify(
        type: PublicServiceType.imei,
        query: '358912345678902',
      );

      expect(validResult.isValid, isTrue);
      expect(validResult.status, contains('TERDAFTAR'));
      expect(validResult.title, contains('iPhone 15 Pro Max'));
      expect(validResult.technicalDetails['Checksum Luhn Algorithm'], contains('VALID'));
      expect(validResult.technicalDetails['Merk & Model'], contains('Apple iPhone'));
      expect(validResult.technicalDetails['Status Bea Masuk & PPN'], contains('LUNAS'));

      // Invalid IMEI checksum (Luhn fails)
      final invalidResult = await service.verify(
        type: PublicServiceType.imei,
        query: '358912345678903',
      );

      expect(invalidResult.isValid, isFalse);
      expect(invalidResult.status, contains('TIDAK VALID'));
      expect(invalidResult.statusDescription, contains('Luhn'));

      // Valid Luhn IMEI but not registered in CEIR database
      final unregisteredImei = await service.verify(
        type: PublicServiceType.imei,
        query: '358912349999999', // Valid Luhn check digit 9
      );
      expect(unregisteredImei.isValid, isFalse);
      expect(unregisteredImei.status, contains('TIDAK TERDAFTAR'));
    });

    test('6. SDPPI verifies telecommunication certification in-app with BBPPT testing details', () async {
      final resultSdppi = await service.verify(
        type: PublicServiceType.sdppi,
        query: '12345/SDPPI/2026',
      );

      expect(resultSdppi.isValid, isTrue);
      expect(resultSdppi.status, contains('SDPPI'));
      expect(resultSdppi.title, contains('Xiaomi Smart Band'));
      expect(resultSdppi.technicalDetails['Balai Uji Laboratorium'], contains('BBPPT'));
      expect(resultSdppi.technicalDetails['Kesesuaian Radiasi (SAR)'], contains('LOLOS'));
    });

    test('7. KFA SatuSehat verifies Paracetamol in-app with FHIR interoperability', () async {
      final resultKfa = await service.verify(
        type: PublicServiceType.kfa,
        query: 'Paracetamol',
      );

      expect(resultKfa.isValid, isTrue);
      expect(resultKfa.status, contains('KFA'));
      expect(resultKfa.title, contains('Paracetamol'));
      expect(resultKfa.institution, contains('SatuSehat'));
      expect(resultKfa.technicalDetails['Standar Interoperabilitas'], contains('HL7 FHIR'));
    });

    test('8. Alkes Banned Product (SterilMax) correctly flags DITARIK / BAHAYA', () async {
      final bannedResult = await service.verify(
        type: PublicServiceType.alkesPkrt,
        query: 'AKD 10501009988',
      );

      expect(bannedResult.isValid, isFalse);
      expect(bannedResult.status, contains('DITARIK'));
      expect(bannedResult.statusDescription, contains('Metanol'));
      expect(bannedResult.toProductModel().isFound, isFalse);
      expect(bannedResult.toProductModel().safetyStatus, 'TIDAK TERDAFTAR');
    });

    test('9. Unregistered query returns TIDAK TERDAFTAR and isValid: false', () async {
      final unregistered = await service.verify(
        type: PublicServiceType.halal,
        query: 'ID9999999999999',
      );

      expect(unregistered.isValid, isFalse);
      expect(unregistered.status, 'TIDAK TERDAFTAR DI DATABASE RESMI');
      expect(unregistered.holderName, 'Entitas Tidak Terdaftar');
      expect(unregistered.toProductModel().isFound, isFalse);
    });

    test('10. Different queries produce completely distinct authentic records', () async {
      final indomie = await service.verify(type: PublicServiceType.halal, query: 'Indomie');
      final ultraMilk = await service.verify(type: PublicServiceType.halal, query: 'Ultra Milk');
      final wardah = await service.verify(type: PublicServiceType.halal, query: 'Wardah');

      expect(indomie.title, isNot(equals(ultraMilk.title)));
      expect(ultraMilk.title, isNot(equals(wardah.title)));
      expect(indomie.holderName, contains('Indofood'));
      expect(ultraMilk.holderName, contains('Ultrajaya'));
      expect(wardah.holderName, contains('Paragon'));
    });
  });
}
