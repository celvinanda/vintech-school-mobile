import 'package:flutter/material.dart';
import 'package:vintech_school_mobile/features/academic/data/models/attendance_model.dart';
import 'package:vintech_school_mobile/features/auth/data/models/user_model.dart';

import 'teacher_attendance/components/teacher_mode_switcher.dart';
import 'teacher_attendance/views/teacher_class_status_view.dart';
import 'teacher_attendance/views/teacher_dashboard_tab_view.dart';

/// Dashboard Presensi Khusus Akun Guru & Staf
/// Selaras 1:1 dengan Google Stitch Design Canvas: "Dashboard Presensi - Vintech School"
/// Mengimplementasikan arsitektur modular Clean Architecture:
/// - [TeacherModeSwitcher]: Pengalih mode antara Dashboard Presensi dan Status Presensi Kelas
/// - [TeacherDashboardTabView]: Bento Grid Presensi Guru (6 Bento Cards modular)
/// - [TeacherClassStatusView]: Monitoring Pengisian Presensi Seluruh Rombel & Detail Siswa Rombel
class AttendanceTeacherDashboardView extends StatefulWidget {
  final UserProfileResponse profile;
  final List<AttendanceModel> allRecords;
  final List<AttendanceModel> filteredRecords;
  final TextEditingController searchController;
  final String statusFilter;
  final Color schoolColor;
  final ScrollController? scrollController;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onSearchChanged;
  final Future<void> Function() onRefresh;

  const AttendanceTeacherDashboardView({
    super.key,
    required this.profile,
    required this.allRecords,
    required this.filteredRecords,
    required this.searchController,
    required this.statusFilter,
    required this.schoolColor,
    this.scrollController,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onRefresh,
  });

  @override
  State<AttendanceTeacherDashboardView> createState() =>
      _AttendanceTeacherDashboardViewState();
}

class _AttendanceTeacherDashboardViewState
    extends State<AttendanceTeacherDashboardView> {
  // Mode View: 0 = Dashboard Presensi (Stitch Bento), 1 = Status Presensi Kelas
  int _activeViewIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode Switcher Header: Dashboard Presensi vs Status Presensi Kelas
        TeacherModeSwitcher(
          activeIndex: _activeViewIndex,
          schoolColor: widget.schoolColor,
          onTabChanged: (index) {
            setState(() => _activeViewIndex = index);
          },
        ),

        // Main Content Area
        Expanded(
          child: _activeViewIndex == 1
              ? TeacherClassStatusView(
                  profile: widget.profile,
                  allRecords: widget.allRecords,
                  schoolColor: widget.schoolColor,
                  scrollController: widget.scrollController,
                  onRefresh: widget.onRefresh,
                )
              : TeacherDashboardTabView(
                  profile: widget.profile,
                  allRecords: widget.allRecords,
                  schoolColor: widget.schoolColor,
                  scrollController: widget.scrollController,
                  onRefresh: widget.onRefresh,
                ),
        ),
      ],
    );
  }
}
