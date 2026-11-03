import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trademark_model.dart';
import '../../data/services/haki_service.dart';

enum TrademarkStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class TrademarkState {
  const TrademarkState({
    this.status = TrademarkStatus.initial,
    this.query = '',
    this.results = const [],
    this.totalCount = 0,
    this.errorMessage,
  });

  final TrademarkStatus status;
  final String query;
  final List<TrademarkModel> results;
  final int totalCount;
  final String? errorMessage;

  bool get isLoading => status == TrademarkStatus.loading;

  TrademarkState copyWith({
    TrademarkStatus? status,
    String? query,
    List<TrademarkModel>? results,
    int? totalCount,
    String? errorMessage,
  }) {
    return TrademarkState(
      status: status ?? this.status,
      query: query ?? this.query,
      results: results ?? this.results,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage,
    );
  }
}

final hakiServiceProvider = Provider<HakiService>((ref) {
  return HakiService();
});

class TrademarkNotifier extends StateNotifier<TrademarkState> {
  TrademarkNotifier(this._hakiService) : super(const TrademarkState());

  final HakiService _hakiService;

  /// Searches registered trademarks on haki.id by keyword.
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const TrademarkState();
      return;
    }

    state = state.copyWith(
      status: TrademarkStatus.loading,
      query: trimmed,
      errorMessage: null,
    );

    try {
      final result = await _hakiService.searchTrademarks(trimmed);

      if (result.items.isEmpty) {
        state = state.copyWith(
          status: TrademarkStatus.empty,
          results: const [],
          totalCount: 0,
        );
      } else {
        state = state.copyWith(
          status: TrademarkStatus.success,
          results: result.items,
          totalCount: result.total,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: TrademarkStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clear() {
    state = const TrademarkState();
  }
}

final trademarkProvider =
    StateNotifierProvider<TrademarkNotifier, TrademarkState>((ref) {
  final service = ref.watch(hakiServiceProvider);
  return TrademarkNotifier(service);
});

