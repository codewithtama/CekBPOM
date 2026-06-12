import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../providers/history_provider.dart';
import '../widgets/scan_history_tile.dart';
import 'result_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Hapus Semua Riwayat',
            style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus seluruh riwayat pemindaian? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.lexend(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(historyProvider.notifier).clearAll();
                Navigator.pop(context);
              },
              child: Text(
                'Hapus Semua',
                style: GoogleFonts.lexend(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyList = ref.watch(historyProvider);

    // Filter history based on search query
    final filteredList = historyList.where((item) {
      final name = item.product.name.toLowerCase();
      final code = item.product.registrationNumber.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || code.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Cek'),
        actions: [
          if (historyList.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color: AppColors.danger,
              ),
              tooltip: 'Hapus Semua',
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          if (historyList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama produk atau kode BPOM...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear_rounded,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

          // Main history list
          Expanded(
            child: historyList.isEmpty
                ? _buildEmptyState()
                : filteredList.isEmpty
                ? _buildNoResultsState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return ScanHistoryTile(
                        key: ValueKey(item.key),
                        history: item,
                        onTap: () {
                          // Re-open results screen using cached record in model
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultScreen(
                                scanCode: item.product.registrationNumber,
                                cachedProduct: item.product,
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          ref
                              .read(historyProvider.notifier)
                              .deleteItem(item.key);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Riwayat',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Produk yang Anda scan atau cari secara manual akan tersimpan secara otomatis di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AppColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ditemukan',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tidak ada riwayat dengan pencarian "$_searchQuery".',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
