import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/ingredients_analyzer.dart';
import '../../data/models/product_model.dart';
import '../widgets/status_badge.dart';

class ComparisonScreen extends StatelessWidget {
  final ProductModel productA;
  final ProductModel productB;

  const ComparisonScreen({
    super.key,
    required this.productA,
    required this.productB,
  });

  List<String> _parseIngredients(String ingText) {
    if (ingText.isEmpty || ingText == '-') return [];
    return ingText
        .split(RegExp(r',|;'))
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final listA = _parseIngredients(productA.ingredients);
    final listB = _parseIngredients(productB.ingredients);
    final commonIngredients = listA.toSet().intersection(listB.toSet()).toList();
    final conflicts = IngredientsAnalyzer.checkCrossProductConflicts(
      productA.ingredients,
      productB.ingredients,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandingkan Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Side-by-side Header
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.background,
              child: Row(
                children: [
                  Expanded(
                    child: _buildHeaderCard(productA),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildHeaderCard(productB),
                  ),
                ],
              ),
            ),
            
            // Detailed Comparison Rows
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildComparisonSectionTitle('Informasi Registrasi'),
                  _buildComparisonRow(
                    label: 'No. Registrasi',
                    valA: productA.registrationNumber,
                    valB: productB.registrationNumber,
                  ),
                  _buildComparisonRow(
                    label: 'Merk / Brand',
                    valA: productA.brand.isNotEmpty ? productA.brand : '-',
                    valB: productB.brand.isNotEmpty ? productB.brand : '-',
                  ),
                  _buildComparisonRow(
                    label: 'Bentuk Sediaan',
                    valA: productA.form.isNotEmpty ? productA.form : '-',
                    valB: productB.form.isNotEmpty ? productB.form : '-',
                  ),
                  _buildComparisonRow(
                    label: 'Produsen / Pendaftar',
                    valA: productA.manufacturer.isNotEmpty ? productA.manufacturer : '-',
                    valB: productB.manufacturer.isNotEmpty ? productB.manufacturer : '-',
                  ),
                  _buildComparisonRow(
                    label: 'Kemasan',
                    valA: productA.package.isNotEmpty ? productA.package : '-',
                    valB: productB.package.isNotEmpty ? productB.package : '-',
                  ),
                  _buildComparisonRow(
                    label: 'Status Registrasi',
                    valA: productA.status.isNotEmpty ? productA.status : '-',
                    valB: productB.status.isNotEmpty ? productB.status : '-',
                    isAmanA: productA.safetyStatus == 'AMAN',
                    isAmanB: productB.safetyStatus == 'AMAN',
                  ),

                  const SizedBox(height: 24),
                  _buildComparisonSectionTitle('Peringatan Interaksi & Konflik Bahan'),
                  _buildConflictSection(conflicts),

                  const SizedBox(height: 20),
                  _buildComparisonSectionTitle('Analisis Kandungan (Komposisi)'),
                  
                  // Danger Chemical Warnings
                  _buildDangerWarningsSection(),

                  const SizedBox(height: 16),
                  
                  // Side by side ingredients lists
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildIngredientsListCard(
                          productA.name,
                          listA,
                          commonIngredients,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildIngredientsListCard(
                          productB.name,
                          listB,
                          commonIngredients,
                        ),
                      ),
                    ],
                  ),

                  if (commonIngredients.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildCommonIngredientsHighlight(commonIngredients),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictSection(List<SkincareConflict> conflicts) {
    if (conflicts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withAlpha(50)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tidak ditemukan konflik bahan aktif agresif. Kedua produk relatif aman digunakan bersamaan.',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: conflicts.map((conflict) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.dangerLight.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.danger.withAlpha(70)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'KONFLIK: ${conflict.itemA} + ${conflict.itemB}',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      conflict.severity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                conflict.description,
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Saran: ${conflict.recommendation}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeaderCard(ProductModel product) {
    Color statusColor;
    final safety = product.safetyStatus;

    if (safety == 'AMAN') {
      statusColor = AppColors.success;
    } else if (safety == 'KEDALUWARSA' || safety == 'PERLU DICEK') {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withAlpha(70), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          StatusBadge(status: safety, fontSize: 10),
          const SizedBox(height: 8),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.brand.isNotEmpty && product.brand != '-' ? product.brand : 'Tanpa Merk',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildComparisonRow({
    required String label,
    required String valA,
    required String valB,
    bool? isAmanA,
    bool? isAmanB,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
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
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  valA,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isAmanA == null
                        ? AppColors.textPrimary
                        : (isAmanA ? AppColors.success : AppColors.danger),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 16,
                color: Colors.grey.shade300,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: Text(
                  valB,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isAmanB == null
                        ? AppColors.textPrimary
                        : (isAmanB ? AppColors.success : AppColors.danger),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerWarningsSection() {
    final warnA = IngredientsAnalyzer.analyze(productA.ingredients);
    final warnB = IngredientsAnalyzer.analyze(productB.ingredients);

    if (warnA.isEmpty && warnB.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerLight.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel_rounded, color: AppColors.danger, size: 18),
              const SizedBox(width: 6),
              Text(
                'ZAT BERBAHAYA TERDETEKSI!',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: warnA.isNotEmpty
                      ? warnA.map((w) => Text('• ${w.chemicalName}', style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.bold))).toList()
                      : [const Text('Tidak Terdeteksi', style: TextStyle(fontSize: 12, color: AppColors.success))],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: warnB.isNotEmpty
                      ? warnB.map((w) => Text('• ${w.chemicalName}', style: const TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.bold))).toList()
                      : [const Text('Tidak Terdeteksi', style: TextStyle(fontSize: 12, color: AppColors.success))],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsListCard(
    String name,
    List<String> ingredients,
    List<String> common,
  ) {
    if (ingredients.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Tidak ada data kandungan',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bahan Terkandung:',
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...ingredients.map((ing) {
            final isCommon = common.contains(ing);
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isCommon 
                    ? AppColors.success.withAlpha(35) 
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCommon 
                      ? AppColors.success.withAlpha(70) 
                      : AppColors.border.withAlpha(70),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ing,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                        fontWeight: isCommon ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isCommon)
                    const Icon(Icons.check_circle_outline_rounded, size: 12, color: AppColors.success),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCommonIngredientsHighlight(List<String> common) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withAlpha(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
              const SizedBox(width: 6),
              Text(
                '${common.length} Kandungan yang Sama (Kembar):',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: common.map((c) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                c,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
