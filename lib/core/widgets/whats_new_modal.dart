import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';
import '../storage/local_storage.dart';

/// Modal 'Yang Baru di Versi Ini' (What's New)
/// Ditampilkan ke pengguna secara otomatis setelah aplikasi diperbarui,
/// berfokus pada manfaat nyata bagi pengguna tanpa istilah teknis developer.
class WhatsNewModal extends StatelessWidget {
  final Color? customColor;
  final VoidCallback? onDismiss;

  const WhatsNewModal({
    super.key,
    this.customColor,
    this.onDismiss,
  });

  static Future<void> showIfAvailable(
    BuildContext context,
    LocalStorage storage, {
    Color? primaryColor,
  }) async {
    if (!storage.shouldShowWhatsNew()) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WhatsNewModal(
        customColor: primaryColor,
        onDismiss: () async {
          await storage.markWhatsNewSeen();
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = customColor ?? const Color(0xFF004AC6);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Row: Badge Versi & Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Pembaruan ${AppConstants.appVersion}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: themeColor,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: Color(0xFFD97706),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Judul Utama
            Text(
              'Yang Baru di Vintech School',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fitur dan penyempurnaan terbaru untuk kemudahan belajar Anda.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),

            // Daftar Fitur Baru (Sorotan Rilis)
            _buildFeatureRow(
              icon: Icons.badge_outlined,
              iconColor: const Color(0xFF0284C7),
              iconBg: const Color(0xFFE0F2FE),
              title: 'Kartu Pelajar & Profil Digital Modern',
              description:
                  'Identitas digital resmi lengkap dengan kode validasi QR instan untuk verifikasi sekolah.',
            ),
            const SizedBox(height: 14),
            _buildFeatureRow(
              icon: Icons.checklist_rounded,
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFD1FAE5),
              title: 'Presensi & Kehadiran Terintegrasi',
              description:
                  'Rekapitulasi kehadiran harian langsung tersinkronisasi otomatis dengan portal sekolah.',
            ),
            const SizedBox(height: 14),
            _buildFeatureRow(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFEDE9FE),
              title: 'Informasi SPP & Pembayaran Cepat',
              description:
                  'Pantau status tagihan SPP bulanan transparan dengan riwayat pembayaran digital.',
            ),
            const SizedBox(height: 14),
            _buildFeatureRow(
              icon: Icons.bolt_rounded,
              iconColor: const Color(0xFFEA580C),
              iconBg: const Color(0xFFFFEDD5),
              title: 'Peningkatan Kinerja & Offline Cepat',
              description:
                  'Aplikasi lebih tangkas, hemat kuota internet, dan pembaruan sistem otomatis di latar belakang.',
            ),
            const SizedBox(height: 24),

            // Tombol Konfirmasi "Mengerti & Lanjutkan"
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (onDismiss != null) {
                    onDismiss!();
                  } else {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Mengerti & Lanjutkan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
