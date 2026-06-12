import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/info_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/providers/history_provider.dart';
import 'core/theme/app_theme.dart';

class CekBpomApp extends ConsumerStatefulWidget {
  const CekBpomApp({super.key});

  @override
  ConsumerState<CekBpomApp> createState() => _CekBpomAppState();
}

class _CekBpomAppState extends ConsumerState<CekBpomApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const InfoScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final historyList = ref.watch(historyProvider);
    final historyCount = historyList.length;

    return MaterialApp(
      title: 'CekBPOM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded),
              label: 'Scan',
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
