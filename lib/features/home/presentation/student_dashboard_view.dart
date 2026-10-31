import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/models/user_model.dart';
import '../logic/home_cubit.dart';
import 'widgets/student_announcements_section.dart';
import 'widgets/student_attendance_summary_card.dart';
import 'widgets/student_quick_services.dart';
import 'widgets/student_smart_assistant_banner.dart';
import 'widgets/student_smart_card.dart';

/// StudentDashboardView selaras 1:1 dengan Google Stitch Design ("Vintech School Dashboard").
/// Mengimplementasikan arsitektur modular Bento Grid:
/// 0. Asisten Cerdas Kontekstual ([StudentSmartAssistantBanner])
/// 1. Digital Student Smart Card ([StudentSmartCard])
/// 2. Layanan Cepat ([StudentQuickServices])
/// 3. Ringkasan Kehadiran Semester Ini ([StudentAttendanceSummaryCard])
/// 4. Pengumuman Sekolah ([StudentAnnouncementsSection])
class StudentDashboardView extends StatelessWidget {
  final UserProfileResponse profile;
  final Function(int tabIndex) onNavigateTab;
  final ScrollController? scrollController;

  const StudentDashboardView({
    super.key,
    required this.profile,
    required this.onNavigateTab,
    this.scrollController,
  });

  Color get _schoolColor {
    final hex = profile.activeSchool?.primaryColor;
    if (hex != null && hex.isNotEmpty) {
      return AppTheme.parseHexColor(hex);
    }
    return const Color(0xFF004AC6); // Stitch Primary Royal Blue
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // Stitch Surface Background
      body: RefreshIndicator(
        color: _schoolColor,
        onRefresh: () => context.read<HomeCubit>().loadDashboard(),
        child: SingleChildScrollView(
          controller: scrollController,
          key: const PageStorageKey('student_dashboard_scroll_view'),
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bento 0: Asisten Cerdas Kontekstual (Waktu KBM, Presensi, SPP, Tugas)
              StudentSmartAssistantBanner(
                profile: profile,
                schoolColor: _schoolColor,
                onAttendanceTap: () => onNavigateTab(1),
                onAcademicTap: () => onNavigateTab(2),
                onBillingTap: () => onNavigateTab(3),
              ),

              const SizedBox(height: 18),

              // Bento 1: Digital Student Smart Card
              StudentSmartCard(
                profile: profile,
                schoolColor: _schoolColor,
              ),

              const SizedBox(height: 18),

              // Bento 2: Quick Service 4-Grid Action Buttons
              StudentQuickServices(
                onNavigateTab: onNavigateTab,
              ),

              const SizedBox(height: 18),

              // Bento 3: Attendance Summary Card
              StudentAttendanceSummaryCard(
                onNavigateTab: onNavigateTab,
              ),

              const SizedBox(height: 20),

              // Bento 4: School Announcements Feed
              const StudentAnnouncementsSection(),
            ],
          ),
        ),
      ),
    );
  }
}
