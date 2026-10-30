import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/school_dashboard_model.dart';
import '../school_profile_screen.dart';
import '../student_notifications_screen.dart';

/// Komponen Top Bar Beranda yang diselaraskan 1:1 dengan Google Stitch Design.
/// - Kiri: School Emblem (Rounded Box dengan primary color & white school icon)
/// - Tengah: Nama Institusi Sekolah & Periode Akademik / Sapaan
/// - Kanan: Icon Lonceng Notifikasi mandiri dengan navigasi ke halaman Notifikasi Siswa
class HomeTopBar extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final VoidCallback? onSchoolTap;
  final VoidCallback? onNotificationTap;
  final List<AnnouncementModel>? announcements;
  final bool hasUnreadNotifications;

  const HomeTopBar({
    super.key,
    required this.profile,
    required this.schoolColor,
    this.onSchoolTap,
    this.onNotificationTap,
    this.announcements,
    this.hasUnreadNotifications = true,
  });

  String get _firstName {
    final full = profile.user.fullName.trim();
    if (full.isEmpty) {
      return profile.activeSchool?.isStaffOrTeacher == true ? 'Guru' : 'Siswa';
    }
    return full.split(' ').first;
  }

  void _handleSchoolTap(BuildContext context) {
    HapticFeedback.selectionClick();
    if (onSchoolTap != null) {
      onSchoolTap!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchoolProfileScreen(profile: profile),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context) {
    HapticFeedback.selectionClick();
    if (onNotificationTap != null) {
      onNotificationTap!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentNotificationsScreen(
          profile: profile,
          schoolColor: schoolColor,
          announcements: announcements,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final school = profile.activeSchool;
    final schoolName = school?.name ?? 'Vintech School';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. School Emblem (Stitch Design: rounded-lg bg-primary shadow-sm)
        GestureDetector(
          onTap: () => _handleSchoolTap(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: schoolColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: schoolColor.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. School Name & Academic Period / Semester
        Expanded(
          child: GestureDetector(
            onTap: () => _handleSchoolTap(context),
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  schoolName.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191C1E),
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Semester Genap 2025/2026 • Halo, $_firstName',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF565E74),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 3. Tombol Notifikasi Icon Lonceng (Stitch Design)
        GestureDetector(
          onTap: () => _handleNotificationTap(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFECEEF0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF434655),
                    size: 21,
                  ),
                ),
                if (hasUnreadNotifications)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBA1A1A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
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
