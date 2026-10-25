import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Komponen navigasi bawah (Bottom Navigation Bar) yang modular, terisolasi,
/// dan cerdas untuk Vintech School Mobile.
/// Mendukung:
/// 1. Material 3 Clean Modern UI dengan indicator tint warna sekolah.
/// 2. Haptic feedback sentuhan ringan saat berpindah tab.
/// 3. Indikator badge cerdas (misal: antrean outbox offline pada tab Presensi).
/// 4. Label kontekstual berbasis peran (Siswa vs Guru/Staf).
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color schoolColor;
  final bool isStaffOrTeacher;
  final int pendingOutboxCount;
  final int unpaidInvoiceCount;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.schoolColor,
    this.isStaffOrTeacher = false,
    this.pendingOutboxCount = 0,
    this.unpaidInvoiceCount = 0,
  });

  Widget _buildIconWithBadge({
    required IconData icon,
    Color? iconColor,
    int badgeCount = 0,
    Color badgeColor = const Color(0xFFD97706),
  }) {
    final iconWidget = Icon(icon, color: iconColor, size: 22);

    if (badgeCount <= 0) {
      return iconWidget;
    }

    return Badge(
      backgroundColor: badgeColor,
      textColor: Colors.white,
      smallSize: 8,
      label: badgeCount > 1
          ? Text(
              '$badgeCount',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            )
          : null,
      child: iconWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
            );
          }),
        ),
        child: NavigationBar(
          height: 65,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            if (index != currentIndex) {
              HapticFeedback.selectionClick();
              onTap(index);
            }
          },
          indicatorColor: schoolColor.withAlpha(24),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            // Tab 1: Beranda
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, size: 22, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.home_rounded, color: schoolColor, size: 22),
              label: 'Beranda',
            ),

            // Tab 2: Presensi (dengan badge outbox jika ada antrean offline)
            NavigationDestination(
              icon: _buildIconWithBadge(
                icon: Icons.checklist_outlined,
                iconColor: const Color(0xFF64748B),
                badgeCount: pendingOutboxCount,
                badgeColor: const Color(0xFFD97706),
              ),
              selectedIcon: _buildIconWithBadge(
                icon: Icons.checklist_rounded,
                iconColor: schoolColor,
                badgeCount: pendingOutboxCount,
                badgeColor: const Color(0xFFD97706),
              ),
              label: isStaffOrTeacher ? 'Presensi Kelas' : 'Presensi',
            ),

            // Tab 3: Tagihan SPP / Keuangan
            NavigationDestination(
              icon: _buildIconWithBadge(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: const Color(0xFF64748B),
                badgeCount: unpaidInvoiceCount,
                badgeColor: const Color(0xFFDC2626),
              ),
              selectedIcon: _buildIconWithBadge(
                icon: Icons.account_balance_wallet_rounded,
                iconColor: schoolColor,
                badgeCount: unpaidInvoiceCount,
                badgeColor: const Color(0xFFDC2626),
              ),
              label: isStaffOrTeacher ? 'Keuangan' : 'Tagihan SPP',
            ),

            // Tab 4: Profil
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded, size: 22, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.person_rounded, color: schoolColor, size: 22),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
