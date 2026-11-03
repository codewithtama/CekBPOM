import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../providers/history_provider.dart';
import '../providers/tab_provider.dart';
import 'halal_search_screen.dart';
import 'ocr_scanner_screen.dart';
import 'search_screen.dart';
import 'scanner_screen.dart';
import 'result_screen.dart';
import 'trademark_search_screen.dart';
import '../providers/update_provider.dart';
import '../widgets/update_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _manualInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUpdateSilently();
    });
  }

  Future<void> _checkUpdateSilently() async {
    try {
      final info = await ref.read(updateProvider.notifier).checkForUpdate();
      if (mounted && info != null && info.hasUpdate) {
        UpdateDialog.show(context, info: info);
      }
    } catch (_) {
      // Silent check on launch should never block or disturb user interaction
    }
  }

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }

  void _showManualInputDialog() {
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
                'Masukkan nomor registrasi BPOM (misal: NA18260102268 atau NKIT250001756)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _manualInputController,
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
              onPressed: () {
                _manualInputController.clear();
                Navigator.pop(context);
              },
              child: Text(
                'Batal',
                style: GoogleFonts.lexend(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final code = _manualInputController.text.trim();
                if (code.isNotEmpty) {
                  _manualInputController.clear();
                  Navigator.pop(context);
                  _processManualInput(code);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Periksa',
                style: GoogleFonts.lexend(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _processManualInput(String code) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(scanCode: code),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyList = ref.watch(historyProvider);
    
    // Calculate stats
    int totalScan = historyList.length;
    int safeCount = historyList.where((h) => h.product.safetyStatus == 'AMAN').length;
    int warningCount = historyList.where((h) => h.product.safetyStatus == 'KEDALUWARSA' || h.product.safetyStatus == 'PERLU DICEK').length;
    int dangerCount = historyList.where((h) => h.product.safetyStatus == 'TIDAK TERDAFTAR').length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CekBPOM',
                          style: GoogleFonts.lexend(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const Text(
                          'Verifikasi Keaslian & Keamanan Produk',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar Shortcut (Multi-Mode Search)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cari nama produk, merk, atau pabrik...',
                          style: GoogleFonts.lexend(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Cari',
                          style: GoogleFonts.lexend(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Scan Card Action Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(70),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Scan Barcode Produk',
                      style: GoogleFonts.lexend(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pindai barcode 1D atau 2D QR Code pada kemasan untuk verifikasi langsung database BPOM.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScannerScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_rounded),
                          const SizedBox(width: 8),
                          Text(
                            'Mulai Scan Sekarang',
                            style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dual Action Grid: OCR Text Scan & Manual Input
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OcrScannerScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.document_scanner_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Scan Teks OCR',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _showManualInputDialog,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.keyboard_alt_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Input Manual',
                            style: GoogleFonts.lexend(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Cek Sertifikasi Halal BPJPH Shortcut
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.success.withAlpha(20),
                  border: Border.all(color: AppColors.success.withAlpha(80), width: 1.5),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HalalSearchScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cek Sertifikat Halal BPJPH',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Pencarian sertifikat halal resmi Kemenag RI (In-App)',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Cek Merek & HKI Terdaftar (DJKI Kemenkumham via haki.id) Shortcut
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.primary.withAlpha(16),
                  border: Border.all(color: AppColors.primary.withAlpha(60), width: 1.5),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrademarkSearchScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.app_registration_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cek Legalitas Merek & HKI (DJKI)',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Cek status pendaftaran merek resmi via haki.id',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Statistics Section
              Text(
                'Analisis Pengecekan',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Visual Donut Chart Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border.withAlpha(120), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Donut Chart Render
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CustomPaint(
                            painter: DonutChartPainter(
                              safeCount: safeCount,
                              warningCount: warningCount,
                              dangerCount: dangerCount,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              totalScan.toString(),
                              style: GoogleFonts.lexend(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Total Cek',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    
                    // Legend
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendRow(
                            label: 'Produk Aman',
                            count: safeCount,
                            color: AppColors.success,
                            bgColor: AppColors.successLight,
                          ),
                          const SizedBox(height: 8),
                          _buildLegendRow(
                            label: 'Perlu Cek Ulang',
                            count: warningCount,
                            color: AppColors.warning,
                            bgColor: AppColors.warningLight,
                          ),
                          const SizedBox(height: 8),
                          _buildLegendRow(
                            label: 'Palsu / Tidak Terdaftar',
                            count: dangerCount,
                            color: AppColors.danger,
                            bgColor: AppColors.dangerLight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Banned Substances Kamus Shortcut Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withAlpha(50), width: 1.5),
                  color: AppColors.primaryLight.withAlpha(25),
                ),
                child: InkWell(
                  onTap: () {
                    // Switch to Info Screen Tab
                    ref.read(tabIndexProvider.notifier).state = 2;
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kamus Zat Berbahaya',
                                style: GoogleFonts.lexend(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Edukasi daftar bahan berbahaya kosmetik & makanan.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendRow({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            count.toString(),
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final int safeCount;
  final int warningCount;
  final int dangerCount;

  DonutChartPainter({
    required this.safeCount,
    required this.warningCount,
    required this.dangerCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paintBase = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final total = safeCount + warningCount + dangerCount;
    if (total == 0) {
      paintBase.color = AppColors.border.withAlpha(120);
      canvas.drawCircle(center, radius, paintBase);
      return;
    }

    final double safeSweep = (safeCount / total) * 360;
    final double warningSweep = (warningCount / total) * 360;
    final double dangerSweep = (dangerCount / total) * 360;

    double startAngle = -90.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    if (safeSweep > 0) {
      paintBase.color = AppColors.success;
      canvas.drawArc(rect, _degToRad(startAngle), _degToRad(safeSweep), false, paintBase);
      startAngle += safeSweep;
    }

    if (warningSweep > 0) {
      paintBase.color = AppColors.warning;
      canvas.drawArc(rect, _degToRad(startAngle), _degToRad(warningSweep), false, paintBase);
      startAngle += warningSweep;
    }

    if (dangerSweep > 0) {
      paintBase.color = AppColors.danger;
      canvas.drawArc(rect, _degToRad(startAngle), _degToRad(dangerSweep), false, paintBase);
    }
  }

  double _degToRad(double deg) => deg * (3.141592653589793 / 180.0);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
