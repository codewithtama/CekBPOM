import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ingredients_analyzer.dart';
import 'result_screen.dart';

class OcrScannerScreen extends StatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  State<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends State<OcrScannerScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  late final TextRecognizer _textRecognizer;
  late final TabController _tabController;

  File? _selectedImage;
  bool _isProcessing = false;
  String _rawRecognizedText = '';
  List<String> _detectedBpomCodes = [];
  IngredientAnalysisResult? _ingredientsResult;
  final TextEditingController _ingredientsController = TextEditingController();

  static final RegExp _bpomPattern = RegExp(
    r'\b(?:POM\s*)?(NA|NB|NC|ND|NE|NKIT|MD|ML|TR|TI|TL|SD|SI|SL|QD|QI|QL|DKL|DKI|DBL|DBI|DTL|DTI|GKL|GKI)[\s.-]*([0-9]{7,16}[A-Z0-9]*)\b',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _textRecognizer.close();
    _tabController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  Future<void> _pickAndProcessImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _isProcessing = true;
        _detectedBpomCodes = [];
        _ingredientsResult = null;
      });

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      _rawRecognizedText = recognizedText.text;

      // Extract BPOM codes
      final Set<String> codes = {};
      for (final match in _bpomPattern.allMatches(_rawRecognizedText)) {
        final prefix = match.group(1)?.toUpperCase() ?? '';
        final digits = (match.group(2) ?? '').replaceAll(RegExp(r'[\s.-]'), '').toUpperCase();
        if (prefix.isNotEmpty && digits.isNotEmpty) {
          codes.add('$prefix$digits');
        }
      }

      // Extract Ingredients block
      String ingredientsText = _extractIngredientsBlock(_rawRecognizedText);
      if (ingredientsText.isEmpty && _rawRecognizedText.trim().isNotEmpty) {
        ingredientsText = _rawRecognizedText;
      }
      _ingredientsController.text = ingredientsText;

      final analysis = IngredientsAnalyzer.analyzeDetailed(ingredientsText);

      setState(() {
        _isProcessing = false;
        _detectedBpomCodes = codes.toList();
        _ingredientsResult = analysis;
        if (_detectedBpomCodes.isEmpty && ingredientsText.isNotEmpty) {
          _tabController.index = 1;
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses gambar: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  String _extractIngredientsBlock(String fullText) {
    final lower = fullText.toLowerCase();
    final markers = ['komposisi:', 'komposisi', 'ingredients:', 'ingredients', 'kandungan:'];

    for (final marker in markers) {
      final idx = lower.indexOf(marker);
      if (idx != -1) {
        final start = idx + marker.length;
        // Take next 500 characters or until next section
        final snippet = fullText.substring(start).trim();
        final endMarkers = ['diproduksi oleh', 'manufactured by', 'batch no', 'exp date', 'netto', 'isi bersih', 'no. reg'];
        int endIdx = snippet.length;
        for (final em in endMarkers) {
          final found = snippet.toLowerCase().indexOf(em);
          if (found != -1 && found < endIdx) {
            endIdx = found;
          }
        }
        return snippet.substring(0, endIdx).trim();
      }
    }
    return '';
  }

  void _reanalyzeIngredients() {
    final text = _ingredientsController.text.trim();
    setState(() {
      _ingredientsResult = IngredientsAnalyzer.analyzeDetailed(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan Teks Kemasan (OCR)',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              icon: const Icon(Icons.qr_code_2_rounded, size: 20),
              text: 'Nomor BPOM (${_detectedBpomCodes.length})',
            ),
            const Tab(
              icon: Icon(Icons.science_outlined, size: 20),
              text: 'Analisis Komposisi',
            ),
          ],
        ),
      ),
      body: _selectedImage == null
          ? _buildInitialPlaceholder()
          : Column(
              children: [
                // Image preview strip
                _buildImagePreviewBar(),

                if (_isProcessing)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Membaca teks dari kemasan dengan OCR...'),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBpomTab(),
                        _buildIngredientsTab(),
                      ],
                    ),
                  ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickAndProcessImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded, size: 18),
                label: const Text('Dari Galeri'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickAndProcessImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: const Text('Foto Kemasan'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.document_scanner_rounded, size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'Pindai Teks dari Kemasan',
              style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Arahkan kamera atau pilih foto kemasan produk untuk otomatis membaca kode izin BPOM atau menganalisis seluruh daftar komposisi kimia secara instan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _pickAndProcessImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt_rounded),
              label: const Text('Buka Kamera Sekarang'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviewBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.background,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_selectedImage!, width: 44, height: 44, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foto Kemasan Dipindai',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  _rawRecognizedText.isNotEmpty
                      ? '${_rawRecognizedText.split(RegExp(r'\s+')).length} kata terbaca'
                      : 'Memproses...',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'Ganti Foto',
            onPressed: () => _pickAndProcessImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget _buildBpomTab() {
    if (_detectedBpomCodes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.find_in_page_outlined, size: 54, color: AppColors.warning),
              const SizedBox(height: 14),
              Text(
                'Tidak Ditemukan Nomor BPOM',
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pastikan pencahayaan cukup dan nomor izin (misal: NA..., MD...) terlihat jelas tanpa blur, atau cek tab Analisis Komposisi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _detectedBpomCodes.length,
      itemBuilder: (context, index) {
        final code = _detectedBpomCodes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.verified_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nomor Terdeteksi:',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      Text(
                        code,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(scanCode: code),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cek BPOM'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientsTab() {
    final result = _ingredientsResult;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Edit/review text box
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Teks Komposisi Terbaca:',
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              TextButton.icon(
                onPressed: _reanalyzeIngredients,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Analisis Ulang'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _ingredientsController,
            maxLines: 4,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Teks bahan kandungan yang terbaca oleh kamera...',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (result != null) ...[
            Text(
              'Hasil Analisis Keamanan Kulit:',
              style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // 1. Toxin check card
            _buildSafetyIndicatorCard(
              title: 'Zat Berbahaya & Ilegal',
              isSafe: result.isSafeFromToxins,
              safeText: 'Tidak terdeteksi bahan terlarang (Merkuri, Hidrokuinon, BKO, EG)',
              warnings: result.dangerousIngredients,
              alertColor: AppColors.danger,
            ),
            const SizedBox(height: 10),

            // 2. Pregnancy check card
            _buildSafetyIndicatorCard(
              title: 'Keamanan Ibu Hamil & Menyusui',
              isSafe: result.isPregnancySafe,
              safeText: 'Aman untuk Bumil & Busui (Bebas Retinoid & BHA dosis tinggi)',
              warnings: result.pregnancyWarnings,
              alertColor: Colors.purple,
            ),
            const SizedBox(height: 10),

            // 3. Fungal Acne card
            _buildSafetyIndicatorCard(
              title: 'Pemicu Fungal Acne (Malassezia)',
              isSafe: result.isFungalAcneSafe,
              safeText: 'Fungal Acne Safe (Bebas Polysorbate & asam lemak jenuh berlebih)',
              warnings: result.fungalAcneTriggers,
              alertColor: Colors.orange.shade800,
            ),
            const SizedBox(height: 10),

            // 4. Sensitivity & Allergens
            _buildSafetyIndicatorCard(
              title: 'Kulit Sensitif & Alergen',
              isSafe: result.isSensitiveSkinSafe,
              safeText: 'Minim Alergen (Bebas pewangi sintetis & alkohol mengeringkan)',
              warnings: result.allergenAndSensitivities,
              alertColor: Colors.blue.shade800,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSafetyIndicatorCard({
    required String title,
    required bool isSafe,
    required String safeText,
    required List<IngredientWarning> warnings,
    required Color alertColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSafe ? AppColors.success.withAlpha(20) : alertColor.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSafe ? AppColors.success.withAlpha(60) : alertColor.withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isSafe ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: isSafe ? AppColors.success : alertColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSafe ? AppColors.success : alertColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isSafe ? AppColors.success : alertColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isSafe ? 'AMAN' : 'PERINGATAN (${warnings.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isSafe)
            Text(
              safeText,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            )
          else
            ...warnings.map((w) {
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ${w.chemicalName}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: alertColor,
                      ),
                    ),
                    Text(
                      w.description,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

