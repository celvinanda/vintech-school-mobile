import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 4: Segmented Tabs Filter (Stitch Design)
/// Filter status tagihan: Belum Bayar (X), Riwayat Lunas (Y), Semua (Z)
class BillingFilterTabs extends StatelessWidget {
  final String selectedFilter; // 'UNPAID', 'PAID', 'ALL'
  final ValueChanged<String> onFilterChanged;
  final int unpaidCount;
  final int paidCount;
  final int totalCount;
  final Color primaryColor;

  const BillingFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.unpaidCount,
    required this.paidCount,
    required this.totalCount,
    this.primaryColor = const Color(0xFF004AC6),
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFECEEF0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _buildTab(
              label: 'Belum Bayar ($unpaidCount)',
              value: 'UNPAID',
            ),
            const SizedBox(width: 4),
            _buildTab(
              label: 'Riwayat Lunas ($paidCount)',
              value: 'PAID',
            ),
            const SizedBox(width: 4),
            _buildTab(
              label: 'Semua ($totalCount)',
              value: 'ALL',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required String label, required String value}) {
    final isSelected = selectedFilter == value;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isSelected) {
              HapticFeedback.selectionClick();
              onFilterChanged(value);
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? primaryColor : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
