import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';

class HalalWebviewScreen extends StatefulWidget {
  final String initialUrl;
  final String title;
  final String query;

  const HalalWebviewScreen({
    super.key,
    required this.initialUrl,
    required this.title,
    required this.query,
  });

  @override
  State<HalalWebviewScreen> createState() => _HalalWebviewScreenState();
}

class _HalalWebviewScreenState extends State<HalalWebviewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _hasError = false;
                _loadingProgress = 10;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _loadingProgress = 100;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = error.description;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Database Halal BPJPH',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Cari: "${widget.query}"',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang Halaman',
            onPressed: () {
              setState(() {
                _hasError = false;
                _loadingProgress = 10;
              });
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError)
            WebViewWidget(controller: _controller)
          else
            _buildErrorView(),

          if (_loadingProgress < 100 && !_hasError)
            LinearProgressIndicator(
              value: _loadingProgress / 100.0,
              backgroundColor: Colors.transparent,
              color: AppColors.success,
              minHeight: 3,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 54, color: AppColors.warning),
            const SizedBox(height: 16),
            Text(
              'Gagal Membuka Portal Halal',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Terjadi kendala saat menghubungkan ke database info.halal.go.id. Pastikan koneksi internet stabil.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _loadingProgress = 10;
                });
                _controller.reload();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
