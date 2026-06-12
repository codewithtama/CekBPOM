import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/scan_history_model.dart';
import '../../data/services/history_service.dart';

// Provider for HistoryService instance
final historyServiceProvider = Provider<HistoryService>((ref) => HistoryService());

class HistoryNotifier extends StateNotifier<List<ScanHistoryModel>> {
  final HistoryService _historyService;

  HistoryNotifier(this._historyService) : super([]) {
    loadHistory();
  }

  void loadHistory() {
    state = _historyService.getHistory();
  }

  Future<void> deleteItem(dynamic key) async {
    await _historyService.deleteHistoryItem(key);
    loadHistory();
  }

  Future<void> clearAll() async {
    await _historyService.clearHistory();
    loadHistory();
  }
}

// StateNotifierProvider for list of ScanHistoryModel
final historyProvider = StateNotifierProvider<HistoryNotifier, List<ScanHistoryModel>>((ref) {
  final service = ref.watch(historyServiceProvider);
  return HistoryNotifier(service);
});
