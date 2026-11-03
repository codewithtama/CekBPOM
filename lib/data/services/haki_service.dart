import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/trademark_model.dart';

/// Service for querying registered trademarks from the DJKI Kemenkumham database
/// via the official haki.id API.
class HakiService {
  HakiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConstants.hakiBaseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                headers: const {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                  'Accept': 'application/json, text/plain, */*',
                  'Accept-Language': 'id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7',
                },
              ),
            );

  final Dio _dio;

  /// Searches the national trademark registry on haki.id for the given [keyword].
  Future<TrademarkSearchResult> searchTrademarks(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) {
      return const TrademarkSearchResult(
        success: true,
        total: 0,
        totalPages: 0,
        page: 1,
        items: [],
      );
    }

    try {
      developer.log('Searching trademarks for: $trimmed', name: 'HakiService');

      final response = await _dio.get<Map<String, dynamic>>(
        '/api/trademarks',
        queryParameters: {'keyword': trimmed},
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Respon dari server HAKI kosong.');
      }

      final success = data['success'] as bool? ?? false;
      final total = (data['total'] as num?)?.toInt() ?? 0;
      final totalPages = (data['totalPages'] as num?)?.toInt() ?? 0;
      final page = (data['page'] as num?)?.toInt() ?? 1;

      final rawList = data['data'] as List<dynamic>? ?? <dynamic>[];
      final items = rawList
          .whereType<Map<String, dynamic>>()
          .map(TrademarkModel.fromJson)
          .toList();

      return TrademarkSearchResult(
        success: success,
        total: total > 0 ? total : items.length,
        totalPages: totalPages,
        page: page,
        items: items,
      );
    } on DioException catch (e) {
      developer.log('DioException in HakiService: ${e.message}', name: 'HakiService');
      if (e.response?.statusCode == 400) {
        final msg = e.response?.data is Map
            ? (e.response?.data as Map)['statusMessage'] as String?
            : null;
        throw Exception(msg ?? 'Kata kunci pencarian tidak valid.');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception(
          'Pencarian ke pangkalan data DJKI memerlukan waktu lebih lama dari biasanya. Silakan coba lagi.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Tidak dapat terhubung ke server HKI. Periksa koneksi internet Anda.');
      }
      throw Exception('Terjadi kesalahan saat memuat data merek HKI: ${e.message}');
    } catch (e) {
      throw Exception('Gagal mencari data merek HKI: $e');
    }
  }
}

