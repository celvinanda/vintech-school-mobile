import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/models/user_model.dart';

/// Komponen Top Bar Beranda (Greeting & School Badge) yang modular,
/// terisolasi, dan adaptif untuk peran Siswa maupun Guru/Staf.
class HomeTopBar extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onSchoolBadgeTap;

  const HomeTopBar({
    super.key,
    required this.profile,
    required this.schoolColor,
    this.onAvatarTap,
    this.onSchoolBadgeTap,
  });

  String get _firstName {
    final full = profile.user.fullName.trim();
    if (full.isEmpty) {
      return profile.activeSchool?.isStaffOrTeacher == true ? 'Guru' : 'Siswa';
    }
    return full.split(' ').first;
  }

  String get _initials => profile.user.initials;

  bool get _isStaffOrTeacher => profile.activeSchool?.isStaffOrTeacher == true;

  @override
  Widget build(BuildContext context) {
    final school = profile.activeSchool;
    final schoolCode = school?.code ?? (_isStaffOrTeacher ? 'GURU' : 'SISWA');
    final schoolName = school?.name ?? 'Vintech School';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Avatar Pengguna dengan Inisial (Dapat di-tap untuk ke Profil)
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: schoolColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: schoolColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _initials,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: schoolColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Teks Sapaan Pengguna & Nama Institusi Sekolah
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Halo, $_firstName ${_isStaffOrTeacher ? "👨‍🏫" : "👋"}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                schoolName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // 3. School Code Pill Badge (Dapat di-tap jika ada multi-sekolah)
        GestureDetector(
          onTap: onSchoolBadgeTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: schoolColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  schoolCode,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
