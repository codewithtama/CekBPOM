import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/product_lookup_result.dart';
import '../models/news_model.dart';
import '../models/product_model.dart';

enum BpomSearchType {
  registrationNumber,
  productName,
  brand,
  manufacturer,
}

extension BpomSearchTypeExtension on BpomSearchType {
  String get label {
    switch (this) {
      case BpomSearchType.registrationNumber:
        return 'No. Registrasi';
      case BpomSearchType.productName:
        return 'Nama Produk';
      case BpomSearchType.brand:
        return 'Merk / Brand';
      case BpomSearchType.manufacturer:
        return 'Pendaftar / Pabrik';
    }
  }

  String get hintText {
    switch (this) {
      case BpomSearchType.registrationNumber:
        return 'Contoh: NA18210100001 atau MD2409...';
      case BpomSearchType.productName:
        return 'Contoh: Serum Acne, Susu UHT, Paracetamol...';
      case BpomSearchType.brand:
        return 'Contoh: Wardah, Indomie, Somethinc...';
      case BpomSearchType.manufacturer:
        return 'Contoh: PT Paragon, PT Indofood...';
    }
  }
}

class BpomSearchResponse {
  final List<ProductModel> products;
  final int totalRecords;
  final int filteredRecords;

  const BpomSearchResponse({
    required this.products,
    required this.totalRecords,
    required this.filteredRecords,
  });
}

class BpomApiService {
  final Dio _dio;
  String? _cachedCookieHeader;
  String? _cachedCsrfToken;
  DateTime? _sessionTimestamp;

  BpomApiService({Dio? dio}) : _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      ),
    );
  }

  Future<void> _ensureSession({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedCookieHeader != null &&
        _cachedCsrfToken != null &&
        _sessionTimestamp != null &&
        now.difference(_sessionTimestamp!) < const Duration(minutes: 8)) {
      return;
    }

    developer.log('Fetching session cookies & CSRF token from BPOM portal', name: 'BpomApiService');
    final getResponse = await _dio.get(
      ApiConstants.fallbackAllProdukUrl,
      options: Options(
        headers: {
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
        },
      ),
    );

    if (getResponse.statusCode != 200) {
      throw DioException(
        requestOptions: getResponse.requestOptions,
        response: getResponse,
        message: 'Gagal mengakses portal BPOM (Status: ${getResponse.statusCode})',
      );
    }

    final setCookies = getResponse.headers['set-cookie'];
    String? sessionCookie;
    String? xsrfCookie;

    if (setCookies != null) {
      for (var cookie in setCookies) {
        if (cookie.contains('webreg_session')) {
          sessionCookie = cookie.split(';').first;
        }
        if (cookie.contains('XSRF-TOKEN')) {
          xsrfCookie = cookie.split(';').first;
        }
      }
    }

    _cachedCookieHeader = [xsrfCookie, sessionCookie]
        .where((c) => c != null && c.isNotEmpty)
        .join('; ');

    final html = getResponse.data.toString();
    final csrfRegex = RegExp(r'name="csrf-token"\s+content="([^"]+)"');
    final csrfMatch = csrfRegex.firstMatch(html);
    _cachedCsrfToken = csrfMatch?.group(1);

    if (_cachedCsrfToken == null || _cachedCsrfToken!.isEmpty) {
      throw Exception('Gagal mendapatkan token keamanan (CSRF) dari portal BPOM.');
    }

    _sessionTimestamp = now;
    developer.log('BPOM session initialized successfully', name: 'BpomApiService');
  }

  /// Searches products in BPOM database with pagination and field filters
  Future<BpomSearchResponse> searchProducts({
    required String query,
    required BpomSearchType searchType,
    int start = 0,
    int length = 20,
    bool isRetry = false,
  }) async {
    try {
      await _ensureSession(forceRefresh: isRetry);

      final postHeaders = {
        'X-CSRF-TOKEN': _cachedCsrfToken ?? '',
        'Referer': ApiConstants.fallbackAllProdukUrl,
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'X-Requested-With': 'XMLHttpRequest',
        'Cookie': _cachedCookieHeader ?? '',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      };

      String regQuery = '';
      String nameQuery = '';
      String brandQuery = '';
      String mfgQuery = '';

      switch (searchType) {
        case BpomSearchType.registrationNumber:
          regQuery = query.trim();
          break;
        case BpomSearchType.productName:
          nameQuery = query.trim();
          break;
        case BpomSearchType.brand:
          brandQuery = query.trim();
          break;
        case BpomSearchType.manufacturer:
          mfgQuery = query.trim();
          break;
      }

      final data = {
        'draw': '1',
        'start': start.toString(),
        'length': length.toString(),
        'search[value]': '',
        'search[regex]': 'false',
        'product_register': regQuery,
        'product_name': nameQuery,
        'product_brand': brandQuery,
        'product_package': '',
        'product_form': '',
        'ingredients': '',
        'submit_date_start': '',
        'submit_date_end': '',
        'product_date_start': '',
        'product_date_end': '',
        'expire_date_start': '',
        'expire_date_end': '',
        'manufacturer_name': mfgQuery,
        'status': '',
        'release_date': '',
        'query': '',
        'manufacturer': '',
        'registrar': '',
      };

      final postResponse = await _dio.post(
        ApiConstants.fallbackApiUrl,
        data: data,
        options: Options(
          headers: postHeaders,
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      if (postResponse.statusCode == 200 && postResponse.data != null) {
        final responseData = postResponse.data;
        if (responseData is Map<String, dynamic>) {
          final totalRecords = (responseData['recordsTotal'] as num?)?.toInt() ?? 0;
          final filteredRecords = (responseData['recordsFiltered'] as num?)?.toInt() ?? 0;
          final List<dynamic> dataList = responseData['data'] ?? [];

          final products = dataList
              .whereType<Map<String, dynamic>>()
              .map((item) => ProductModel.fromJson(item))
              .toList();

          return BpomSearchResponse(
            products: products,
            totalRecords: totalRecords,
            filteredRecords: filteredRecords,
          );
        }
      }

      throw Exception('Format respon BPOM tidak sesuai standar.');
    } on DioException catch (dioErr) {
      if (!isRetry && (dioErr.response?.statusCode == 419 || dioErr.response?.statusCode == 401)) {
        developer.log('Session expired, refreshing and retrying search...', name: 'BpomApiService');
        return searchProducts(
          query: query,
          searchType: searchType,
          start: start,
          length: length,
          isRetry: true,
        );
      }

      developer.log('Dio network error during search', name: 'BpomApiService', error: dioErr);
      if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout) {
        throw Exception('Koneksi lambat, silakan coba beberapa saat lagi.');
      }
      throw Exception('Gagal menghubungi portal BPOM: ${dioErr.message}');
    } catch (e) {
      developer.log('Unexpected error during BPOM search', name: 'BpomApiService', error: e);
      throw Exception('Gagal memproses pencarian. Periksa koneksi internet Anda.');
    }
  }

  /// Verifies authenticity of a product registration number
  Future<ProductLookupResult> checkProduct(String code) async {
    developer.log('Checking product registration: $code', name: 'BpomApiService');

    final searchResult = await searchProducts(
      query: code,
      searchType: BpomSearchType.registrationNumber,
      start: 0,
      length: 10,
    );

    if (searchResult.products.isNotEmpty) {
      return ProductLookupResult(
        product: searchResult.products.first,
        sourceLabel: 'BPOM',
      );
    } else {
      return ProductLookupResult(
        product: ProductModel.notFound(code),
        sourceLabel: 'BPOM',
      );
    }
  }

  /// Fetches and parses live news from BPOM portal
  Future<List<NewsModel>> fetchNews() async {
    developer.log('Fetching news from: ${ApiConstants.bpomNewsUrl}', name: 'BpomApiService');
    try {
      final response = await _dio.get(
        ApiConstants.bpomNewsUrl,
        options: Options(
          headers: {
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat berita BPOM (Status: ${response.statusCode})');
      }

      final html = response.data.toString();
      final List<NewsModel> newsList = [];

      final articleRegex = RegExp(r'<article[^>]*>(.*?)</article>', caseSensitive: false, dotAll: true);
      final matches = articleRegex.allMatches(html);

      for (final match in matches) {
        final block = match.group(1) ?? '';

        final titleRegex = RegExp(r'<h5 class="card-title">(.*?)</h5>', caseSensitive: false, dotAll: true);
        final titleMatch = titleRegex.firstMatch(block);
        String title = '';
        if (titleMatch != null) {
          title = titleMatch.group(1) ?? '';
          title = title.replaceAll(RegExp(r'<[^>]+>'), '').trim();
        }

        final linkRegex = RegExp(r'href="(/berita/[^"]+)"', caseSensitive: false);
        final linkMatch = linkRegex.firstMatch(block);
        String url = '';
        if (linkMatch != null) {
          final relPath = linkMatch.group(1) ?? '';
          url = 'https://www.pom.go.id$relPath';
        }

        final imgRegex = RegExp(r'<img[^>]*src="([^"]+)"', caseSensitive: false);
        final imgMatch = imgRegex.firstMatch(block);
        String imageUrl = '';
        if (imgMatch != null) {
          imageUrl = imgMatch.group(1) ?? '';
        }

        final dateRegex = RegExp(r'bi-clock.*?<small>(.*?)</small>', caseSensitive: false, dotAll: true);
        final dateMatch = dateRegex.firstMatch(block);
        String date = '';
        if (dateMatch != null) {
          date = (dateMatch.group(1) ?? '').trim();
        }

        final descRegex = RegExp(r'<p class="card-text[^"]*">(.*?)</p>', caseSensitive: false, dotAll: true);
        final descMatch = descRegex.firstMatch(block);
        String description = '';
        if (descMatch != null) {
          description = descMatch.group(1) ?? '';
          description = description.replaceAll(RegExp(r'<[^>]+>'), '').trim();
          description = description
              .replaceAll('&ndash;', '–')
              .replaceAll('&ldquo;', '"')
              .replaceAll('&rdquo;', '"')
              .replaceAll('&nbsp;', ' ')
              .replaceAll('&amp;', '&');
        }

        if (title.isNotEmpty && url.isNotEmpty) {
          newsList.add(
            NewsModel(
              title: title,
              url: url,
              imageUrl: imageUrl,
              date: date,
              description: description,
            ),
          );
        }
      }

      developer.log('Parsed ${newsList.length} news items successfully', name: 'BpomApiService');
      return newsList;
    } on DioException catch (dioErr) {
      developer.log('Dio network error during news fetch', name: 'BpomApiService', error: dioErr);
      throw Exception('Gagal menghubungi portal berita BPOM: ${dioErr.message}');
    } catch (e) {
      developer.log('Unexpected error during news fetch', name: 'BpomApiService', error: e);
      throw Exception('Gagal memproses berita BPOM. Silakan periksa koneksi internet Anda.');
    }
  }
}
