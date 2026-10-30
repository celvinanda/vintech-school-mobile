import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Komponen Layanan Cepat (4 Kolom Action Bento Grid)
/// Selaras 1:1 dengan Google Stitch Dashboard
class StudentQuickServices extends StatelessWidget {
  final Function(int tabIndex) onNavigateTab;

  const StudentQuickServices({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ServiceButton(
          icon: Icons.fact_check_rounded,
          label: 'Presensi',
          iconColor: const Color(0xFF007D55),
          bgColor: const Color(0xFF007D55).withValues(alpha: 0.10),
          onTap: () {
            HapticFeedback.selectionClick();
            onNavigateTab(1);
          },
        ),
        const SizedBox(width: 10),
        _ServiceButton(
          icon: Icons.account_balance_wallet_rounded,
          label: 'SPP Digital',
          iconColor: const Color(0xFF004AC6),
          bgColor: const Color(0xFF004AC6).withValues(alpha: 0.10),
          onTap: () {
            HapticFeedback.selectionClick();
            onNavigateTab(2);
          },
        ),
        const SizedBox(width: 10),
        _ServiceButton(
          icon: Icons.calendar_month_rounded,
          label: 'Jadwal',
          iconColor: const Color(0xFF4F46E5),
          bgColor: const Color(0xFF4F46E5).withValues(alpha: 0.10),
          onTap: () {
            HapticFeedback.selectionClick();
            onNavigateTab(1);
          },
        ),
        const SizedBox(width: 10),
        _ServiceButton(
          icon: Icons.campaign_rounded,
          label: 'Pengumuman',
          iconColor: const Color(0xFFD97706),
          bgColor: const Color(0xFFD97706).withValues(alpha: 0.12),
          onTap: () {
            HapticFeedback.selectionClick();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menampilkan pengumuman resmi sekolah di bawah.'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ServiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _ServiceButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEEF0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF191C1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
