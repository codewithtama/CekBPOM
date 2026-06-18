import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/screens/info_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/providers/tab_provider.dart';
import 'core/theme/app_theme.dart';

class CekBpomApp extends ConsumerWidget {
  const CekBpomApp({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    HistoryScreen(),
    InfoScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'CekBPOM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: BiometricGate(
        child: _AppShell(ref: ref),
      ),
    );
  }
}

class _AppShell extends ConsumerWidget {
  final WidgetRef ref;

  const _AppShell({required this.ref});

  static const List<Widget> _screens = [
    HomeScreen(),
    HistoryScreen(),
    InfoScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyList = ref.watch(historyProvider);
    final historyCount = historyList.length;
    final currentIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(tabIndexProvider.notifier).state = index;
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
    );
  }
}

class BiometricGate extends StatefulWidget {
  final Widget child;

  const BiometricGate({super.key, required this.child});

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticated = false;
  bool _isChecking = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isAuthenticated) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_isChecking || _isAuthenticated) {
      return;
    }

    if (kIsWeb || !(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      setState(() {
        _isAuthenticated = true;
        _message = null;
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _message = null;
    });

    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      if (!canCheckBiometrics || !isSupported) {
        if (!mounted) return;
        setState(() {
          _message = 'Perangkat ini belum mendukung sidik jari atau face unlock.';
          _isChecking = false;
        });
        return;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Scan sidik jari atau face unlock untuk membuka CekBPOM.',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (!mounted) return;
      setState(() {
        _isAuthenticated = authenticated;
        _isChecking = false;
        _message = authenticated ? null : 'Autentikasi dibatalkan.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isChecking = false;
        _message = 'Gagal autentikasi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint_rounded, size: 72),
                const SizedBox(height: 20),
                Text(
                  'Kunci Keamanan',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Gunakan sidik jari atau face unlock sebelum masuk ke aplikasi.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_isChecking) const LinearProgressIndicator(),
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _message!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _authenticate,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Buka Aplikasi'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
