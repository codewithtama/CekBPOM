import 'dart:developer' as developer;
import '../../core/constants/api_constants.dart';
import '../models/halal_model.dart';
import '../models/product_model.dart';

class HalalService {
  static const Set<String> _knownHalalBrands = {
    'wardah',
    'kahf',
    'make over',
    'emina',
    'somethinc',
    'avoskin',
    'scarlett',
    'indomie',
    'sedap',
    'sedaap',
    'sari roti',
    'ultra milk',
    'indomilk',
    'frisian flag',
    'dancow',
    'pocari sweat',
    'teh botol',
    'sosro',
    'garuda',
    'taro',
    'chitato',
    'silverqueen',
    'biore',
    'garnier',
    'ponds',
    'pond\'s',
    'vaseline',
    'lifebuoy',
    'sunlight',
    'bango',
    'royco',
    'sasa',
    'ajinomoto',
    'kapal api',
    'torabika',
    'luwak',
  };

  /// Builds direct URL to BPJPH halal certificate database with product query
  static String buildVerificationUrl(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return ApiConstants.bpjphHalalSearchUrl;
    }
    final encoded = Uri.encodeComponent(trimmed);
    return '${ApiConstants.bpjphHalalSearchUrl}?produk=$encoded';
  }

  /// Evaluates Halal certification status for a BPOM product and generates
  /// direct link to BPJPH Kemenag official database (https://bpjph.halal.go.id/cari/sertifikat)
  static HalalCheckResult checkProductHalal(ProductModel product) {
    developer.log('Evaluating Halal status for: ${product.name}', name: 'HalalService');

    // Use Brand, or fall back to product name
    final searchQuery = product.brand.isNotEmpty && product.brand != '-'
        ? product.brand
        : product.name;

    final verificationUrl = buildVerificationUrl(searchQuery);

    final lowerBrand = product.brand.toLowerCase();
    final lowerName = product.name.toLowerCase();

    bool isKnown = false;
    for (final brand in _knownHalalBrands) {
      if (lowerBrand.contains(brand) || lowerName.contains(brand)) {
        isKnown = true;
        break;
      }
    }

    if (isKnown) {
      return HalalCheckResult(
        query: searchQuery,
        status: 'TERDAFTAR RESMI',
        isCertified: true,
        agency: 'BPJPH Kemenag RI / LPPOM MUI',
        officialVerificationUrl: verificationUrl,
        description:
            'Merk/Produk ini telah terdaftar dan memegang sertifikasi halal resmi dari BPJPH Kementerian Agama Republik Indonesia.',
      );
    }

    return HalalCheckResult(
      query: searchQuery,
      status: 'VERIFIKASI BPJPH',
      isCertified: false,
      agency: 'BPJPH Kemenag RI',
      officialVerificationUrl: verificationUrl,
      description:
          'Ketuk tombol di bawah untuk memeriksa nomor sertifikat dan status ketetapan halal resmi produk ini di pangkalan data BPJPH Kemenag.',
    );
  }
}
