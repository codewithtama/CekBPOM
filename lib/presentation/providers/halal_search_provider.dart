import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/halal_product_model.dart';
import '../../data/services/halal_service.dart';

enum HalalSearchStatus {
  initial,
  loading,
  success,
  empty,
  error,
  loadingMore,
}

class HalalSearchState {
  const HalalSearchState({
    this.status = HalalSearchStatus.initial,
    this.query = '',
    this.searchType = HalalSearchType.product,
    this.results = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.errorMessage,
  });

  final HalalSearchStatus status;
  final String query;
  final HalalSearchType searchType;
  final List<HalalProductModel> results;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String? errorMessage;

  bool get hasMore => currentPage < totalPages;
  bool get isLoading => status == HalalSearchStatus.loading;
  bool get isLoadingMore => status == HalalSearchStatus.loadingMore;

  HalalSearchState copyWith({
    HalalSearchStatus? status,
    String? query,
    HalalSearchType? searchType,
    List<HalalProductModel>? results,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    String? errorMessage,
  }) {
    return HalalSearchState(
      status: status ?? this.status,
      query: query ?? this.query,
      searchType: searchType ?? this.searchType,
      results: results ?? this.results,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      errorMessage: errorMessage,
    );
  }
}

final halalServiceProvider = Provider<HalalService>((ref) {
  return HalalService();
});

class HalalSearchNotifier extends StateNotifier<HalalSearchState> {
  HalalSearchNotifier(this._halalService) : super(const HalalSearchState());

  final HalalService _halalService;

  /// Performs a fresh native Halal search against BPJPH.
  Future<void> search({
    required String query,
    HalalSearchType? type,
  }) async {
    final trimmed = query.trim();
    final effectiveType = type ?? state.searchType;

    if (trimmed.isEmpty) {
      state = state.copyWith(
        status: HalalSearchStatus.initial,
        query: '',
        results: const [],
        totalItems: 0,
        totalPages: 1,
        currentPage: 1,
      );
      return;
    }

    state = state.copyWith(
      status: HalalSearchStatus.loading,
      query: trimmed,
      searchType: effectiveType,
      currentPage: 1,
      errorMessage: null,
    );

    try {
      final result = await _fetchPage(
        query: trimmed,
        type: effectiveType,
        page: 1,
      );

      if (result.items.isEmpty) {
        state = state.copyWith(
          status: HalalSearchStatus.empty,
          results: const [],
          totalItems: 0,
          totalPages: 1,
          currentPage: 1,
        );
      } else {
        state = state.copyWith(
          status: HalalSearchStatus.success,
          results: result.items,
          totalItems: result.totalItems,
          totalPages: result.totalPages,
          currentPage: 1,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: HalalSearchStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Loads the next page for infinite scrolling.
  Future<void> loadNextPage() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(status: HalalSearchStatus.loadingMore);

    try {
      final result = await _fetchPage(
        query: state.query,
        type: state.searchType,
        page: nextPage,
      );

      state = state.copyWith(
        status: HalalSearchStatus.success,
        results: [...state.results, ...result.items],
        currentPage: nextPage,
        totalPages: result.totalPages,
        totalItems: result.totalItems,
      );
    } catch (e) {
      // Don't wipe existing results on pagination failure, just revert status
      state = state.copyWith(
        status: HalalSearchStatus.success,
        errorMessage: 'Gagal memuat halaman berikutnya: $e',
      );
    }
  }

  /// Sets the active filter type and optionally re-triggers search if query exists.
  void setFilterType(HalalSearchType type) {
    if (state.searchType == type) return;
    state = state.copyWith(searchType: type);
    if (state.query.isNotEmpty) {
      search(query: state.query, type: type);
    }
  }

  Future<HalalSearchResult> _fetchPage({
    required String query,
    required HalalSearchType type,
    required int page,
  }) {
    switch (type) {
      case HalalSearchType.product:
        return _halalService.searchHalal(productName: query, page: page);
      case HalalSearchType.producer:
        return _halalService.searchHalal(producerName: query, page: page);
      case HalalSearchType.certificate:
        return _halalService.searchHalal(certificateNumber: query, page: page);
    }
  }
}

final halalSearchProvider =
    StateNotifierProvider<HalalSearchNotifier, HalalSearchState>((ref) {
  final service = ref.watch(halalServiceProvider);
  return HalalSearchNotifier(service);
});

