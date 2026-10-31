import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/local_storage.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/models/school_dashboard_model.dart';
import '../school_profile_screen.dart';
import '../student_notifications_screen.dart';
import 'top_bar/top_bar_emblem.dart';
import 'top_bar/top_bar_network_status.dart';
import 'top_bar/top_bar_notification_action.dart';
import 'top_bar/top_bar_title_context.dart';

/// Top Bar Beranda Modular & Cerdas (Smart Top Bar)
/// Mengimplementasikan arsitektur modular terpisah:
/// 1. [TopBarEmblem]: Logo / emblem institusi sekolah
/// 2. [TopBarTitleContext]: Sapaan waktu dinamis (Pagi/Siang/Sore), nama siswa, dan indikator multi-sekolah
/// 3. [TopBarNetworkStatus]: Indikator status sinkronisasi offline Hive ke cloud
/// 4. [TopBarNotificationAction]: Tombol lonceng notifikasi pintar dengan hitungan badge unread
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

  void _handleSchoolTap(BuildContext context) {
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
    final isStaff = school?.isStaffOrTeacher == true;
    final hasMultipleSchools = profile.memberships.length > 1;

    // Menghitung jumlah notifikasi pengumuman yang belum dibaca
    final unreadAnnouncementsCount = announcements?.length ?? 0;

    // Membaca status outbox sinkronisasi offline Hive
    int pendingOutbox = 0;
    try {
      pendingOutbox = context.watch<LocalStorage>().hive.totalPendingOutbox;
    } catch (_) {
      pendingOutbox = 0;
    }

    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Modular School Emblem
          TopBarEmblem(
            schoolColor: schoolColor,
            onTap: () => _handleSchoolTap(context),
          ),
          const SizedBox(width: 12),

          // 2. Smart Contextual Title & Time-Aware Greeting
          Expanded(
            child: TopBarTitleContext(
              schoolName: schoolName,
              fullName: profile.user.fullName,
              classroomName: isStaff ? school?.title : school?.classroomName,
              isStaffOrTeacher: isStaff,
              hasMultipleSchools: hasMultipleSchools,
              onTap: () => _handleSchoolTap(context),
            ),
          ),
          const SizedBox(width: 8),

          // 3. Smart Offline & Cloud Sync Status (Hanya tampil jika ada data pending di Hive)
          TopBarNetworkStatus(
            pendingSyncCount: pendingOutbox,
          ),

          // 4. Smart Notification Bell Action
          TopBarNotificationAction(
            onTap: () => _handleNotificationTap(context),
            unreadCount: unreadAnnouncementsCount,
            hasUnread: hasUnreadNotifications || unreadAnnouncementsCount > 0,
          ),
        ],
      ),
    );
  }
}
