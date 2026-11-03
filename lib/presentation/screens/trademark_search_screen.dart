import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/trademark_model.dart';
import '../providers/trademark_provider.dart';

/// Screen providing lookup for registered trademarks (HKI / Merek Dagang)
/// from the DJKI Kemenkumham database via the haki.id API.
class TrademarkSearchScreen extends ConsumerStatefulWidget {
  const TrademarkSearchScreen({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  ConsumerState<TrademarkSearchScreen> createState() => _TrademarkSearchScreenState();
}

class _TrademarkSearchScreenState extends ConsumerState<TrademarkSearchScreen> {
  late final TextEditingController _controller;

  static const List<String> _popularQueries = [
    'Gudang Garam',
    'Wardah',
    'Indomie',
    'Kahf',
    'Somethinc',
    'Avoskin',
    'Scarlett',
    'Kopiko',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(trademarkProvider.notifier).search(widget.initialQuery!);
      });
    }
  }

  void _submitSearch([String? customQuery]) {
    final q = customQuery ?? _controller.text;
    if (customQuery != null) {
      _controller.text = customQuery;
    }
    FocusScope.of(context).unfocus();
    ref.read(trademarkProvider.notifier).search(q);
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke papan klip.'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _openPdkiLink(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan rincian PDKI tidak tersedia.')),
      );
      return;
    }

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
            content: Text('Gagal membuka halaman PDKI: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _shareTrademark(TrademarkModel item) {
    final text = 'Informasi Hak Merek Dagang (HKI) Resmi Terdaftar:\n'
        '• Merek: ${item.mark}\n'
        '• Pemilik/Pemohon: ${item.applicant}\n'
        '• No. Pendaftaran: ${item.registrationNumber}\n'
        '• Status: ${item.status}\n'
        '• Klasifikasi: ${item.classDescription}\n'
        '• Tanggal Daftar: ${item.registrationDate}\n'
        '• Perlindungan s/d: ${item.expirationDate}\n\n'
        'Diverifikasi via Aplikasi CekBPOM (Sumber: DJKI Kemenkumham RI).';
    Share.share(text, subject: 'Hak Merek HKI: ${item.mark}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trademarkProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cek Merek & HKI Terdaftar',
              style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Pangkalan Data Kekayaan Intelektual (DJKI Kemenkumham)',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchHeader(state),
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(TrademarkState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: _submitSearch,
            decoration: InputDecoration(
              hintText: 'Cari nama merek (misal: Wardah, Gudang Garam)',
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _controller.clear();
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(TrademarkState state) {
    switch (state.status) {
      case TrademarkStatus.initial:
        return _buildInitialState();
      case TrademarkStatus.loading:
        return _buildLoadingState();
      case TrademarkStatus.empty:
        return _buildEmptyState(state.query);
      case TrademarkStatus.error:
        return _buildErrorState(state.errorMessage);
      case TrademarkStatus.success:
        return _buildResultsList(state);
    }
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1D4ED8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.branding_watermark_rounded,
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
                        'Verifikasi Legalitas Merek (HKI)',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Cek status kepemilikan hak merek dagang, nomor pendaftaran resmi (IDM), kelas merek, dan masa berlaku proteksi hukum dari Direktorat Jenderal Kekayaan Intelektual (DJKI).',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Pencarian Merek Populer',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularQueries.map((mark) {
              return ActionChip(
                label: Text(mark),
                labelStyle: GoogleFonts.lexend(fontSize: 12),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                ),
                onPressed: () => _submitSearch(mark),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFEFF6FF),
          child: Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Sedang memindai jutaan data merek di pangkalan data DJKI...',
                  style: GoogleFonts.lexend(fontSize: 12, color: const Color(0xFF1E3A8A)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (context, index) => Container(
                height: 200,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList(TrademarkState state) {
    return Column(
      children: [
        // Counter banner
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ditemukan ${state.totalCount} merek terdaftar',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1D4ED8),
                ),
              ),
              Text(
                'Kata kunci: "${state.query}"',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // List of results
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final item = state.results[index];
              return _buildTrademarkCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrademarkCard(TrademarkModel item) {
    final isRegistered = item.isRegistered;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status Badge & Share Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isRegistered ? AppColors.successLight : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isRegistered
                          ? AppColors.success.withValues(alpha: 0.3)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isRegistered ? Icons.verified_rounded : Icons.info_outline_rounded,
                        color: isRegistered ? AppColors.success : const Color(0xFFD97706),
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.status.toUpperCase(),
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isRegistered ? AppColors.success : const Color(0xFFB45309),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.pdkiLink != null && item.pdkiLink!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
                        tooltip: 'Lihat di Portal PDKI Resmi',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(right: 8),
                        onPressed: () => _openPdkiLink(item.pdkiLink),
                      ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textSecondary),
                      tooltip: 'Bagikan Info HKI',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () => _shareTrademark(item),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Logo & Mark Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Image or Fallback Box
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: AppColors.background,
                    child: item.logoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: item.logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.branding_watermark_outlined,
                              color: AppColors.textSecondary,
                              size: 26,
                            ),
                          )
                        : const Icon(
                            Icons.branding_watermark_outlined,
                            color: AppColors.textSecondary,
                            size: 26,
                          ),
                  ),
                ),
                const SizedBox(width: 14),

                // Mark Name and Class
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.mark,
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Text(
                          item.classDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Pemilik / Pemohon
            _buildDetailRow(
              icon: Icons.business_rounded,
              label: 'Pemohon / Pemilik Merek',
              value: item.applicant,
            ),
            const SizedBox(height: 8),

            // Nomor Pendaftaran (IDM...)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.confirmation_number_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nomor Pendaftaran Merek',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 1),
                      InkWell(
                        onTap: item.registrationNumber != '-'
                            ? () => _copyToClipboard(item.registrationNumber, 'Nomor pendaftaran')
                            : null,
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.registrationNumber,
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (item.registrationNumber != '-') ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.copy_rounded, size: 13, color: AppColors.primary),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nomor Permohonan & Masa Berlaku
            Row(
              children: [
                Expanded(
                  child: _buildDetailRow(
                    icon: Icons.description_outlined,
                    label: 'No. Permohonan',
                    value: item.fillingNumber,
                  ),
                ),
                Expanded(
                  child: _buildDetailRow(
                    icon: Icons.event_available_outlined,
                    label: 'Proteksi s/d',
                    value: item.expirationDate,
                  ),
                ),
              ],
            ),

            // Goods & Services expandable section
            if (item.goodsServices.isNotEmpty) ...[
              const SizedBox(height: 10),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(top: 4, bottom: 8),
                  title: Text(
                    'Uraian Barang & Jasa Terlindungi',
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        item.goodsServices,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.orange.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Merek Tidak Ditemukan',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Tidak ditemukan merek terdaftar untuk kata kunci "$query" di pangkalan data DJKI Kemenkumham. Coba cari dengan nama merek pokok atau nama PT pemohon.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.danger),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data HKI',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message ?? 'Terjadi kendala jaringan saat memuat data merek.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _submitSearch(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
