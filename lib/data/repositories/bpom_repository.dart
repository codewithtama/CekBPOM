import 'dart:developer' as developer;
import '../../core/utils/connectivity_helper.dart';
import '../../core/utils/barcode_parser.dart';
import '../models/news_model.dart';
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

  /// Fetches live news from BPOM with offline fallback to critical warning alerts
  Future<List<NewsModel>> fetchNews() async {
    final hasConnection = await ConnectivityHelper.isConnected();

    if (!hasConnection) {
      developer.log('Offline: Returning static fallback news alerts', name: 'BpomRepository');
      return _getFallbackNews();
    }

    try {
      return await _apiService.fetchNews();
    } catch (e) {
      developer.log('Failed to fetch live news, returning fallback alerts', name: 'BpomRepository', error: e);
      return _getFallbackNews();
    }
  }

  List<NewsModel> _getFallbackNews() {
    return [
      NewsModel(
        title: 'Peringatan Kosmetik Mengandung Merkuri & Hidrokuinon',
        url: 'https://www.pom.go.id/berita',
        imageUrl: '',
        date: 'Mei 2026',
        description: 'BPOM merilis daftar kosmetik pemutih wajah ilegal yang terbukti mengandung bahan berbahaya Merkuri (Mercury) dan Hidrokuinon tingkat tinggi yang memicu kanker kulit. Harap waspada dan periksa kembali kosmetik Anda.',
      ),
      NewsModel(
        title: 'Penarikan Obat Sirop Tercemar Etilen Glikol (EG)',
        url: 'https://www.pom.go.id/berita',
        imageUrl: '',
        date: 'Februari 2026',
        description: 'Pengawasan ketat terhadap obat sirop anak. Beberapa bets produk ditarik karena ditemukan cemaran EG/DEG melebihi ambang batas aman yang memicu gagal ginjal akut pada anak.',
      ),
      NewsModel(
        title: 'Suplemen Tradisional Mengandung Bahan Kimia Obat (BKO)',
        url: 'https://www.pom.go.id/berita',
        imageUrl: '',
        date: 'Desember 2025',
        description: 'Hasil sampling menemukan jamu pegal linu dan penambah stamina ilegal dicampuri Bahan Kimia Obat parasetamol, sildenafil, dan dexamethasone tanpa izin edar resmi dari BPOM.',
      ),
      NewsModel(
        title: 'Kopi Kemasan Mengandung Sildenafil & Tadalafil',
        url: 'https://www.pom.go.id/berita',
        imageUrl: '',
        date: 'Oktober 2025',
        description: 'BPOM menyita produk kopi serbuk tradisional yang dicampuri obat kuat sildenafil secara ilegal. Konsumsi produk tersebut sangat berbahaya karena dapat memicu serangan jantung fatal.',
      ),
    ];
  }
}
