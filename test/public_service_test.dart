import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/data/models/public_service_model.dart';

void main() {
  group('PublicServiceInfo Tests', () {
    test('All 7 government services are properly configured', () {
      expect(PublicServiceInfo.allServices.length, 7);

      final types = PublicServiceInfo.allServices.map((s) => s.type).toSet();
      expect(types.length, 7);
      expect(types, contains(PublicServiceType.alkesPkrt));
      expect(types, contains(PublicServiceType.halal));
      expect(types, contains(PublicServiceType.sni));
      expect(types, contains(PublicServiceType.pdki));
      expect(types, contains(PublicServiceType.imei));
      expect(types, contains(PublicServiceType.sdppi));
      expect(types, contains(PublicServiceType.kfa));
    });

    test('IMEI validator correctly accepts valid 15-digit Luhn checksum', () {
      final imeiService = PublicServiceInfo.getByType(PublicServiceType.imei);

      // Valid Luhn IMEI
      expect(imeiService.validate('358912345678902'), isNull);

      // Invalid length
      expect(imeiService.validate('12345'), contains('15 digit'));

      // Empty string
      expect(imeiService.validate(''), contains('tidak boleh kosong'));

      // Invalid Luhn checksum (wrong last digit)
      expect(imeiService.validate('358912345678909'), contains('Luhn'));
    });

    test('Alkes & PKRT validator rejects empty or very short strings', () {
      final service = PublicServiceInfo.getByType(PublicServiceType.alkesPkrt);

      expect(service.validate('AKD 20501810123'), isNull);
      expect(service.validate(''), contains('tidak boleh kosong'));
      expect(service.validate('AK'), contains('terlalu pendek'));
    });

    test('Halal validator works with product name or certificate ID', () {
      final service = PublicServiceInfo.getByType(PublicServiceType.halal);

      expect(service.validate('ID0011000001234'), isNull);
      expect(service.validate('Susu Cokelat'), isNull);
      expect(service.validate('AB'), contains('minimal 3 karakter'));
    });

    test('Build verification URLs generates valid official government targets', () {
      final halal = PublicServiceInfo.getByType(PublicServiceType.halal);
      final halalUrl = halal.buildVerificationUrl('Indomie');
      expect(halalUrl, contains('bpjph.halal.go.id'));
      expect(halalUrl, contains('Indomie'));

      final pdki = PublicServiceInfo.getByType(PublicServiceType.pdki);
      final pdkiUrl = pdki.buildVerificationUrl('CekBPOM');
      expect(pdkiUrl, contains('pdki-indonesia.dgip.go.id'));
      expect(pdkiUrl, contains('CekBPOM'));

      final imei = PublicServiceInfo.getByType(PublicServiceType.imei);
      expect(imei.buildVerificationUrl('358912345678901'), contains('beacukai.go.id'));

      final alkes = PublicServiceInfo.getByType(PublicServiceType.alkesPkrt);
      expect(alkes.buildVerificationUrl('AKD 1234'), contains('regalkes.kemkes.go.id'));

      final sni = PublicServiceInfo.getByType(PublicServiceType.sni);
      expect(sni.buildVerificationUrl('SNI 1234'), contains('bangbeni.bsn.go.id'));

      final sdppi = PublicServiceInfo.getByType(PublicServiceType.sdppi);
      expect(sdppi.buildVerificationUrl('1234/SDPPI/2026'), contains('sertifikasi.postel.go.id'));

      final kfa = PublicServiceInfo.getByType(PublicServiceType.kfa);
      expect(kfa.buildVerificationUrl('Paracetamol'), contains('satusehat.kemkes.go.id'));
    });
  });
}
