import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/halal_service.dart';

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
  late final TextEditingController _searchController;
  int _loadingProgress = 0;
  bool _hasError = false;
  String _errorMessage = '';
  String _currentUrl = '';

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _searchController = TextEditingController(text: widget.query);
    _initWebViewController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 14; Mobile; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      )
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
                _loadingProgress = 15;
                _currentUrl = url;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _loadingProgress = 100;
                _currentUrl = url;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only trigger full-screen error if the main webpage navigation fails
            if (error.isForMainFrame == true && mounted) {
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

  void _performSearch(String query) {
    FocusScope.of(context).unfocus();
    final url = HalalService.buildVerificationUrl(query);
    setState(() {
      _hasError = false;
      _loadingProgress = 15;
      _currentUrl = url;
    });
    _controller.loadRequest(Uri.parse(url));
  }

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.parse(_currentUrl.isNotEmpty ? _currentUrl : ApiConstants.bpjphHalalSearchUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pencarian Sertifikat Halal',
          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
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
                _loadingProgress = 15;
              });
              _controller.reload();
            },
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            tooltip: 'Buka di Browser Luar',
            onPressed: _openInExternalBrowser,
          ),
        ],
      ),
      body: Column(
        children: [
          // In-App Search Bar for BPJPH Halal Database
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _performSearch,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari produk, merk, atau produsen...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.success, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _performSearch(_searchController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cari'),
                ),
              ],
            ),
          ),

          // WebView content
          Expanded(
            child: Stack(
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
              'Gagal Membuka Portal Halal BPJPH',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Terjadi kendala saat menghubungkan ke database bpjph.halal.go.id. Pastikan koneksi internet stabil.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _openInExternalBrowser,
                  icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                  label: const Text('Buka di Browser'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                      _loadingProgress = 15;
                    });
                    _controller.reload();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
