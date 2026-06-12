import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scan_history_model.dart';

class ScanHistoryTile extends StatelessWidget {
  final ScanHistoryModel history;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ScanHistoryTile({
    super.key,
    required this.history,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    final safety = history.product.safetyStatus;

    if (safety == 'AMAN') {
      statusColor = AppColors.success;
    } else if (safety == 'KEDALUWARSA' || safety == 'PERLU DICEK') {
      statusColor = AppColors.warning;
    } else {
      statusColor = AppColors.danger;
    }

    final formattedDate = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(history.scanDate);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left status color bar
              Container(
                width: 6,
                color: statusColor,
              ),
              
              // Detail info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              safety,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        history.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nomor Reg: ${history.product.registrationNumber}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                onPressed: onDelete,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
