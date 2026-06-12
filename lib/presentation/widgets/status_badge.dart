import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status.toUpperCase()) {
      case 'AMAN':
        backgroundColor = AppColors.successLight;
        textColor = AppColors.success;
        icon = Icons.verified_user_rounded;
        label = 'AMAN / TERDAFTAR';
        break;
      case 'KEDALUWARSA':
        backgroundColor = AppColors.warningLight;
        textColor = AppColors.warning;
        icon = Icons.timelapse_rounded;
        label = 'KEDALUWARSA';
        break;
      case 'PERLU DICEK':
        backgroundColor = AppColors.warningLight;
        textColor = AppColors.warning;
        icon = Icons.warning_amber_rounded;
        label = 'PERLU DICEK';
        break;
      case 'TIDAK TERDAFTAR':
      default:
        backgroundColor = AppColors.dangerLight;
        textColor = AppColors.danger;
        icon = Icons.gpp_bad_rounded;
        label = 'TIDAK TERDAFTAR';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: textColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: fontSize + 4),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
