import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/school_dashboard_model.dart';
import '../school_profile_screen.dart';

/// Komponen Top Bar Beranda yang clean, minimalis, dan modern.
/// Fitur:
/// 1. Kiri: Profile Sekolah (School Emblem & Profile Info) menggantikan avatar personal.
/// 2. Tengah: Sapaan pengguna yang ramah dan nama institusi sekolah.
/// 3. Kanan: Icon Lonceng Notifikasi mandiri dengan indikator badge aktif.
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

  bool get _isStaffOrTeacher => profile.activeSchool?.isStaffOrTeacher == true;

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
    _showNotificationsModal(context);
  }

  @override
  Widget build(BuildContext context) {
    final school = profile.activeSchool;
    final schoolName = school?.name ?? 'Vintech School';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Profile Sekolah (Emblem Avatar Institusi)
        GestureDetector(
          onTap: () => _handleSchoolTap(context),
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
              child: Icon(
                Icons.school_rounded,
                color: schoolColor,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Teks Sapaan Pengguna & Nama Sekolah
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Halo, $_firstName ${_isStaffOrTeacher ? "👨‍🏫" : "👋"}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16.5,
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

        // 3. Tombol Notifikasi Icon Lonceng (Clean & Minimalis)
        GestureDetector(
          onTap: () => _handleNotificationTap(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 22,
                  color: Color(0xFF1E293B),
                ),
                if (hasUnreadNotifications)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626), // Merah aktif indikator notifikasi
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

  /// Modal Daftar Notifikasi & Pengumuman Sekolah
  void _showNotificationsModal(BuildContext context) {
    final list = announcements ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: schoolColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.notifications_active_rounded, color: schoolColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Pemberitahuan Sekolah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none_rounded, size: 44, color: const Color(0xFF94A3B8)),
                            const SizedBox(height: 12),
                            Text(
                              'Belum Ada Notifikasi Baru',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pengumuman resmi dari sekolah akan muncul di sini.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: list.length,
                        separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                        itemBuilder: (ctx, index) {
                          final item = list[index];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        if (item.isPinned)
                                          Container(
                                            margin: const EdgeInsets.only(right: 6),
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEF3C7),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'PENTING',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFFB45309),
                                              ),
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: schoolColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.audienceDisplay.toUpperCase(),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: schoolColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      item.createdAt.length >= 10 ? item.createdAt.substring(0, 10) : item.createdAt,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.content,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFF475569),
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
