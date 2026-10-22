import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cekbpom/app.dart';
import 'package:cekbpom/data/models/scan_history_model.dart';
import 'package:cekbpom/presentation/providers/history_provider.dart';
import 'package:cekbpom/presentation/providers/settings_provider.dart';
import 'package:cekbpom/presentation/providers/tab_provider.dart';

class _FakeHistoryNotifier extends StateNotifier<List<ScanHistoryModel>>
    implements HistoryNotifier {
  _FakeHistoryNotifier() : super([]);

  @override
  void loadHistory() {}

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> addHistory(dynamic product) async {}

  @override
  Future<void> clearAllData() async {}

  @override
  Future<void> clearHistory() async {}

  @override
  Future<void> deleteItem(dynamic key) async {}
}

class _FakeSettingsNotifier extends StateNotifier<AppSettings>
    implements SettingsNotifier {
  _FakeSettingsNotifier()
      : super(AppSettings(enableVibration: true, enableSound: true));

  @override
  Future<void> toggleSound(bool value) async {}

  @override
  Future<void> toggleVibration(bool value) async {}
}

void main() {
  testWidgets('Back gesture on non-zero tab returns to previous tab', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          historyProvider.overrideWith((ref) => _FakeHistoryNotifier()),
          settingsProvider.overrideWith((ref) => _FakeSettingsNotifier()),
        ],
        child: const CekBpomApp(),
      ),
    );
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(CekBpomApp));
    final container = ProviderScope.containerOf(element);

    expect(container.read(tabIndexProvider), 0);

    // Tap Tab 1 ("Layanan")
    await tester.tap(find.text('Layanan'));
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), 1);

    // Tap Tab 2 ("Riwayat")
    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), 2);

    // Tap Tab 4 ("Pengaturan")
    await tester.tap(find.text('Pengaturan'));
    await tester.pumpAndSettle();
    expect(container.read(tabIndexProvider), 4);

    // Trigger back navigation (system swipe back gesture)
    final didPopPengaturan = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Handled by returning to Riwayat (Tab 2)
    expect(didPopPengaturan, isTrue);
    expect(container.read(tabIndexProvider), 2);

    // Trigger back navigation again
    final didPopRiwayat = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Handled by returning to Layanan (Tab 1)
    expect(didPopRiwayat, isTrue);
    expect(container.read(tabIndexProvider), 1);

    // Trigger back navigation again
    final didPopLayanan = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Handled by returning to Scan (Tab 0)
    expect(didPopLayanan, isTrue);
    expect(container.read(tabIndexProvider), 0);

    // Trigger back navigation on Home tab: now it allows popping the app root
    final didPopHome = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(didPopHome, isFalse); // Root canPop was true, no route to pop -> system can exit
  });
}
