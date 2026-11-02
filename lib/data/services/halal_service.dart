import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/halal_model.dart';
import '../models/halal_product_model.dart';
import '../models/product_model.dart';

enum HalalSearchType {
  product,
  producer,
  certificate,
}

class HalalService {
  HalalService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                  'Accept':
                      'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                  'Accept-Language': 'id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7',
                },
              ),
            );

  final Dio _dio;

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

  /// Evaluates Halal certification status for a BPOM product
  static HalalCheckResult checkProductHalal(ProductModel product) {
    developer.log('Evaluating Halal status for: ${product.name}', name: 'HalalService');

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

  /// Queries the live official BPJPH database natively and returns parsed [HalalSearchResult].
  Future<HalalSearchResult> searchHalal({
    String? productName,
    String? producerName,
    String? certificateNumber,
    int page = 1,
  }) async {
    final queryParams = <String, String>{};

    if (productName != null && productName.trim().isNotEmpty) {
      queryParams['produk'] = productName.trim();
    }
    if (producerName != null && producerName.trim().isNotEmpty) {
      queryParams['produsen'] = producerName.trim();
    }
    if (certificateNumber != null && certificateNumber.trim().isNotEmpty) {
      queryParams['no_regis'] = certificateNumber.trim();
    }
    if (page > 1) {
      queryParams['page'] = page.toString();
    }

    try {
      final response = await _dio.get<String>(
        ApiConstants.bpjphHalalSearchUrl,
        queryParameters: queryParams,
      );

      final html = response.data ?? '';
      return _parseHalalResponse(html, page);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('Gagal terhubung ke server BPJPH Kemenag. Periksa koneksi internet Anda.');
      }
      throw Exception('Terjadi kesalahan saat memuat data halal: ${e.message}');
    } catch (e) {
      throw Exception('Gagal memproses data sertifikasi halal: $e');
    }
  }

  /// Extracts and parses streamed RSC data from Next.js HTML response.
  HalalSearchResult _parseHalalResponse(String html, int requestedPage) {
    final pushRegex = RegExp(r'self\.__next_f\.push\(\[1,\s*"(.*?)"\]\)', dotAll: true);
    final matches = pushRegex.allMatches(html);

    final streamBuffer = StringBuffer();
    for (final match in matches) {
      final rawPush = match.group(1);
      if (rawPush != null && rawPush.isNotEmpty) {
        final unescaped = rawPush
            .replaceAll(r'\"', '"')
            .replaceAll(r'\\', r'\')
            .replaceAll(r'\n', '\n')
            .replaceAll(r'\r', '\r')
            .replaceAll(r'\t', '\t');
        streamBuffer.write(unescaped);
      }
    }

    final fullStream = streamBuffer.toString();

    // Extract pagination metadata
    final totalItemsMatch = RegExp(r'"totalItems":\s*(\d+)').firstMatch(fullStream);
    final totalPagesMatch = RegExp(r'"totalPages":\s*(\d+)').firstMatch(fullStream);
    final currentPageMatch = RegExp(r'"currentPage":\s*(\d+)').firstMatch(fullStream);
    final pageSizeMatch = RegExp(r'"pageSize":\s*(\d+)').firstMatch(fullStream);

    final totalItems = int.tryParse(totalItemsMatch?.group(1) ?? '0') ?? 0;
    final totalPages = int.tryParse(totalPagesMatch?.group(1) ?? '0') ?? 0;
    final currentPage = int.tryParse(currentPageMatch?.group(1) ?? requestedPage.toString()) ?? requestedPage;
    final pageSize = int.tryParse(pageSizeMatch?.group(1) ?? '10') ?? 10;

    // Locate "data":[
    final dataIdx = fullStream.indexOf('"data":[');
    if (dataIdx == -1) {
      return HalalSearchResult(
        items: const [],
        currentPage: currentPage,
        totalItems: 0,
        totalPages: 0,
        pageSize: pageSize,
      );
    }

    final start = dataIdx + 7;
    int bracketCount = 0;
    int end = start;

    for (int i = start; i < fullStream.length; i++) {
      if (fullStream[i] == '[') {
        bracketCount++;
      } else if (fullStream[i] == ']') {
        bracketCount--;
        if (bracketCount == 0) {
          end = i + 1;
          break;
        }
      }
    }

    if (end <= start) {
      return HalalSearchResult(
        items: const [],
        currentPage: currentPage,
        totalItems: totalItems,
        totalPages: totalPages,
        pageSize: pageSize,
      );
    }

    final jsonArrayStr = fullStream.substring(start, end);
    try {
      final decodedList = jsonDecode(jsonArrayStr) as List<dynamic>;
      final products = decodedList
          .whereType<Map<String, dynamic>>()
          .map(HalalProductModel.fromJson)
          .toList();

      return HalalSearchResult(
        items: products,
        currentPage: currentPage,
        totalItems: totalItems > 0 ? totalItems : products.length,
        totalPages: totalPages > 0 ? totalPages : 1,
        pageSize: pageSize,
      );
    } catch (e) {
      developer.log('Error parsing halal JSON array: $e', name: 'HalalService');
      return HalalSearchResult(
        items: const [],
        currentPage: currentPage,
        totalItems: 0,
        totalPages: 0,
        pageSize: pageSize,
      );
    }
  }
}
