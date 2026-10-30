import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/models/user_model.dart';
import '../logic/home_cubit.dart';
import '../logic/home_state.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/student_announcements_section.dart';
import 'widgets/student_attendance_summary_card.dart';
import 'widgets/student_quick_services.dart';
import 'widgets/student_smart_card.dart';

/// StudentDashboardView selaras 1:1 dengan Google Stitch Design ("Vintech School Dashboard").
/// Mengimplementasikan arsitektur modular Bento Grid:
/// 1. Sticky Top Bar ([HomeTopBar])
/// 2. Digital Student Smart Card ([StudentSmartCard])
/// 3. Layanan Cepat ([StudentQuickServices])
/// 4. Ringkasan Kehadiran Semester Ini ([StudentAttendanceSummaryCard])
/// 5. Pengumuman Sekolah ([StudentAnnouncementsSection])
class StudentDashboardView extends StatelessWidget {
  final UserProfileResponse profile;
  final Function(int tabIndex) onNavigateTab;

  const StudentDashboardView({
    super.key,
    required this.profile,
    required this.onNavigateTab,
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Sticky Pinned Top Bar (Stitch Header)
            RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
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
                child: BlocBuilder<HomeCubit, HomeState>(
                  builder: (context, state) {
                    final announcements = state is HomeLoaded ? state.dashboard.announcements : null;
                    return HomeTopBar(
                      profile: profile,
                      schoolColor: _schoolColor,
                      announcements: announcements,
                    );
                  },
                ),
              ),
            ),

            // 2. High-Performance Scrollable Dashboard Body
            Expanded(
              child: RefreshIndicator(
                color: _schoolColor,
                onRefresh: () => context.read<HomeCubit>().loadDashboard(),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
            ),
          ],
        ),
      ),
    );
  }
}
