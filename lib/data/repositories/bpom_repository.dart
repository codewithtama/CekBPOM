import 'dart:developer' as developer;
import '../../core/utils/connectivity_helper.dart';
import '../../core/utils/barcode_parser.dart';
import '../models/product_model.dart';
import '../services/bpom_api_service.dart';
import '../services/history_service.dart';

class BpomRepository {
  final BpomApiService _apiService;
  final HistoryService _historyService;

  BpomRepository({
    required BpomApiService apiService,
    required HistoryService historyService,
  })  : _apiService = apiService,
        _historyService = historyService;

  /// Validates and checks product registration number
  Future<ProductModel> checkProduct(String code) async {
    final cleaned = BarcodeParser.cleanCode(code);
    if (cleaned.isEmpty) {
      throw Exception('Nomor registrasi tidak valid.');
    }

    final hasConnection = await ConnectivityHelper.isConnected();

    if (!hasConnection) {
      developer.log('Offline mode active. Searching local cache...', name: 'BpomRepository');
      final cachedProduct = _historyService.getCachedProduct(cleaned);
      if (cachedProduct != null) {
        return cachedProduct;
      } else {
        throw Exception(
          'Anda sedang offline. Produk ini belum pernah dipindai sebelumnya, sehingga tidak ada di cache lokal.',
        );
      }
    }

    // Online mode: fetch from API/scraper
    final product = await _apiService.checkProduct(cleaned);
    
    // Cache the result into scan history
    await _historyService.addHistory(product);
    
    return product;
  }
}
