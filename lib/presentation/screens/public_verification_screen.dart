import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/public_service_model.dart';

class PublicVerificationScreen extends StatefulWidget {
  final PublicServiceType initialService;

  const PublicVerificationScreen({
    super.key,
    this.initialService = PublicServiceType.alkesPkrt,
  });

  @override
  State<PublicVerificationScreen> createState() => _PublicVerificationScreenState();
}

class _PublicVerificationScreenState extends State<PublicVerificationScreen> {
  late PublicServiceType _currentService;
  final TextEditingController _queryController = TextEditingController();
  String? _validationError;
  bool _isValidated = false;

  @override
  void initState() {
    super.initState();
    _currentService = widget.initialService;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _onServiceChanged(PublicServiceType type) {
    if (_currentService == type) return;
    setState(() {
      _currentService = type;
      _queryController.clear();
      _validationError = null;
      _isValidated = false;
    });
  }

  void _useExample(String example) {
    setState(() {
      _queryController.text = example;
      _validateInput();
    });
  }

  void _validateInput() {
    final info = PublicServiceInfo.getByType(_currentService);
    final error = info.validate(_queryController.text);
    setState(() {
      _validationError = error;
      _isValidated = true;
    });
  }

  Future<void> _openOfficialPortal(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Tidak dapat membuka browser.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka portal: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
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

    final targetUrl = info.buildVerificationUrl(_queryController.text);
    await _openOfficialPortal(targetUrl);
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
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
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
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
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      selectedColor: item.themeColor,
                      backgroundColor: item.themeColor.withValues(alpha: 0.08),
                      side: BorderSide(
                        color: isSelected ? item.themeColor : item.themeColor.withValues(alpha: 0.2),
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
                              child: Icon(info.icon, color: info.themeColor, size: 24),
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
                        const SizedBox(height: 14),
                        InkWell(
                          onTap: () => _openOfficialPortal(info.officialPortalUrl),
                          borderRadius: BorderRadius.circular(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Kunjungi portal: ${info.officialPortalUrl}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: info.themeColor,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.open_in_new_rounded, size: 12, color: info.themeColor),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Search & Input Section
                  Text(
                    'Formulir Penelusuran',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info.codeFormatHint,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
                        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: info.themeColor, width: 2),
                      ),
                      errorText: _isValidated ? _validationError : null,
                      filled: true,
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Text(
                          'Contoh: ${info.exampleCode} (klik untuk isi)',
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

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchVerification(info),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: info.themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.search_rounded),
                      label: Text(
                        'Verifikasi di Basis Data Resmi',
                        style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. Panduan Format Khusus Per Lembaga
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
          note: 'Label SDPPI biasanya ditempel pada stiker bodi atau e-label menu perangkat.',
        );

      case PublicServiceType.kfa:
        return _buildGuideCard(
          title: 'Kamus Farmasi & Alat Kesehatan (KFA SatuSehat)',
          items: const [
            'Standardisasi kodefikasi master data obat nasional berstandar FHIR.',
            'Memetakan nama dagang obat ke zat aktif generik dan kode ATC.',
            'Terhubung langsung dengan rekam medis elektronik SatuSehat Kemenkes.',
          ],
          note: 'Bermanfaat untuk memeriksa kandungan generik dan indikasi medis resmi.',
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
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold),
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
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
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
