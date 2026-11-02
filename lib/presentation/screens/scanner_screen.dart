import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../providers/settings_provider.dart';
import 'ocr_scanner_screen.dart';
import 'result_screen.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _isScanCompleted = false;
  late AnimationController _scannerAnimationController;
  late Animation<double> _scannerLineAnimation;
  double _currentZoom = 0.0;

  void _toggleZoom() {
    setState(() {
      if (_currentZoom == 0.0) {
        _currentZoom = 0.5; // 2x zoom
      } else if (_currentZoom == 0.5) {
        _currentZoom = 1.0; // 3x max zoom
      } else {
        _currentZoom = 0.0; // reset
      }
      _cameraController.setZoomScale(_currentZoom);
    });
  }

  String _getZoomText() {
    if (_currentZoom == 0.0) return '1.0x';
    if (_currentZoom == 0.5) return '2.0x';
    return '3.0x';
  }

  @override
  void initState() {
    super.initState();
    _scannerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scannerLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scannerAnimationController, curve: Curves.easeInOut),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scannerAnimationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _scannerAnimationController.forward();
        }
      });
    _scannerAnimationController.forward();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _scannerAnimationController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_isScanCompleted) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawCode = barcodes.first.rawValue;
      if (rawCode != null && rawCode.isNotEmpty) {
        setState(() {
          _isScanCompleted = true;
        });

        // Trigger user feedback based on settings
        final settings = ref.read(settingsProvider);
        if (settings.enableVibration) {
          HapticFeedback.vibrate();
        }
        if (settings.enableSound) {
          SystemSound.play(SystemSoundType.click);
        }

        // Auto-copy to clipboard
        Clipboard.setData(ClipboardData(text: rawCode));

        // Navigate directly to result screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(scanCode: rawCode),
          ),
        );
      }
    }
  }

  Future<void> _scanImageFromGallery() async {
    if (_isScanCompleted) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Text('Menganalisis barcode gambar...'),
                ],
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }

        final bool isSuccess = await _cameraController.analyzeImage(image.path);

        if (!isSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak menemukan barcode pada gambar. Coba gunakan tombol "Scan Teks OCR".'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menganalisis gambar: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Input Manual',
            style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan nomor registrasi BPOM yang tertera di kemasan produk:',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'NA18260102268',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.lexend(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final code = controller.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(scanCode: code),
                    ),
                  );
                }
              },
              child: Text(
                'Periksa',
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera View
          MobileScanner(
            controller: _cameraController,
            onDetect: _onBarcodeDetected,
          ),

          // 2. Camera Overlay (Darkened outer borders)
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha(130),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  color: Colors.transparent,
                ),
                Center(
                  child: Container(
                    width: scanAreaSize,
                    height: scanAreaSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Scan Target Border Lines
          Center(
            child: SizedBox(
              width: scanAreaSize,
              height: scanAreaSize,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: _isScanCompleted ? AppColors.success : Colors.white, width: 4),
                          left: BorderSide(color: _isScanCompleted ? AppColors.success : Colors.white, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: _isScanCompleted ? AppColors.success : Colors.white, width: 4),
                          right: BorderSide(color: _isScanCompleted ? AppColors.success : Colors.white, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(24)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: _isScanCompleted ? AppColors.success : Colors.white, width: 4),
                          left: BorderSide(color: _isScanCompleted ? AppColors.success : Colors.white, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(24)),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: _isScanCompleted ? AppColors.success : Colors.white, width: 4),
                          right: BorderSide(color: _isScanCompleted ? AppColors.success : Colors.white, width: 4),
                        ),
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(24)),
                      ),
                    ),
                  ),

                  // Animated Red/Green Laser Line
                  AnimatedBuilder(
                    animation: _scannerLineAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: _scannerLineAnimation.value * (scanAreaSize - 4),
                        left: 8,
                        right: 8,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (_isScanCompleted ? AppColors.success : AppColors.danger).withAlpha(0),
                                (_isScanCompleted ? AppColors.success : AppColors.danger),
                                (_isScanCompleted ? AppColors.success : AppColors.danger).withAlpha(0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isScanCompleted ? AppColors.success : AppColors.danger).withAlpha(150),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Zoom Multiplier Button
          Positioned(
            right: 24,
            top: MediaQuery.of(context).size.height * 0.45,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleZoom,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 20),
                      const SizedBox(height: 2),
                      Text(
                        _getZoomText(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Instructions Text (Top)
          Positioned(
            top: 64,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Pindai Barcode',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.document_scanner_rounded, color: Colors.white),
                          tooltip: 'Scan Teks OCR',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const OcrScannerScreen()),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                          tooltip: 'Pilih dari Galeri',
                          onPressed: _scanImageFromGallery,
                        ),
                        IconButton(
                          icon: ValueListenableBuilder<TorchState>(
                            valueListenable: _cameraController.torchState,
                            builder: (context, state, child) {
                              switch (state) {
                                case TorchState.off:
                                  return const Icon(Icons.flash_off_rounded, color: Colors.white);
                                case TorchState.on:
                                  return const Icon(Icons.flash_on_rounded, color: AppColors.warning);
                              }
                            },
                          ),
                          onPressed: () => _cameraController.toggleTorch(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                const Text(
                  'Arahkan kamera ke barcode produk secara vertikal atau horizontal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 5. Dual Action Buttons (Bottom)
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OcrScannerScreen()),
                      );
                    },
                    icon: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Scan Teks OCR',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showManualInputDialog,
                    icon: const Icon(Icons.keyboard_alt_rounded, size: 18),
                    label: const Text(
                      'Input Manual',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
