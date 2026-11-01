import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../academic/logic/attendance_cubit.dart';
import '../../../academic/presentation/widgets/academic_top_bar.dart';
import '../../../academic/presentation/widgets/attendance_top_bar.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../billing/logic/billing_cubit.dart';
import '../../../billing/logic/billing_state.dart';
import '../../../billing/presentation/widgets/billing_top_bar.dart';
import '../../../profile/presentation/settings_screen.dart';
import '../../../profile/presentation/widgets/profile_digital_card_modal.dart';
import '../../../profile/presentation/widgets/profile_top_bar.dart';
import '../../logic/home_cubit.dart';
import '../../logic/home_state.dart';
import '../school_profile_screen.dart';
import '../student_notifications_screen.dart';
import 'home_top_bar.dart';

/// Base Top Bar Terpadu (Unified Persistent Shell Header)
/// Memastikan Bar Atas menyatu permanen dengan Bar Notifikasi sistem Android/iOS:
/// 1. Wadah Luar (Background Putih, SafeArea, Border & Shadow) 100% PERSISTEN & TIDAK BERKEDIP saat ganti tab.
/// 2. Konten Dalam (Emblem, Judul & Action Buttons) bertransisi halus dengan AnimatedSwitcher (180ms).
/// 3. Mengontrol seluruh logika header 5 tab secara terpusat, modular, dan hemat memori.
class AppBaseTopBar extends StatelessWidget {
  final int currentIndex;
  final UserProfileResponse profile;
  final Color schoolColor;
  final bool isStaffOrTeacher;
  final VoidCallback? onSchoolTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onAttendanceRefresh;
  final VoidCallback? onAcademicReportTap;
  final VoidCallback? onBillingRefresh;
  final VoidCallback? onProfileDigitalCardTap;
  final VoidCallback? onProfileSettingsTap;
  final VoidCallback? onProfileShareQrTap;

  const AppBaseTopBar({
    super.key,
    required this.currentIndex,
    required this.profile,
    required this.schoolColor,
    this.isStaffOrTeacher = false,
    this.onSchoolTap,
    this.onNotificationTap,
    this.onAttendanceRefresh,
    this.onAcademicReportTap,
    this.onBillingRefresh,
    this.onProfileDigitalCardTap,
    this.onProfileSettingsTap,
    this.onProfileShareQrTap,
  });

  void _handleSchoolTap(BuildContext context) {
    if (onSchoolTap != null) {
      onSchoolTap!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SchoolProfileScreen(profile: profile),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, dynamic announcements) {
    if (onNotificationTap != null) {
      onNotificationTap!();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentNotificationsScreen(
          profile: profile,
          schoolColor: schoolColor,
          announcements: announcements,
        ),
      ),
    );
  }

  void _handleReportTap(BuildContext context) {
    if (onAcademicReportTap != null) {
      onAcademicReportTap!();
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF007D55), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Rapor Digital Resmi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Rapor digital ini diterbitkan secara otomatis dan terverifikasi tanda tangan digital kepala sekolah.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF2563EB)),
              ),
              title: Text(
                'Rapor_Semester_Genap_2026.pdf',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Nilai Rata-rata: 88.6 • Peringkat 3 dari 36',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5),
              ),
              trailing: IconButton(
                icon: Icon(Icons.download_rounded, color: schoolColor),
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Mengunduh Rapor Digital (PDF)...'),
                      backgroundColor: Color(0xFF007D55),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _handleDigitalCardTap(BuildContext context) {
    if (onProfileDigitalCardTap != null) {
      onProfileDigitalCardTap!();
      return;
    }
    showDialog(
      context: context,
      builder: (_) => ProfileDigitalCardModal(
        profile: profile,
        schoolColor: schoolColor,
      ),
    );
  }

  void _handleSettingsTap(BuildContext context) {
    if (onProfileSettingsTap != null) {
      onProfileSettingsTap!();
      return;
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(profile: profile),
      ),
    );
  }

  void _handleShareQrTap(BuildContext context) {
    if (onProfileShareQrTap != null) {
      onProfileShareQrTap!();
      return;
    }
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Bagikan QR Profil Siswa',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pindai QR ini untuk verifikasi absensi atau gerbang perpustakaan sekolah.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(Icons.qr_code_2_rounded, size: 160, color: schoolColor),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(
              bottom: BorderSide(color: Color(0xFFECEEF0), width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: KeyedSubtree(
                  key: ValueKey<int>(currentIndex),
                  child: _buildInnerTopBar(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _isParent => profile.activeSchool?.isParent == true;
  bool get _isStudent => profile.activeSchool?.isStudent == true || (!isStaffOrTeacher && !_isParent);

  Widget _buildInnerTopBar(BuildContext context) {
    if (_isParent) {
      switch (currentIndex) {
        case 0:
          return _buildHomeTopBar(context);
        case 1:
          return _buildAttendanceTopBar(context);
        case 2:
          return _buildBillingTopBar(context);
        case 3:
          return _buildProfileTopBar(context);
        default:
          return const SizedBox.shrink();
      }
    } else if (_isStudent) {
      switch (currentIndex) {
        case 0:
          return _buildHomeTopBar(context);
        case 1:
          return _buildAttendanceTopBar(context);
        case 2:
          return _buildAcademicTopBar(context);
        case 3:
          return _buildProfileTopBar(context);
        default:
          return const SizedBox.shrink();
      }
    } else {
      switch (currentIndex) {
        case 0:
          return _buildHomeTopBar(context);
        case 1:
          return _buildAttendanceTopBar(context);
        case 2:
          return _buildAcademicTopBar(context);
        case 3:
          return _buildBillingTopBar(context);
        case 4:
          return _buildProfileTopBar(context);
        default:
          return const SizedBox.shrink();
      }
    }
  }

  Widget _buildHomeTopBar(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final announcements = state is HomeLoaded ? state.dashboard.announcements : null;
        return HomeTopBar(
          profile: profile,
          schoolColor: schoolColor,
          announcements: announcements,
          onSchoolTap: () => _handleSchoolTap(context),
          onNotificationTap: () => _handleNotificationTap(context, announcements),
        );
      },
    );
  }

  Widget _buildAttendanceTopBar(BuildContext context) {
    return AttendanceTopBar(
      profile: profile,
      schoolColor: schoolColor,
      isStudent: _isStudent,
      onRefresh: () {
        if (onAttendanceRefresh != null) {
          onAttendanceRefresh!();
        } else {
          context.read<AttendanceCubit>().loadAttendances(forceRefreshMeta: true);
        }
      },
    );
  }

  Widget _buildAcademicTopBar(BuildContext context) {
    return AcademicTopBar(
      profile: profile,
      schoolColor: schoolColor,
      onReportTap: () => _handleReportTap(context),
      gpa: 88.6,
      academicPeriod: 'Semester Genap 2025/2026',
    );
  }

  Widget _buildBillingTopBar(BuildContext context) {
    return BlocBuilder<BillingCubit, BillingState>(
      builder: (context, state) {
        final unpaidCount = state is BillingLoaded
            ? state.invoices.where((i) => !i.isPaid).length
            : 0;
        return BillingTopBar(
          profile: profile,
          schoolColor: schoolColor,
          unpaidCount: unpaidCount,
          onRefresh: () {
            if (onBillingRefresh != null) {
              onBillingRefresh!();
            } else {
              context.read<BillingCubit>().loadInvoices();
            }
          },
        );
      },
    );
  }

  Widget _buildProfileTopBar(BuildContext context) {
    return ProfileTopBar(
      profile: profile,
      schoolColor: schoolColor,
      onDigitalCardTap: () => _handleDigitalCardTap(context),
      onSettingsTap: () => _handleSettingsTap(context),
      onShareQrTap: () => _handleShareQrTap(context),
    );
  }
}
