import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/bpom_repository.dart';
import '../../data/services/bpom_api_service.dart';
import 'scan_provider.dart';

class SearchState {
  final String query;
  final BpomSearchType searchType;
  final bool isLoading;
  final bool isLoadingMore;
  final List<ProductModel> products;
  final int totalRecords;
  final int filteredRecords;
  final String? error;
  final int currentStart;
  final bool hasMore;

  const SearchState({
    this.query = '',
    this.searchType = BpomSearchType.productName,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.products = const [],
    this.totalRecords = 0,
    this.filteredRecords = 0,
    this.error,
    this.currentStart = 0,
    this.hasMore = false,
  });

  SearchState copyWith({
    String? query,
    BpomSearchType? searchType,
    bool? isLoading,
    bool? isLoadingMore,
    List<ProductModel>? products,
    int? totalRecords,
    int? filteredRecords,
    String? error,
    int? currentStart,
    bool? hasMore,
  }) {
    return SearchState(
      query: query ?? this.query,
      searchType: searchType ?? this.searchType,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      products: products ?? this.products,
      totalRecords: totalRecords ?? this.totalRecords,
      filteredRecords: filteredRecords ?? this.filteredRecords,
      error: error,
      currentStart: currentStart ?? this.currentStart,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final BpomRepository _repository;
  static const int _pageSize = 20;

  SearchNotifier(this._repository) : super(const SearchState());

  void setSearchType(BpomSearchType type) {
    if (state.searchType == type) return;
    state = state.copyWith(searchType: type);
    if (state.query.trim().isNotEmpty) {
      search(state.query);
    }
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(
        query: '',
        isLoading: false,
        products: [],
        totalRecords: 0,
        filteredRecords: 0,
        hasMore: false,
        error: null,
      );
      return;
    }

    state = state.copyWith(
      query: trimmed,
      isLoading: true,
      error: null,
      currentStart: 0,
    );

    try {
      final response = await _repository.searchProducts(
        query: trimmed,
        searchType: state.searchType,
        start: 0,
        length: _pageSize,
      );

      final hasMore = response.products.length < response.filteredRecords &&
          response.products.length == _pageSize;

      state = state.copyWith(
        isLoading: false,
        products: response.products,
        totalRecords: response.totalRecords,
        filteredRecords: response.filteredRecords,
        currentStart: response.products.length,
        hasMore: hasMore,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final response = await _repository.searchProducts(
        query: state.query,
        searchType: state.searchType,
        start: state.currentStart,
        length: _pageSize,
      );

      final combined = [...state.products, ...response.products];
      final hasMore = combined.length < response.filteredRecords &&
          response.products.length == _pageSize;

      state = state.copyWith(
        isLoadingMore: false,
        products: combined,
        currentStart: combined.length,
        hasMore: hasMore,
        totalRecords: response.totalRecords,
        filteredRecords: response.filteredRecords,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Gagal memuat halaman berikutnya: ${e.toString().replaceAll('Exception: ', '')}',
      );
    }
  }

  void clear() {
    state = const SearchState();
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repo = ref.watch(bpomRepositoryProvider);
  return SearchNotifier(repo);
});

