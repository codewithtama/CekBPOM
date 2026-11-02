import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/data/models/product_model.dart';
import 'package:cekbpom/data/services/halal_service.dart';

void main() {
  group('HalalService', () {
    test('identifies certified staple Indonesian brands', () {
      final product = ProductModel(
        productId: '101',
        registrationNumber: 'NA18210100001',
        name: 'Serum Brightening Wardah',
        brand: 'Wardah',
        package: '30ml',
        form: 'Serum',
        manufacturer: 'PT Paragon Technology and Innovation',
        status: 'Berlaku',
        expiredDate: '2028-10-10',
        registeredDate: '2024-01-01',
        category: 'Kosmetika',
        ingredients: 'Aqua, Niacinamide',
        isFound: true,
      );

      final result = HalalService.checkProductHalal(product);

      expect(result.isCertified, isTrue);
      expect(result.status, 'TERDAFTAR RESMI');
      expect(result.officialVerificationUrl.contains('bpjph.halal.go.id/cari/sertifikat'), isTrue);
    });

    test('generates valid official verification link for unverified products', () {
      final product = ProductModel(
        productId: '102',
        registrationNumber: 'NA18999999999',
        name: 'Custom Face Mist Rare Brand',
        brand: 'Rare Brand',
        package: '50ml',
        form: 'Liquid',
        manufacturer: 'PT Unregistered',
        status: 'Berlaku',
        expiredDate: '2027-10-10',
        registeredDate: '2024-01-01',
        category: 'Kosmetika',
        ingredients: 'Aqua',
        isFound: true,
      );

      final result = HalalService.checkProductHalal(product);

      expect(result.isCertified, isFalse);
      expect(result.status, 'VERIFIKASI BPJPH');
      expect(result.officialVerificationUrl, contains('Rare%20Brand'));
    });
  });
}

