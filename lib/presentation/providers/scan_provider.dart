import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/bpom_repository.dart';
import '../../data/services/bpom_api_service.dart';
import 'history_provider.dart';

// Provider for BpomApiService
final apiServiceProvider = Provider<BpomApiService>((ref) => BpomApiService());

// Provider for BpomRepository
final bpomRepositoryProvider = Provider<BpomRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  final history = ref.watch(historyServiceProvider);
  return BpomRepository(apiService: api, historyService: history);
});

class ScanState {
  final bool isLoading;
  final String? error;
  final ProductModel? result;

  ScanState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  ScanState copyWith({
    bool? isLoading,
    String? error,
    ProductModel? result,
  }) {
    return ScanState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      result: result ?? this.result,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  final BpomRepository _repository;
  final Ref _ref;

  ScanNotifier(this._repository, this._ref) : super(ScanState());

  Future<void> checkProduct(String code) async {
    state = ScanState(isLoading: true);
    try {
      final product = await _repository.checkProduct(code);
      state = ScanState(isLoading: false, result: product);
      // Automatically refresh scan history list
      _ref.read(historyProvider.notifier).loadHistory();
    } catch (e) {
      state = ScanState(
        isLoading: false, 
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void clearResult() {
    state = ScanState();
  }
}

final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  final repo = ref.watch(bpomRepositoryProvider);
  return ScanNotifier(repo, ref);
});
