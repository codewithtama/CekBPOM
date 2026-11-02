import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/halal_product_model.dart';
import '../../data/services/halal_service.dart';
import '../providers/halal_search_provider.dart';

/// Screen providing 100% native in-app search against official BPJPH Halal certificate database.
class HalalSearchScreen extends ConsumerStatefulWidget {
  const HalalSearchScreen({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  ConsumerState<HalalSearchScreen> createState() => _HalalSearchScreenState();
}

class _HalalSearchScreenState extends ConsumerState<HalalSearchScreen> {
  late final TextEditingController _controller;
  late final ScrollController _scrollController;

  static const List<String> _popularQueries = [
    'Wardah',
    'Indomie',
    'Kahf',
    'Somethinc',
    'Ultra Milk',
    'Avoskin',
    'Emina',
    'Garnier',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _scrollController = ScrollController()..addListener(_onScroll);

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(halalSearchProvider.notifier).search(query: widget.initialQuery!);
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      ref.read(halalSearchProvider.notifier).loadNextPage();
    }
  }

  void _submitSearch([String? customQuery]) {
    final q = customQuery ?? _controller.text;
    if (customQuery != null) {
      _controller.text = customQuery;
    }
    FocusScope.of(context).unfocus();
    ref.read(halalSearchProvider.notifier).search(query: q);
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

  void _shareCertificate(HalalProductModel item) {
    final text = 'Sertifikasi Halal Resmi BPJPH Kemenag RI:\n'
        '• Produk: ${item.productName}\n'
        '• Merek: ${item.brandName}\n'
        '• Produsen: ${item.producerName}\n'
        '• No. Sertifikat: ${item.certificateNumber}\n'
        '• Tanggal Terbit: ${item.issueDate}\n'
        '• Pabrik: ${item.factoryLocation}\n\n'
        'Diverifikasi via Aplikasi CekBPOM.';
    Share.share(text, subject: 'Sertifikat Halal: ${item.productName}');
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(halalSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cek Sertifikasi Halal',
              style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Pangkalan Data Resmi BPJPH Kemenag RI',
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

  Widget _buildSearchHeader(HalalSearchState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Search Box
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: _submitSearch,
            decoration: InputDecoration(
              hintText: _getHintText(state.searchType),
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
          const SizedBox(height: 10),

          // Filter Segment Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'Nama Produk',
                  icon: Icons.local_offer_outlined,
                  type: HalalSearchType.product,
                  isSelected: state.searchType == HalalSearchType.product,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Produsen / PT',
                  icon: Icons.business_rounded,
                  type: HalalSearchType.producer,
                  isSelected: state.searchType == HalalSearchType.producer,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'No. Sertifikat',
                  icon: Icons.verified_outlined,
                  type: HalalSearchType.certificate,
                  isSelected: state.searchType == HalalSearchType.certificate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required HalalSearchType type,
    required bool isSelected,
  }) {
    return ChoiceChip(
      showCheckmark: false,
      selected: isSelected,
      onSelected: (_) {
        ref.read(halalSearchProvider.notifier).setFilterType(type);
      },
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      label: Text(
        label,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  String _getHintText(HalalSearchType type) {
    switch (type) {
      case HalalSearchType.product:
        return 'Cari nama produk (misal: Wardah, Indomie)';
      case HalalSearchType.producer:
        return 'Cari nama pabrik / PT (misal: Paragon, Indofood)';
      case HalalSearchType.certificate:
        return 'Cari nomor sertifikat (misal: ID0041...)';
    }
  }

  Widget _buildBody(HalalSearchState state) {
    switch (state.status) {
      case HalalSearchStatus.initial:
        return _buildInitialState();
      case HalalSearchStatus.loading:
        return _buildLoadingShimmer();
      case HalalSearchStatus.empty:
        return _buildEmptyState(state.query);
      case HalalSearchStatus.error:
        return _buildErrorState(state.errorMessage);
      case HalalSearchStatus.success:
      case HalalSearchStatus.loadingMore:
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
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.success,
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pencarian Native Resmi',
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Terhubung langsung dengan basis data sertifikat halal BPJPH Kementerian Agama Republik Indonesia secara real-time.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.3,
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
            'Pencarian Populer',
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
            children: _popularQueries.map((brand) {
              return ActionChip(
                label: Text(brand),
                labelStyle: GoogleFonts.lexend(fontSize: 12),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                ),
                onPressed: () => _submitSearch(brand),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(HalalSearchState state) {
    return Column(
      children: [
        // Result metadata counter
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ditemukan ${state.totalItems} produk halal',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              Text(
                'Halaman ${state.currentPage} dari ${state.totalPages}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // List of results
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: state.results.length + (state.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == state.results.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                );
              }

              final item = state.results[index];
              return _buildHalalCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHalalCard(HalalProductModel item) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
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
            // Certified Halal Badge & Share
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, color: AppColors.success, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        'TERSERTIFIKASI HALAL',
                        style: GoogleFonts.lexend(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textSecondary),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  onPressed: () => _shareCertificate(item),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Product Name
            Text(
              item.productName,
              style: GoogleFonts.lexend(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Brand
            if (item.brandName != '-') ...[
              Text(
                'Merek: ${item.brandName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
            ],

            const Divider(height: 16),

            // Producer / PT
            _buildDetailRow(
              icon: Icons.business_rounded,
              label: 'Produsen / Pelaku Usaha',
              value: item.producerName,
            ),
            const SizedBox(height: 8),

            // Certificate Number (with copy button)
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
                        'Nomor Sertifikat',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 1),
                      InkWell(
                        onTap: () => _copyToClipboard(item.certificateNumber, 'Nomor sertifikat'),
                        borderRadius: BorderRadius.circular(4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.certificateNumber,
                              style: GoogleFonts.lexend(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Issue Date
            _buildDetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal Terbit Sertifikat',
              value: item.issueDate,
            ),

            if (item.factoryLocation != '-') ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.location_on_outlined,
                label: 'Lokasi Pabrik',
                value: item.factoryLocation,
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

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          height: 160,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
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
              'Tidak Ditemukan',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Tidak ditemukan sertifikat halal untuk kata kunci "$query". Coba gunakan nama merek utama atau produsen tanpa singkatan.',
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
              'Gagal Memuat Data',
              style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message ?? 'Terjadi kendala jaringan saat menghubungi database BPJPH.',
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
