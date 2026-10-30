import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/models/user_model.dart';
import '../settings_screen.dart';

/// Card 1: Top Navigation Header for Profile (Stitch Design)
/// Menampilkan Emblem Sekolah, Title "Profil Siswa", dan Akses Pengaturan Sistem
class ProfileHeaderBar extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;

  const ProfileHeaderBar({
    super.key,
    required this.profile,
    required this.schoolColor,
  });

  @override
  Widget build(BuildContext context) {
    final schoolName = profile.activeSchool?.schoolName ?? 'Vintech School';
    final isStudent = profile.activeSchool?.isStudent == true;

    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: schoolColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: schoolColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schoolName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    isStudent ? 'Profil Siswa' : 'Profil Tenaga Pendidik',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFECEEF0)),
              ),
            ),
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF475569),
              size: 21,
            ),
            tooltip: 'Pengaturan & Sistem',
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(profile: profile),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
