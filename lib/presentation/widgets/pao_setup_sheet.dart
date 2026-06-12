import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../providers/pao_provider.dart';

class PaoSetupSheet extends ConsumerStatefulWidget {
  final String regNumber;
  final DateTime? initialDate;
  final int? initialMonths;

  const PaoSetupSheet({
    super.key,
    required this.regNumber,
    this.initialDate,
    this.initialMonths,
  });

  @override
  ConsumerState<PaoSetupSheet> createState() => _PaoSetupSheetState();
}

class _PaoSetupSheetState extends ConsumerState<PaoSetupSheet> {
  late DateTime _selectedDate;
  late int _selectedMonths;
  final List<int> _commonDurations = [3, 6, 12, 18, 24];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedMonths = widget.initialMonths ?? 12;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);

    return Padding(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            widget.initialMonths != null ? 'Edit Pelacak PAO' : 'Atur Pelacak PAO',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lacak kelayakan kosmetik setelah segel/kemasan dibuka.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),

          // Date opened selector
          Text(
            'Tanggal Buka Kemasan',
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Duration selection
          Text(
            'Masa Pakai Setelah Dibuka (Bulan)',
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Predefined chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _commonDurations.map((duration) {
              final isSelected = _selectedMonths == duration;
              return ChoiceChip(
                label: Text(
                  '${duration}M',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.background,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedMonths = duration;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Slider for custom months
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Durasi Kustom:',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$_selectedMonths Bulan',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Slider(
            value: _selectedMonths.toDouble(),
            min: 1,
            max: 36,
            divisions: 35,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (val) {
              setState(() {
                _selectedMonths = val.toInt();
              });
            },
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Batal',
                    style: GoogleFonts.lexend(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(paoProvider.notifier).savePao(
                          widget.regNumber,
                          _selectedDate,
                          _selectedMonths,
                        );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
