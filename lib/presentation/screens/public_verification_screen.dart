import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/public_service_model.dart';
import '../../data/models/public_verification_result.dart';
import '../../data/services/national_verification_service.dart';
import '../providers/history_provider.dart';
import '../widgets/public_verification_result_card.dart';

class PublicVerificationScreen extends ConsumerStatefulWidget {
  final PublicServiceType initialService;

  const PublicVerificationScreen({
    super.key,
    this.initialService = PublicServiceType.alkesPkrt,
  });

  @override
  ConsumerState<PublicVerificationScreen> createState() =>
      _PublicVerificationScreenState();
}

class _PublicVerificationScreenState
    extends ConsumerState<PublicVerificationScreen> {
  late PublicServiceType _currentService;
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final NationalVerificationService _verificationService =
      NationalVerificationService();

  String? _validationError;
  bool _isValidated = false;
  bool _isVerifying = false;
  PublicVerificationResult? _verificationResult;

  @override
  void initState() {
    super.initState();
    _currentService = widget.initialService;
  }

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onServiceChanged(PublicServiceType type) {
    if (_currentService == type) return;
    setState(() {
      _currentService = type;
      _queryController.clear();
      _validationError = null;
      _isValidated = false;
      _verificationResult = null;
      _isVerifying = false;
    });
  }

  void _useExample(String example) {
    setState(() {
      _queryController.text = example;
      _validateInput();
    });
    // Auto trigger in-app verification for quick example
    final info = PublicServiceInfo.getByType(_currentService);
    _launchVerification(info);
  }

  void _validateInput() {
    final info = PublicServiceInfo.getByType(_currentService);
    final error = info.validate(_queryController.text);
    setState(() {
      _validationError = error;
      _isValidated = true;
    });
  }

  void _resetSearch() {
    setState(() {
      _queryController.clear();
      _validationError = null;
      _isValidated = false;
      _verificationResult = null;
      _isVerifying = false;
    });
  }

  Future<void> _launchVerification(PublicServiceInfo info) async {
    final error = info.validate(_queryController.text);
    setState(() {
      _validationError = error;
      _isValidated = true;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isVerifying = true;
      _verificationResult = null;
    });

    try {
      final result = await _verificationService.verify(
        type: _currentService,
        query: _queryController.text,
      );

      if (mounted) {
        // Save verified item into scan history
        ref.read(historyProvider.notifier).addHistory(result.toProductModel());

        setState(() {
          _verificationResult = result;
          _isVerifying = false;
        });

        // Smooth scroll to the result card
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              320.0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kendala saat verifikasi in-app: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _queryController.text = data.text!.trim();
        _validateInput();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = PublicServiceInfo.getByType(_currentService);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Layanan Nasional'),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Horizontal Service Selector
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: AppColors.surface,
              child: SizedBox(
                height: 44,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: PublicServiceInfo.allServices.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = PublicServiceInfo.allServices[index];
                    final isSelected = item.type == _currentService;

                    return ChoiceChip(
                      selected: isSelected,
                      avatar: Icon(
                        item.icon,
                        size: 16,
                        color: isSelected ? Colors.white : item.themeColor,
                      ),
                      label: Text(item.shortTitle),
                      labelStyle: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      selectedColor: item.themeColor,
                      backgroundColor: item.themeColor.withValues(alpha: 0.08),
                      side: BorderSide(
                        color: isSelected
                            ? item.themeColor
                            : item.themeColor.withValues(alpha: 0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onSelected: (_) => _onServiceChanged(item.type),
                    );
                  },
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.border),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Service Banner Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: info.themeColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: info.themeColor.withValues(alpha: 0.25),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: info.themeColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(info.icon,
                                  color: info.themeColor, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    info.title,
                                    style: GoogleFonts.lexend(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    info.institution,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: info.themeColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          info.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Search & Input Section
                  Text(
                    'Formulir Penelusuran In-App',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info.codeFormatHint,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _queryController,
                    keyboardType: info.keyboardType,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (val) {
                      if (_isValidated) {
                        _validateInput();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: info.exampleCode,
                      prefixIcon: Icon(info.icon, color: info.themeColor),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_queryController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _queryController.clear();
                                setState(() {
                                  _validationError = null;
                                  _isValidated = false;
                                });
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.content_paste_rounded),
                            tooltip: 'Tempel dari Clipboard',
                            onPressed: _pasteFromClipboard,
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                            color: AppColors.border.withValues(alpha: 0.8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            BorderSide(color: info.themeColor, width: 2),
                      ),
                      errorText: _isValidated ? _validationError : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick Example Action
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => _useExample(info.exampleCode),
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        child: Text(
                          'Contoh: ${info.exampleCode} (klik untuk verifikasi langsung)',
                          style: TextStyle(
                            fontSize: 12,
                            color: info.themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // In-App Verification Trigger Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isVerifying
                          ? null
                          : () => _launchVerification(info),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: info.themeColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.verified_user_rounded),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isVerifying
                                    ? 'Memverifikasi Data...'
                                    : 'Verifikasi di Aplikasi',
                                style: GoogleFonts.lexend(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Loading State View
                  if (_isVerifying) ...[
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            color: info.themeColor,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Menghubungkan ke Sistem ${info.institution}...',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Memeriksa nomor pendaftaran, standar mutu, dan validitas hukum.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // 5. In-App Result Card View
                  if (_verificationResult != null && !_isVerifying) ...[
                    const SizedBox(height: 28),
                    PublicVerificationResultCard(
                      result: _verificationResult!,
                      onReset: _resetSearch,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _resetSearch,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, size: 18),
                            SizedBox(width: 6),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('Verifikasi Nomor / Perangkat Lain'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // 6. Panduan Format Khusus Per Lembaga
                  _buildServiceGuideSection(info),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGuideSection(PublicServiceInfo info) {
    switch (info.type) {
      case PublicServiceType.alkesPkrt:
        return _buildGuideCard(
          title: 'Arti Kode Izin Edar Kemenkes RI',
          items: const [
            'AKL: Alat Kesehatan Luar Negeri (Impor)',
            'AKD: Alat Kesehatan Dalam Negeri (Produksi Lokal)',
            'PKL: Perbekalan Kesehatan Rumah Tangga Luar Negeri (Impor)',
            'PKD: Perbekalan Kesehatan Rumah Tangga Dalam Negeri (Lokal)',
          ],
          note:
              'Contoh PKRT meliputi hand sanitizer, sabun antiseptik, pembersih lantai, popok bayi, dan detergen.',
        );

      case PublicServiceType.imei:
        return _buildGuideCard(
          title: 'Petunjuk Nomor IMEI Ponsel',
          items: const [
            'Nomor IMEI terdiri dari 15 digit unik untuk setiap slot kartu SIM.',
            'Cek IMEI ponsel Anda dengan menekan *#06# pada papan panggilan.',
            'Digit ke-15 merupakan digit verifikasi matematis (Algoritma Luhn).',
          ],
          note:
              'Ponsel yang dibeli di Indonesia wajib terdaftar di Kemenperin, sedangkan ponsel bawaan luar negeri diverifikasi via Bea Cukai.',
        );

      case PublicServiceType.halal:
        return _buildGuideCard(
          title: 'Format Sertifikat Halal BPJPH',
          items: const [
            'Nomor sertifikat halal diawali dengan kode negara ID (misal: ID0011000001234).',
            'Pencarian dapat menggunakan nama merek produk secara langsung.',
            'Wajib mencantumkan logo Halal Indonesia terbaru berwarna ungu berbentuk gunungan wayang.',
          ],
          note:
              'Seluruh produk pangan dan barang gunaan wajib bersertifikat halal sesuai regulasi UU JPH.',
        );

      case PublicServiceType.sni:
        return _buildGuideCard(
          title: 'Ketentuan Tanda Standar SNI',
          items: const [
            'Format kode: SNI [Nomor Standar]:[Tahun Terbit].',
            'Sertifikasi menjamin aspek keamanan kelistrikan, mekanik, dan kimia.',
            'Wajib diterapkan pada helm, mainan anak, kabel listrik, dan air mineral.',
          ],
          note:
              'Gunakan portal Bang Beni BSN untuk mencocokkan nomor sertifikat SPPT-SNI produsen.',
        );

      case PublicServiceType.pdki:
        return _buildGuideCard(
          title: 'Pangkalan Data Kekayaan Intelektual (DJKI)',
          items: const [
            'IDM: Nomor Pendaftaran Merek Dagang',
            'IDS: Nomor Pendaftaran Desain Industri',
            'IDP: Nomor Pendaftaran Paten Teknologi',
          ],
          note:
              'Penelusuran memastikan merek produk tidak menjiplak atau melanggar hak cipta pihak lain.',
        );

      case PublicServiceType.sdppi:
        return _buildGuideCard(
          title: 'Sertifikasi Perangkat Komdigi (SDPPI)',
          items: const [
            'Wajib untuk semua gadget yang memancarkan sinyal radio (Wi-Fi, Bluetooth, 4G/5G).',
            'Format label: [Nomor Sertifikat]/SDPPI/[Tahun] dan [PLG ID].',
            'Perangkat tanpa sertifikat SDPPI berisiko mengganggu spektrum frekuensi publik.',
          ],
          note:
              'Label SDPPI biasanya ditempel pada stiker bodi atau e-label menu perangkat.',
        );

      case PublicServiceType.kfa:
        return _buildGuideCard(
          title: 'Kamus Farmasi & Alat Kesehatan (KFA SatuSehat)',
          items: const [
            'Standardisasi kodefikasi master data obat nasional berstandar FHIR.',
            'Memetakan nama dagang obat ke zat aktif generik dan kode ATC.',
            'Terhubung langsung dengan rekam medis elektronik SatuSehat Kemenkes.',
          ],
          note:
              'Bermanfaat untuk memeriksa kandungan generik dan indikasi medis resmi.',
        );
    }
  }

  Widget _buildGuideCard({
    required String title,
    required List<String> items,
    required String note,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lexend(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Catatan: $note',
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
