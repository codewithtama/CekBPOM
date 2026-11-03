import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/data/models/trademark_model.dart';

void main() {
  group('TrademarkModel', () {
    test('parses complete JSON from haki.id API correctly', () {
      final sampleJson = <String, dynamic>{
        '_id': '68df68e4423e9de96bd8fe02',
        'TableData': {
          'mark': 'Gudang Garam',
          'applicant': 'PT.GUDANG GARAM Tbk.',
          'filling_number_text': 'DID2022093965',
          'registration_number': 'IDM001204008',
          'filling_date': '2022-11-21',
          'registration_date': '2024-08-14',
          'publication_date': '2022-11-29',
          'receiving_date': '2022-11-21',
          'expiration_date': '2032-11-21',
          'nice_classes': '34',
          'status': '(TM) Didaftar',
          'logo_url': '/api/trademark-image/cekmerek/68df68e4423e9de96bd8fe02',
          'link':
              'https://pdki-indonesia.dgip.go.id/link/495054323032323139373734377c74726164656d61726b',
          'applicant_address': 'SEMAMPIR II/1, Kediri',
          'goods_services': 'Rokok, tembakau, cerutu',
        },
      };

      final model = TrademarkModel.fromJson(sampleJson);

      expect(model.id, '68df68e4423e9de96bd8fe02');
      expect(model.mark, 'Gudang Garam');
      expect(model.applicant, 'PT.GUDANG GARAM Tbk.');
      expect(model.registrationNumber, 'IDM001204008');
      expect(model.fillingNumber, 'DID2022093965');
      expect(model.fillingDate, '2022-11-21');
      expect(model.registrationDate, '2024-08-14');
      expect(model.expirationDate, '2032-11-21');
      expect(model.niceClasses, '34');
      expect(model.status, '(TM) Didaftar');
      expect(model.isRegistered, isTrue);
      expect(
        model.logoUrl,
        'https://haki.id/api/trademark-image/cekmerek/68df68e4423e9de96bd8fe02',
      );
      expect(
        model.pdkiLink,
        'https://pdki-indonesia.dgip.go.id/link/495054323032323139373734377c74726164656d61726b',
      );
      expect(model.applicantAddress, 'SEMAMPIR II/1, Kediri');
      expect(model.goodsServices, 'Rokok, tembakau, cerutu');
      expect(
        model.classDescription,
        'Kelas 34 (Tembakau, Rokok & Perlengkapan Perokok)',
      );
    });

    test('handles fallback when fields are missing or empty', () {
      final minimalJson = <String, dynamic>{
        '_id': 'dummy-id',
        'TableData': <String, dynamic>{},
      };

      final model = TrademarkModel.fromJson(minimalJson);

      expect(model.id, 'dummy-id');
      expect(model.mark, 'Merek Tanpa Nama');
      expect(model.applicant, 'Pemilik Tidak Diketahui');
      expect(model.registrationNumber, '-');
      expect(model.isRegistered, isFalse);
      expect(model.logoUrl, isNull);
      expect(model.pdkiLink, isNull);
      expect(model.classDescription, '-');
    });

    test('classDescription formats known Nice classes properly', () {
      TrademarkModel createWithClass(String niceClass) {
        return TrademarkModel(
          id: 'test',
          mark: 'Test',
          applicant: 'Owner',
          registrationNumber: 'REG123',
          fillingNumber: 'FILL123',
          fillingDate: '2024-01-01',
          registrationDate: '2024-01-01',
          expirationDate: '2034-01-01',
          niceClasses: niceClass,
          status: '(TM) Didaftar',
          logoUrl: null,
          pdkiLink: null,
          applicantAddress: 'Address',
          goodsServices: 'Services',
        );
      }

      expect(createWithClass('3').classDescription, contains('Kosmetik'));
      expect(createWithClass('5').classDescription, contains('Farmasi'));
      expect(createWithClass('29').classDescription, contains('Olahan Daging'));
      expect(createWithClass('30').classDescription, contains('Kopi, Teh'));
      expect(createWithClass('32').classDescription, contains('Minuman'));
      expect(createWithClass('35').classDescription, contains('Periklanan'));
      expect(createWithClass('99').classDescription, 'Kelas 99');
    });

    test('TrademarkSearchResult reports isEmpty correctly', () {
      const emptyResult = TrademarkSearchResult(
        success: true,
        total: 0,
        totalPages: 0,
        page: 1,
        items: [],
      );
      expect(emptyResult.isEmpty, isTrue);

      final populatedResult = TrademarkSearchResult(
        success: true,
        total: 1,
        totalPages: 1,
        page: 1,
        items: [
          TrademarkModel.fromJson({
            '_id': '1',
            'TableData': {'mark': 'Test'},
          }),
        ],
      );
      expect(populatedResult.isEmpty, isFalse);
      expect(populatedResult.total, 1);
    });
  });
}
