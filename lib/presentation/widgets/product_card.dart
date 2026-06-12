import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import 'status_badge.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
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
                  if (product.ingredients.isNotEmpty) ...[
                    const Divider(height: 32, thickness: 1),
                    _buildIngredientsSection(product.ingredients),
                  ],
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
}
