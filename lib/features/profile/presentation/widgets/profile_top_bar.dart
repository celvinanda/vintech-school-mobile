import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/data/models/user_model.dart';

import 'package:vintech_school_mobile/features/home/presentation/widgets/top_bar/top_bar_emblem.dart';

/// Top Bar Profil & Identitas Modular & Minimalis
/// - Kiri: Emblem Ikon Profil dengan warna sekolah
/// - Tengah: Judul "PROFIL & IDENTITAS" dan nama lengkap pengguna
/// - Kanan: Tombol Pengaturan Akun & Sistem
class ProfileTopBar extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final VoidCallback onSettingsTap;

  const ProfileTopBar({
    super.key,
    required this.profile,
    required this.schoolColor,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final school = profile.activeSchool;
    final isStudent = school?.isStudent == true;
    final isParent = school?.isParent == true;
    final roleLabel =
        school?.roleDisplayLabel ??
        (isStudent
            ? 'Siswa Aktif'
            : (isParent ? 'Wali Murid' : 'Tenaga Pendidik'));
    final classroom = isParent
        ? (profile.primaryChild?.classroomName ?? 'Siswa Terikat')
        : (school?.classroomName ?? 'Kelas X-IPA-1');

    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Modular Emblem Profil
          TopBarEmblem(schoolColor: schoolColor, icon: Icons.person_rounded),
          const SizedBox(width: 12),
          // 2. Smart Title & Identity Context
          Expanded(
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
          const SizedBox(width: 8),
          // 3. Settings Button (Akses Pengaturan & Keamanan Terpusat)
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
                width: 38,
                height: 38,
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
