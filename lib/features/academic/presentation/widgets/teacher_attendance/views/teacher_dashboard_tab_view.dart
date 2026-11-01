import 'package:flutter/material.dart';
import 'package:vintech_school_mobile/features/academic/data/models/attendance_model.dart';
import 'package:vintech_school_mobile/features/auth/data/models/user_model.dart';

import '../components/teacher_follow_up_section.dart';
import '../components/teacher_gateway_sync_footer.dart';
import '../components/teacher_greeting_card.dart';
import '../components/teacher_metrics_bento_card.dart';
import '../components/teacher_quick_actions_grid.dart';
import '../components/teacher_weekly_trend_card.dart';

/// Tab 1 View: Dashboard Presensi Guru (Stitch Bento Grid)
class TeacherDashboardTabView extends StatelessWidget {
  final UserProfileResponse profile;
  final List<AttendanceModel> allRecords;
  final Color schoolColor;
  final ScrollController? scrollController;
  final Future<void> Function() onRefresh;

  const TeacherDashboardTabView({
    super.key,
    required this.profile,
    required this.allRecords,
    required this.schoolColor,
    this.scrollController,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: schoolColor,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        controller: scrollController,
        key: const PageStorageKey('attendance_teacher_dashboard_scroll'),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card 1: Teacher Greeting & Date Banner
            TeacherGreetingCard(profile: profile),
            const SizedBox(height: 14),

            // Card 2: Key Attendance Metrics Bento Card
            TeacherMetricsBentoCard(
              allRecords: allRecords,
              schoolColor: schoolColor,
            ),
            const SizedBox(height: 18),

            // Card 3: Quick Actions Grid (Aksi Cepat Guru)
            TeacherQuickActionsGrid(profile: profile, schoolColor: schoolColor),
            const SizedBox(height: 18),

            // Card 4: Weekly Trend Chart (Tren Kehadiran Mingguan)
            const TeacherWeeklyTrendCard(),
            const SizedBox(height: 18),

            // Card 5: Attention & Follow-Up (Perlu Tindak Lanjut Wali Kelas)
            const TeacherFollowUpSection(),
            const SizedBox(height: 18),

            // Card 6: Operational Sync & Gateway Footer
            TeacherGatewaySyncFooter(onRefresh: onRefresh),
          ],
        ),
      ),
    );
  }
}
