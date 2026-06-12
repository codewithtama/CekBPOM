import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scan_history_model.dart';

class ScanHistoryTile extends StatelessWidget {
  final ScanHistoryModel history;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final bool isComparisonMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;
  final Map<dynamic, dynamic>? paoData;

  const ScanHistoryTile({
    super.key,
    required this.history,
    required this.onTap,
    required this.onDelete,
    this.isComparisonMode = false,
    this.isSelected = false,
    this.onSelectChanged,
    this.paoData,
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

    Widget? paoIndicator;
    if (paoData != null) {
      final openedDate = DateTime.parse(paoData!['openedDate']);
      final paoMonths = paoData!['paoMonths'] as int;
      final expiryDate = openedDate.add(Duration(days: paoMonths * 30));
      final remainingDays = expiryDate.difference(DateTime.now()).inDays;
      
      Color paoColor;
      IconData paoIcon;
      String paoText;

      if (remainingDays <= 0) {
        paoColor = AppColors.danger;
        paoIcon = Icons.hourglass_disabled_rounded;
        paoText = 'PAO Exp';
      } else if (remainingDays <= 30) {
        paoColor = AppColors.warning;
        paoIcon = Icons.hourglass_bottom_rounded;
        paoText = 'PAO ${remainingDays}d';
      } else {
        paoColor = AppColors.success;
        paoIcon = Icons.hourglass_top_rounded;
        paoText = 'PAO ${remainingDays}d';
      }

      paoIndicator = Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: paoColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(paoIcon, size: 10, color: paoColor),
            const SizedBox(width: 3),
            Text(
              paoText,
              style: TextStyle(
                color: paoColor,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

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
              if (isComparisonMode)
                Checkbox(
                  value: isSelected,
                  onChanged: onSelectChanged,
                  activeColor: AppColors.primary,
                ),
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
                          Row(
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
                              // ignore: use_null_aware_elements
                              if (paoIndicator != null) paoIndicator,
                            ],
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

              // Hide delete button when in comparison mode
              if (!isComparisonMode) ...[
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  onPressed: onDelete,
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
