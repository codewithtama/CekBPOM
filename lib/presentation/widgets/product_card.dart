import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/barcode_parser.dart';
import '../../core/utils/ingredients_analyzer.dart';
import '../../data/models/product_model.dart';
import '../../data/services/halal_service.dart';
import '../providers/pao_provider.dart';
import '../screens/halal_search_screen.dart';
import '../screens/trademark_search_screen.dart';
import 'pao_setup_sheet.dart';
import 'status_badge.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;
  final String? sourceLabel;

  const ProductCard({super.key, required this.product, this.sourceLabel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color accentColor;
    Color gradientStart;
    Color gradientEnd;
    final safety = product.safetyStatus;

    if (safety == 'AMAN') {
      accentColor = AppColors.success;
      gradientStart = AppColors.success.withAlpha(10);
      gradientEnd = AppColors.success.withAlpha(2);
    } else if (safety == 'KEDALUWARSA' || safety == 'PERLU DICEK') {
      accentColor = AppColors.warning;
      gradientStart = AppColors.warning.withAlpha(10);
      gradientEnd = AppColors.warning.withAlpha(2);
    } else {
      accentColor = AppColors.danger;
      gradientStart = AppColors.danger.withAlpha(10);
      gradientEnd = AppColors.danger.withAlpha(2);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: accentColor.withAlpha(50), width: 1.5),
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
                    color: accentColor.withAlpha(25),
                    width: 1,
                  ),
                ),
              ),
              child: Center(child: StatusBadge(status: safety, fontSize: 16)),
            ),

            if (sourceLabel != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_done_rounded, size: 18, color: accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sumber data: $sourceLabel',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  _buildRetailBarcodeNoticeIfNeeded(),
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

                  // Halal Certification Status Card
                  const SizedBox(height: 12),
                  _buildHalalSection(context),

                  // Trademark & HKI Brand Legality Section
                  const SizedBox(height: 12),
                  _buildTrademarkSection(context),

                  // Detailed Skin Safety & Ingredient Analysis
                  if (product.ingredients.isNotEmpty) ...[
                    const Divider(height: 32, thickness: 1),
                    _buildDetailedIngredientsSection(context, product.ingredients),
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
                color: accentColor.withAlpha(25),
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
                : AppColors.primary.withAlpha(180),
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

  Widget _buildHalalSection(BuildContext context) {
    final halalResult = HalalService.checkProductHalal(product);
    final isCertified = halalResult.isCertified;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCertified ? AppColors.success.withAlpha(15) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCertified ? AppColors.success.withAlpha(60) : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCertified ? AppColors.success.withAlpha(30) : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: isCertified ? AppColors.success : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sertifikasi Halal Indonesia',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      halalResult.agency,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCertified ? AppColors.success : AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  halalResult.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            halalResult.description,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HalalSearchScreen(
                    initialQuery: halalResult.query,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.verified_outlined, size: 16),
            label: Text(
              'Cek Sertifikat Halal BPJPH',
              style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isCertified ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrademarkSection(BuildContext context) {
    final query = (product.brand.isNotEmpty && product.brand != '-')
        ? product.brand
        : product.name;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.app_registration_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Legalitas Merek & HKI (DJKI)',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Pangkalan Data Kekayaan Intelektual RI',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Verifikasi kepemilikan dan status pendaftaran merek "$query" resmi DJKI Kemenkumham.',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrademarkSearchScreen(
                    initialQuery: query,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.search_rounded, size: 16),
            label: Text(
              'Cek Merek "$query" di HKI',
              style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedIngredientsSection(BuildContext context, String ingredients) {
    final analysis = IngredientsAnalyzer.analyzeDetailed(ingredients);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.science_rounded,
              size: 20,
              color: AppColors.primary.withAlpha(180),
            ),
            const SizedBox(width: 10),
            Text(
              'Analisis Formulasi & Skin Safety',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Quick Indicators Wrap
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSafetyPill(
              label: analysis.isSafeFromToxins ? 'Bebas Racun BPOM' : 'Zat Berbahaya!',
              isSafe: analysis.isSafeFromToxins,
              icon: Icons.shield_rounded,
            ),
            _buildSafetyPill(
              label: analysis.isPregnancySafe ? 'Bumil & Busui Safe' : 'Hindari Bumil',
              isSafe: analysis.isPregnancySafe,
              icon: Icons.pregnant_woman_rounded,
            ),
            _buildSafetyPill(
              label: analysis.isFungalAcneSafe ? 'Fungal Acne Safe' : 'Picu Fungal Acne',
              isSafe: analysis.isFungalAcneSafe,
              icon: Icons.spa_rounded,
            ),
            _buildSafetyPill(
              label: analysis.isSensitiveSkinSafe ? 'Kulit Sensitif Safe' : 'Ada Alergen/Parfum',
              isSafe: analysis.isSensitiveSkinSafe,
              icon: Icons.face_retouching_natural_rounded,
            ),
          ],
        ),

        // Warnings list if any
        if (analysis.totalWarnings > 0) ...[
          const SizedBox(height: 14),
          _buildWarningBox(analysis),
        ],

        // Internal conflict if any
        if (analysis.hasConflicts) ...[
          const SizedBox(height: 12),
          _buildInternalConflictBox(analysis.internalConflicts),
        ],

        const SizedBox(height: 12),
        const Text(
          'Daftar Komposisi Lengkap:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
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
              fontSize: 12,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyPill({required String label, required bool isSafe, required IconData icon}) {
    final color = isSafe ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox(IngredientAnalysisResult analysis) {
    final allWarnings = [
      ...analysis.dangerousIngredients,
      ...analysis.pregnancyWarnings,
      ...analysis.fungalAcneTriggers,
      ...analysis.allergenAndSensitivities,
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerLight.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
              const SizedBox(width: 8),
              Text(
                'Catatan Perhatian Komposisi (${allWarnings.length})',
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...allWarnings.map((w) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• [${w.category}] ${w.chemicalName}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    w.description,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.25),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInternalConflictBox(List<SkincareConflict> conflicts) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on_rounded, color: Colors.orange, size: 18),
              const SizedBox(width: 6),
              Text(
                'Peringatan Interaksi Formulasi',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...conflicts.map((c) => Text(
            '• ${c.title}: ${c.description}',
            style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, height: 1.3),
          )),
        ],
      ),
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
            color: AppColors.border.withAlpha(200),
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
                  color: AppColors.primary.withAlpha(180),
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
        color: statusBgColor.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha(70), width: 1.5),
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
                      color: statusColor.withAlpha(35),
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
              backgroundColor: AppColors.border.withAlpha(120),
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

  Widget _buildRetailBarcodeNoticeIfNeeded() {
    if (product.isFound || !BarcodeParser.isRetailBarcode(product.registrationNumber)) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withAlpha(100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kode yang dipindai (${product.registrationNumber}) merupakan barcode kasir/produk (EAN/UPC), bukan nomor registrasi BPOM.\n\nPeriksa nomor izin edar resmi pada label kemasan (misalnya BPOM RI MD/ML/NA/TR) atau pindai kode 2D QR resmi BPOM.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
