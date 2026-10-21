import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/core/utils/barcode_parser.dart';

void main() {
  group('BarcodeParser', () {
    test('cleanCode extracts GS1 AI (90) formatted registration numbers', () {
      expect(
        BarcodeParser.cleanCode('(90)NA18210100001(91)LOT998'),
        'NA18210100001',
      );
    });

    test('cleanCode handles raw GS1 element string separated by FNC1 (0x1D)', () {
      expect(
        BarcodeParser.cleanCode('90NA18210100001\x1D91BATCH123'),
        'NA18210100001',
      );
    });

    test('cleanCode strips AIM symbology prefix', () {
      expect(
        BarcodeParser.cleanCode(']Q3(90)MD042867000101354'),
        'MD042867000101354',
      );
    });

    test('cleanCode strips whitespace from manual input', () {
      expect(
        BarcodeParser.cleanCode('  MD 042867000101354  '),
        'MD042867000101354',
      );
    });

    test('isValidBpomFormat validates standard BPOM patterns', () {
      expect(BarcodeParser.isValidBpomFormat('NA18210100001'), isTrue);
      expect(BarcodeParser.isValidBpomFormat('MD042867000101354'), isTrue);
      expect(BarcodeParser.isValidBpomFormat('TR123456789'), isTrue);
      expect(BarcodeParser.isValidBpomFormat('POMTR122663051'), isTrue);
      expect(BarcodeParser.isValidBpomFormat('DKL2542601949B1'), isTrue);
      expect(BarcodeParser.isValidBpomFormat('8992761136014'), isFalse);
      expect(BarcodeParser.isValidBpomFormat(''), isFalse);
    });

    test('isRetailBarcode identifies 1D EAN/UPC barcodes', () {
      expect(BarcodeParser.isRetailBarcode('8992761136014'), isTrue);
      expect(BarcodeParser.isRetailBarcode('NA18210100001'), isFalse);
    });

    test('isSameRegistration compares numbers ignoring spaces and POM prefix', () {
      expect(
        BarcodeParser.isSameRegistration('POM TR 122663051', 'TR122663051'),
        isTrue,
      );
      expect(
        BarcodeParser.isSameRegistration('NA 18210100001', 'NA18210100001'),
        isTrue,
      );
      expect(
        BarcodeParser.isSameRegistration('NA18210100001', 'NA18210100002'),
        isFalse,
      );
    });
  });
}
