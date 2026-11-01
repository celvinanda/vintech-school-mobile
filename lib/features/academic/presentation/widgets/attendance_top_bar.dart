import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/models/user_model.dart';
import 'package:vintech_school_mobile/features/home/presentation/widgets/top_bar/top_bar_emblem.dart';

/// Top Bar Presensi Siswa & Guru Modular & Cerdas
/// Selaras 1:1 dengan tema Top Bar Beranda:
/// - Kiri: Emblem Ikon Presensi (Shield) 40x40 dengan gradien warna sekolah
/// - Tengah: Judul "PRESENSI & KEHADIRAN" dan konteks Sekolah / Status
/// - Kanan: Pill Status GPS + Tombol Segarkan (Ikon langsung tanpa border circle)
class AttendanceTopBar extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final VoidCallback onRefresh;
  final bool isStudent;

  const AttendanceTopBar({
    super.key,
    required this.profile,
    required this.schoolColor,
    required this.onRefresh,
    this.isStudent = true,
  });

  @override
  Widget build(BuildContext context) {
    final school = profile.activeSchool;
    final schoolName = school?.name ?? 'Vintech School';
    final roleLabel = isStudent ? 'Presensi Siswa' : 'Presensi Pendidik';

    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Modular Emblem Presensi
          TopBarEmblem(
            schoolColor: schoolColor,
            icon: Icons.shield_rounded,
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
                    'PRESENSI & KEHADIRAN',
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
                    '$schoolName • $roleLabel',
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
          const SizedBox(width: 6),

          // 3. Smart GPS Live Radius Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF059669),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'GPS Aktif',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF059669),
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
