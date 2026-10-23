import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'product_model.dart';
import 'public_service_model.dart';

class PublicVerificationResult {
  final PublicServiceType serviceType;
  final String queryCode;
  final String title;
  final String registrationNumber;
  final String institution;
  final String holderName;
  final String validityPeriod;
  final String category;
  final String status; // 'TERDAFTAR & SAH', 'TIDAK TERDAFTAR', 'PERLU KONFIRMASI', 'TIDAK VALID'
  final Color statusColor;
  final String statusDescription;
  final Map<String, String> technicalDetails;
  final DateTime verifiedAt;
  final String sourceLabel;
  final bool isValid;
  final String officialPortalUrl;

  const PublicVerificationResult({
    required this.serviceType,
    required this.queryCode,
    required this.title,
    required this.registrationNumber,
    required this.institution,
    required this.holderName,
    required this.validityPeriod,
    required this.category,
    required this.status,
    required this.statusColor,
    required this.statusDescription,
    required this.technicalDetails,
    required this.verifiedAt,
    required this.sourceLabel,
    required this.isValid,
    required this.officialPortalUrl,
  });

  /// Status badge color based on verification state
  Color get badgeColor {
    if (!isValid) return AppColors.danger;
    if (status.contains('PERLU') || status.contains('KEDALUWARSA')) {
      return AppColors.warning;
    }
    return AppColors.success;
  }

  /// Converts this result into ProductModel so it can be stored in History and printed via PdfGenerator
  ProductModel toProductModel() {
    final statusText = isValid ? 'Berlaku' : (status.isNotEmpty ? status : 'TIDAK TERDAFTAR');
    final detailsSummary = technicalDetails.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');

    return ProductModel(
      productId: '${serviceType.name}_${DateTime.now().millisecondsSinceEpoch}',
      registrationNumber: registrationNumber,
      name: title,
      brand: holderName,
      package: category,
      form: institution,
      manufacturer: holderName,
      status: statusText,
      expiredDate: '',
      registeredDate: '${verifiedAt.day}/${verifiedAt.month}/${verifiedAt.year}',
      category: category,
      ingredients: detailsSummary,
      isFound: isValid,
    );
  }
}
