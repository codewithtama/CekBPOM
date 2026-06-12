import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../providers/scan_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_overlay.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final String scanCode;
  final ProductModel? cachedProduct;

  const ResultScreen({
    super.key,
    required this.scanCode,
    this.cachedProduct,
  });

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> with SingleTickerProviderStateMixin {
  final ScreenshotController _screenshotController = ScreenshotController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.cachedProduct != null) {
        _animationController.forward();
      } else {
        ref.read(scanProvider.notifier).checkProduct(widget.scanCode);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _shareResult(ProductModel product) async {
    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final xFile = XFile.fromData(
          imageBytes,
          mimeType: 'image/png',
          name: 'cekbpom_${product.registrationNumber}.png',
        );
        await Share.shareXFiles(
          [xFile],
          text: 'Hasil Verifikasi BPOM:\n'
              'Produk: ${product.name}\n'
              'No. Registrasi: ${product.registrationNumber}\n'
              'Status: ${product.safetyStatus == 'AMAN' ? 'AMAN / TERDAFTAR' : product.safetyStatus}\n'
              'Dicek via Aplikasi CekBPOM.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan hasil: $e')),
        );
      }
    }
  }

  Future<void> _reportProduct(ProductModel product) async {
    final complaintUri = Uri.parse(ApiConstants.bpomComplaintUrl);
    if (await canLaunchUrl(complaintUri)) {
      await launchUrl(complaintUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka link pengaduan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    
    // Determine the product to display (either cached or retrieved from state)
    final product = widget.cachedProduct ?? scanState.result;

    // Trigger animation when online state completes and returns a result
    if (widget.cachedProduct == null && scanState.result != null && !_animationController.isAnimating && _animationController.status == AnimationStatus.dismissed) {
      _animationController.forward();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Pengecekan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ref.read(scanProvider.notifier).clearResult();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Background content
          if (product != null)
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SlideTransition(
                    position: _slideAnimation,
                    child: Screenshot(
                      controller: _screenshotController,
                      child: ProductCard(product: product),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // CTA Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareResult(product),
                          icon: const Icon(Icons.share_rounded),
                          label: const Text('Bagikan Hasil'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _reportProduct(product),
                          icon: const Icon(Icons.report_gmailerrorred_rounded),
                          label: const Text('Laporkan Produk'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

          // Loading indicator overlay
          if (widget.cachedProduct == null && scanState.isLoading)
            const LoadingOverlay(),

          // Error layout
          if (widget.cachedProduct == null && scanState.error != null && !scanState.isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.dangerLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.danger,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Terjadi Kesalahan',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      scanState.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(scanProvider.notifier).checkProduct(widget.scanCode);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Coba Lagi',
                        style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
