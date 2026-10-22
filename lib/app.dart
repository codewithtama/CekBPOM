import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/public_verification_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/info_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/providers/tab_provider.dart';
import 'core/theme/app_theme.dart';

class CekBpomApp extends StatelessWidget {
  const CekBpomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CekBPOM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  static const List<Widget> _screens = [
    HomeScreen(),
    PublicVerificationScreen(),
    HistoryScreen(),
    InfoScreen(),
    SettingsScreen(),
  ];

  final List<int> _tabHistory = [0];

  void _onTabSelected(int index) {
    if (index == 0) {
      _tabHistory
        ..clear()
        ..add(0);
    } else {
      _tabHistory
        ..remove(index)
        ..add(index);
    }
    ref.read(tabIndexProvider.notifier).state = index;
  }

  void _handlePop() {
    if (_tabHistory.length > 1) {
      _tabHistory.removeLast();
      ref.read(tabIndexProvider.notifier).state = _tabHistory.last;
    } else if (ref.read(tabIndexProvider) != 0) {
      _tabHistory
        ..clear()
        ..add(0);
      ref.read(tabIndexProvider.notifier).state = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(tabIndexProvider, (previous, next) {
      if (previous != next) {
        if (next == 0) {
          if (_tabHistory.length != 1 || _tabHistory.first != 0) {
            _tabHistory
              ..clear()
              ..add(0);
          }
        } else {
          _tabHistory
            ..remove(next)
            ..add(next);
        }
      }
    });

    final historyCount = ref.watch(historyProvider).length;
    final currentIndex = ref.watch(tabIndexProvider);
    final canPop = currentIndex == 0 && _tabHistory.length <= 1;

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handlePop();
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: _onTabSelected,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded),
              label: 'Scan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.verified_outlined),
              activeIcon: Icon(Icons.verified_rounded),
              label: 'Layanan',
            ),
            BottomNavigationBarItem(
              icon: historyCount > 0
                  ? Badge(
                      label: Text(historyCount.toString()),
                      child: const Icon(Icons.history_rounded),
                    )
                  : const Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.info_outline_rounded),
              activeIcon: Icon(Icons.info_rounded),
              label: 'Info',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
