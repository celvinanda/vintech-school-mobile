import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/models/user_model.dart';
import 'package:vintech_school_mobile/features/home/presentation/widgets/top_bar/top_bar_emblem.dart';

/// Top Bar Profil & Identitas Modular & Cerdas
/// Selaras 1:1 dengan tema Top Bar Beranda:
/// - Kiri: Emblem Ikon Siswa 40x40 dengan gradien warna sekolah
/// - Tengah: Judul "PROFIL & IDENTITAS" dan nama lengkap siswa
/// - Kanan: Tombol QR Scan + Tombol Pengaturan (Ikon langsung tanpa border circle)
class ProfileTopBar extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final VoidCallback onDigitalCardTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onShareQrTap;

  const ProfileTopBar({
    super.key,
    required this.profile,
    required this.schoolColor,
    required this.onDigitalCardTap,
    required this.onSettingsTap,
    required this.onShareQrTap,
  });

  @override
  Widget build(BuildContext context) {
    final school = profile.activeSchool;
    final isStudent = school?.isStudent == true;
    final roleLabel = isStudent ? 'Siswa Aktif' : 'Tenaga Pendidik';
    final classroom = school?.classroomName ?? 'Kelas X-IPA-1';

    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Modular Emblem Profil
          TopBarEmblem(
            schoolColor: schoolColor,
            icon: Icons.person_rounded,
            onTap: onDigitalCardTap,
          ),
          const SizedBox(width: 12),

          // 2. Smart Title & Identity Context
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onDigitalCardTap();
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PROFIL & IDENTITAS',
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
                    '${profile.user.fullName} • $roleLabel ($classroom)',
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
          const SizedBox(width: 4),

          // 3. QR Quick-Scan Button (Ikon langsung tanpa border circle)
          Material(
            color: Colors.transparent,
            child: InkResponse(
              onTap: () {
                HapticFeedback.selectionClick();
                onShareQrTap();
              },
              radius: 20,
              highlightShape: BoxShape.circle,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    color: Color(0xFF334155),
                    size: 23,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),

          // 4. Settings Button (Ikon langsung tanpa border circle)
          Material(
            color: Colors.transparent,
            child: InkResponse(
              onTap: () {
                HapticFeedback.selectionClick();
                onSettingsTap();
              },
              radius: 20,
              highlightShape: BoxShape.circle,
              child: const SizedBox(
                width: 36,
                height: 36,
                child: Center(
                  child: Icon(
                    Icons.settings_outlined,
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
