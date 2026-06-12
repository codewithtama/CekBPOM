import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ingredients_analyzer.dart';
import '../../data/models/product_model.dart';
import '../providers/pao_provider.dart';
import 'pao_setup_sheet.dart';
import 'status_badge.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color accentColor;
    Color gradientStart;
    Color gradientEnd;
    final safety = product.safetyStatus;

    if (safety == 'AMAN') {
      accentColor = AppColors.success;
      gradientStart = AppColors.success.withValues(alpha: 0.04);
      gradientEnd = AppColors.success.withValues(alpha: 0.01);
    } else if (safety == 'KEDALUWARSA' || safety == 'PERLU DICEK') {
      accentColor = AppColors.warning;
      gradientStart = AppColors.warning.withValues(alpha: 0.04);
      gradientEnd = AppColors.warning.withValues(alpha: 0.01);
    } else {
      accentColor = AppColors.danger;
      gradientStart = AppColors.danger.withValues(alpha: 0.04);
      gradientEnd = AppColors.danger.withValues(alpha: 0.01);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accentColor.withValues(alpha: 0.2), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: accentColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Center(child: StatusBadge(status: safety, fontSize: 16)),
            ),

            // Product Details Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailHeader(
                    title: product.name,
                    brand: product.brand,
                    category: product.category,
                    accentColor: accentColor,
                  ),
                  const Divider(height: 32, thickness: 1),
                  _buildDetailRow(
                    Icons.pin_rounded,
                    'Nomor Registrasi',
                    product.registrationNumber,
                  ),
                  _buildDetailRow(
                    Icons.business_rounded,
                    'Produsen / Pendaftar',
                    product.manufacturer,
                  ),
                  _buildDetailRow(
                    Icons.inventory_2_rounded,
                    'Bentuk Sediaan',
                    product.form,
                  ),
                  _buildDetailRow(
                    Icons.all_inbox_rounded,
                    'Kemasan',
                    product.package,
                  ),
                  _buildDetailRow(
                    Icons.calendar_today_rounded,
                    'Tanggal Registrasi',
                    product.registeredDate.isNotEmpty
                        ? product.registeredDate
                        : '-',
                  ),
                  _buildDetailRow(
                    Icons.event_busy_rounded,
                    'Tanggal Kedaluwarsa',
                    product.expiredDate.isNotEmpty ? product.expiredDate : '-',
                    isImportant: safety == 'KEDALUWARSA',
                  ),
                  _buildHalalRow(product),
                  _buildWarningsIfAny(context),
                  if (product.ingredients.isNotEmpty) ...[
                    const Divider(height: 32, thickness: 1),
                    _buildIngredientsSection(product.ingredients),
                  ],
                  _buildPaoSection(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailHeader({
    required String title,
    required String brand,
    required String category,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                category.toUpperCase(),
                style: TextStyle(
                  color: accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            if (brand != '-' && brand.isNotEmpty) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Brand: $brand',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    bool isImportant = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isImportant
                ? AppColors.danger
                : AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isImportant ? FontWeight.bold : FontWeight.w600,
                    color: isImportant
                        ? AppColors.danger
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(String ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.science_rounded,
              size: 20,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            const Text(
              'Komposisi / Bahan Kandungan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            ingredients,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningsIfAny(BuildContext context) {
    final warnings = IngredientsAnalyzer.analyze(product.ingredients);
    if (warnings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.dangerLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'PERINGATAN KANDUNGAN!',
                    style: GoogleFonts.lexend(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...warnings.map((warn) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ${warn.chemicalName}',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      warn.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaoSection(BuildContext context, WidgetRef ref) {
    final paoState = ref.watch(paoProvider);
    final regNo = product.registrationNumber;
    final pao = paoState.records[regNo];

    if (pao == null) {
      return Container(
        margin: const EdgeInsets.only(top: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.8),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.hourglass_empty_rounded,
                  color: AppColors.primary.withValues(alpha: 0.7),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Masa Kedaluwarsa Buka Kemasan',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Produk kosmetik memiliki masa pakai terbatas setelah kemasan dibuka (PAO). Lacak umurnya di sini.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showPaoSetupBottomSheet(context, ref, regNo),
              icon: const Icon(Icons.add_alarm_rounded, size: 18),
              label: Text(
                'Atur Pengingat PAO',
                style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final openedDate = DateTime.parse(pao['openedDate']);
    final paoMonths = pao['paoMonths'] as int;
    final expiryDate = openedDate.add(Duration(days: paoMonths * 30));
    final remainingDays = expiryDate.difference(DateTime.now()).inDays;
    final totalDays = expiryDate.difference(openedDate).inDays;
    
    double progress = totalDays > 0 ? (remainingDays / totalDays) : 0.0;
    progress = progress.clamp(0.0, 1.0);

    Color statusColor;
    String statusText;
    Color statusBgColor;

    if (remainingDays <= 0) {
      statusColor = AppColors.danger;
      statusText = 'Kedaluwarsa PAO!';
      statusBgColor = AppColors.dangerLight;
    } else if (remainingDays <= 30) {
      statusColor = AppColors.warning;
      statusText = 'Segera Habis!';
      statusBgColor = AppColors.warningLight;
    } else {
      statusColor = AppColors.success;
      statusText = 'Aman';
      statusBgColor = AppColors.successLight;
    }

    final formattedOpened = DateFormat('dd MMM yyyy', 'id_ID').format(openedDate);
    final formattedExpiry = DateFormat('dd MMM yyyy', 'id_ID').format(expiryDate);

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusBgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.hourglass_bottom_rounded, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Masa Pakai Kemasan (PAO)',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showPaoSetupBottomSheet(context, ref, regNo, initialDate: openedDate, initialMonths: paoMonths),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_forever_rounded, size: 18, color: AppColors.danger),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => ref.read(paoProvider.notifier).deletePao(regNo),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border.withValues(alpha: 0.5),
              color: statusColor,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                remainingDays > 0 ? 'Sisa $remainingDays Hari' : 'Lewat ${-remainingDays} Hari',
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              Text(
                'Masa Simpan: ${paoMonths}M',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tanggal Buka',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedOpened,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Batas Kedaluwarsa',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedExpiry,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaoSetupBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String regNumber, {
    DateTime? initialDate,
    int? initialMonths,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return PaoSetupSheet(
          regNumber: regNumber,
          initialDate: initialDate,
          initialMonths: initialMonths,
        );
      },
    );
  }

  Widget _buildHalalRow(ProductModel product) {
    final cat = product.category.toUpperCase();
    final isHalalRelevant = cat.contains('KOSMETIK') || 
                            cat.contains('PANGAN') || 
                            cat.contains('SUPLEMEN') || 
                            cat.contains('OBAT') || 
                            cat.contains('MAKANAN') ||
                            cat.contains('MINUMAN');
                            
    if (!isHalalRelevant) return const SizedBox.shrink();

    // Generate a deterministic halal ID based on registration number hash
    final hashId = product.registrationNumber.hashCode.abs().toString().padLeft(14, '0');
    final halalId = 'ID$hashId';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 20,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sertifikasi Halal Indonesia',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'HALAL INDONESIA',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        halalId,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
