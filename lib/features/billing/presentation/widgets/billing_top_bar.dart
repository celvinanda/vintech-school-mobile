import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/models/user_model.dart';
import 'package:vintech_school_mobile/features/home/presentation/widgets/top_bar/top_bar_emblem.dart';

/// Top Bar Tagihan SPP Modular & Cerdas
/// Selaras 1:1 dengan tema Top Bar Beranda:
/// - Kiri: Emblem Ikon Keuangan / Dompet 40x40 dengan gradien warna sekolah
/// - Tengah: Judul "TAGIHAN SPP & KEUANGAN" dan konteks Siswa / TA
/// - Kanan: Status Tagihan Unpaid Badge + Tombol Segarkan (Ikon langsung tanpa border circle)
class BillingTopBar extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final VoidCallback onRefresh;
  final int unpaidCount;

  const BillingTopBar({
    super.key,
    required this.profile,
    required this.schoolColor,
    required this.onRefresh,
    this.unpaidCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final school = profile.activeSchool;
    final schoolName = school?.name ?? 'Vintech School';
    final nis = profile.user.cleanIdentifier;

    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Modular Emblem Keuangan
          TopBarEmblem(
            schoolColor: schoolColor,
            icon: Icons.account_balance_wallet_rounded,
            onTap: onRefresh,
          ),
          const SizedBox(width: 12),

          // 2. Smart Title & Contextual Info
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onRefresh();
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TAGIHAN SPP & KEUANGAN',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    '$schoolName • NIS $nis',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 3. Smart Unpaid Status Pill (Jika ada tagihan tertunggak)
          if (unpaidCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$unpaidCount Belum Bayar',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 4),

          // 4. Refresh Action Button (Bersih langsung icon tanpa border/card circle)
          Material(
            color: Colors.transparent,
            child: InkResponse(
              onTap: () {
                HapticFeedback.selectionClick();
                onRefresh();
              },
              radius: 20,
              highlightShape: BoxShape.circle,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF334155),
                    size: 23,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
