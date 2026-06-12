import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/history_service.dart';
import 'history_provider.dart';

class PaoState {
  final Map<String, Map<dynamic, dynamic>> records;

  PaoState({required this.records});

  PaoState copyWith({Map<String, Map<dynamic, dynamic>>? records}) {
    return PaoState(records: records ?? this.records);
  }
}

class PaoNotifier extends StateNotifier<PaoState> {
  final HistoryService _historyService;

  PaoNotifier(this._historyService) : super(PaoState(records: {})) {
    loadPaoRecords();
  }

  void loadPaoRecords() {
    final historyList = _historyService.getHistory();
    final Map<String, Map<dynamic, dynamic>> localRecords = {};
    
    for (final item in historyList) {
      final regNo = item.product.registrationNumber;
      final pao = _historyService.getPao(regNo);
      if (pao != null) {
        localRecords[regNo] = pao;
      }
    }
    state = PaoState(records: localRecords);
  }

  Future<void> savePao(String regNumber, DateTime openedDate, int paoMonths) async {
    await _historyService.savePao(regNumber, openedDate, paoMonths);
    loadPaoRecords();
  }

  Future<void> deletePao(String regNumber) async {
    await _historyService.deletePao(regNumber);
    loadPaoRecords();
  }

  Future<void> clearAll() async {
    await _historyService.clearAllPao();
    state = PaoState(records: {});
  }
}

final paoProvider = StateNotifierProvider<PaoNotifier, PaoState>((ref) {
  final service = ref.watch(historyServiceProvider);
  return PaoNotifier(service);
});
