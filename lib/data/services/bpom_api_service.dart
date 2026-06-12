import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../../core/constants/api_constants.dart';
import '../models/news_model.dart';
import '../models/product_model.dart';

class BpomApiService {
  final Dio _dio;

  BpomApiService({Dio? dio}) : _dio = dio ?? _createDefaultDio();

  static Dio _createDefaultDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      ),
    );
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    return dio;
  }

  /// Verifies authenticity of a product registration number
  Future<ProductModel> checkProduct(String code) async {
    developer.log('Checking product: $code', name: 'BpomApiService');
    
    // 1. Try hitting the primary public API (as requested)
    try {
      final response = await _dio.get('${ApiConstants.primaryApiUrl}$code');
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return ProductModel.fromJson(data);
        }
      }
    } catch (e) {
      developer.log(
        'Primary API failed or timed out. Falling back to web scraping...',
        name: 'BpomApiService',
        error: e,
      );
    }

    // 2. Fallback: scrape data from the main website using DataTables endpoint
    return _scrapeProduct(code);
  }

  /// Scrapes product from official website's DataTable endpoint
  Future<ProductModel> _scrapeProduct(String code) async {
    try {
      // Step A: Perform GET to retrieve session cookies and CSRF token
      developer.log('Step A: Fetching session cookies & CSRF token from all-produk page', name: 'BpomApiService');
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
          message: 'Failed to access BPOM web portal (Status: ${getResponse.statusCode})',
        );
      }

      // Extract cookies from response headers
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

      final cookieHeader = [xsrfCookie, sessionCookie]
          .where((c) => c != null && c.isNotEmpty)
          .join('; ');

      if (cookieHeader.isEmpty) {
        developer.log('Warning: No cookies extracted from BPOM response', name: 'BpomApiService');
      } else {
        developer.log('Extracted cookie header successfully', name: 'BpomApiService');
      }

      // Extract CSRF token from HTML
      final html = getResponse.data.toString();
      final csrfRegex = RegExp(r'name="csrf-token"\s+content="([^"]+)"');
      final csrfMatch = csrfRegex.firstMatch(html);
      final csrfToken = csrfMatch?.group(1);

      if (csrfToken == null || csrfToken.isEmpty) {
        throw Exception('Failed to parse security token (CSRF) from BPOM portal.');
      }
      developer.log('Successfully parsed CSRF token: $csrfToken', name: 'BpomApiService');

      // Step B: POST search payload to DataTables endpoint
      developer.log('Step B: POSTing query to DT endpoint', name: 'BpomApiService');
      
      final postHeaders = {
        'X-CSRF-TOKEN': csrfToken,
        'Referer': ApiConstants.fallbackAllProdukUrl,
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'X-Requested-With': 'XMLHttpRequest',
        'Cookie': cookieHeader,
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      };

      // Exact parameter naming mapped by metronic/jquery datatables server-side processing
      final data = {
        'draw': '1',
        'start': '0',
        'length': '10',
        'search[value]': '',
        'search[regex]': 'false',
        'product_register': code,
        'product_name': '',
        'product_brand': '',
        'product_package': '',
        'product_form': '',
        'ingredients': '',
        'submit_date_start': '',
        'submit_date_end': '',
        'product_date_start': '',
        'product_date_end': '',
        'expire_date_start': '',
        'expire_date_end': '',
        'manufacturer_name': '',
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
          final recordsFiltered = responseData['recordsFiltered'] ?? 0;
          final List<dynamic> dataList = responseData['data'] ?? [];

          developer.log('DataTable results filtered count: $recordsFiltered', name: 'BpomApiService');

          if (dataList.isNotEmpty) {
            // Found matched product, map the first result
            developer.log('Product registration found in BPOM database!', name: 'BpomApiService');
            return ProductModel.fromJson(dataList.first as Map<String, dynamic>);
          } else {
            // Not found in database
            developer.log('Product not found in BPOM database.', name: 'BpomApiService');
            return ProductModel.notFound(code);
          }
        }
      }
      
      throw Exception('Invalid response layout returned by BPOM server.');
    } on DioException catch (dioErr) {
      developer.log('Dio network error during fallback scraping', name: 'BpomApiService', error: dioErr);
      
      if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout) {
        throw Exception('Koneksi lambat, silakan coba lagi beberapa saat.');
      }
      throw Exception('Gagal menghubungi portal BPOM: ${dioErr.message}');
    } catch (e) {
      developer.log('Unexpected error during fallback scraping', name: 'BpomApiService', error: e);
      throw Exception('Gagal melakukan pengecekan produk. Silakan periksa koneksi internet Anda.');
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

      // Find all <article> tags
      final articleRegex = RegExp(r'<article[^>]*>(.*?)</article>', caseSensitive: false, dotAll: true);
      final matches = articleRegex.allMatches(html);

      developer.log('Found ${matches.length} article blocks in HTML', name: 'BpomApiService');

      for (final match in matches) {
        final block = match.group(1) ?? '';

        // Extract Title from card-title h5
        final titleRegex = RegExp(r'<h5 class="card-title">(.*?)</h5>', caseSensitive: false, dotAll: true);
        final titleMatch = titleRegex.firstMatch(block);
        String title = '';
        if (titleMatch != null) {
          title = titleMatch.group(1) ?? '';
          // Remove all HTML tags
          title = title.replaceAll(RegExp(r'<[^>]+>'), '').trim();
        }

        // Extract Link
        final linkRegex = RegExp(r'href="(/berita/[^"]+)"', caseSensitive: false);
        final linkMatch = linkRegex.firstMatch(block);
        String url = '';
        if (linkMatch != null) {
          final relPath = linkMatch.group(1) ?? '';
          url = 'https://www.pom.go.id$relPath';
        }

        // Extract Image
        final imgRegex = RegExp(r'<img[^>]*src="([^"]+)"', caseSensitive: false);
        final imgMatch = imgRegex.firstMatch(block);
        String imageUrl = '';
        if (imgMatch != null) {
          imageUrl = imgMatch.group(1) ?? '';
        }

        // Extract Date
        final dateRegex = RegExp(r'bi-clock.*?<small>(.*?)</small>', caseSensitive: false, dotAll: true);
        final dateMatch = dateRegex.firstMatch(block);
        String date = '';
        if (dateMatch != null) {
          date = (dateMatch.group(1) ?? '').trim();
        }

        // Extract Description/Snippet
        final descRegex = RegExp(r'<p class="card-text[^"]*">(.*?)</p>', caseSensitive: false, dotAll: true);
        final descMatch = descRegex.firstMatch(block);
        String description = '';
        if (descMatch != null) {
          description = descMatch.group(1) ?? '';
          // Clean html tags and entities
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
