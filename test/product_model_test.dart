import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/data/models/product_model.dart';

void main() {
  group('ProductModel', () {
    test('fromJson correctly parses BPOM DataTables response item', () {
      final json = {
        'PRODUCT_ID': '12345',
        'PRODUCT_REGISTER': 'NA18210100001',
        'PRODUCT_NAME': 'SERUM BRIGHTENING',
        'PRODUCT_BRANDS': 'GLOW BEAUTY',
        'PRODUCT_PACKAGE': 'Botol 30 ml',
        'PRODUCT_FORM': 'Cairan kental',
        'MANUFACTURER_NAME': 'PT KOSMETIKA INDONESIA',
        'STATUS': 'Berlaku',
        'PRODUCT_EXPIRED': '2029-12-31',
        'PRODUCT_DATE': '2024-01-15',
        'CATEGORY': 'Kosmetika',
        'INGREDIENTS': 'Aqua, Niacinamide, Glycerin',
      };

      final product = ProductModel.fromJson(json);

      expect(product.productId, '12345');
      expect(product.registrationNumber, 'NA18210100001');
      expect(product.name, 'SERUM BRIGHTENING');
      expect(product.brand, 'GLOW BEAUTY');
      expect(product.isFound, isTrue);
      expect(product.safetyStatus, 'AMAN');
    });

    test('notFound factory creates unverified state', () {
      final product = ProductModel.notFound('INVALID123');

      expect(product.registrationNumber, 'INVALID123');
      expect(product.name, 'Produk Tidak Terdaftar');
      expect(product.isFound, isFalse);
      expect(product.safetyStatus, 'TIDAK TERDAFTAR');
    });

    test('safetyStatus detects expired product', () {
      final product = ProductModel(
        productId: '1',
        registrationNumber: 'TR123',
        name: 'Jamu Sehat',
        brand: 'Sehat',
        package: 'Sachet',
        form: 'Serbuk',
        manufacturer: 'PT Jamu',
        status: 'Berlaku',
        expiredDate: '2020-01-01',
        registeredDate: '2015-01-01',
        category: 'Obat Tradisional',
        ingredients: '',
        isFound: true,
      );

      expect(product.safetyStatus, 'KEDALUWARSA');
    });
  });
}
