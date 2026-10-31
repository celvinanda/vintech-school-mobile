import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../academic/presentation/attendance_entry_sheet.dart';
import '../../auth/data/models/user_model.dart';
import '../logic/home_cubit.dart';
import '../logic/home_state.dart';
import 'widgets/home_top_bar.dart';

class TeacherDashboardView extends StatelessWidget {
  final UserProfileResponse profile;
  final Function(int tabIndex) onNavigateTab;
  final ScrollController? scrollController;

  const TeacherDashboardView({
    super.key,
    required this.profile,
    required this.onNavigateTab,
    this.scrollController,
  });

  Color get _schoolColor => AppTheme.parseHexColor(profile.activeSchool?.primaryColor);

  String get _cleanNip => profile.user.cleanIdentifier;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB),
        body: Column(
          children: [
            // Sticky Pinned Top Bar (Menyatu tanpa jeda dengan Bar Notifikasi)
            RepaintBoundary(
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
                    child: BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                        return HomeTopBar(
                          profile: profile,
                          schoolColor: _schoolColor,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Scrollable Dashboard Body
            Expanded(
              child: RefreshIndicator(
                color: _schoolColor,
                onRefresh: () => context.read<HomeCubit>().loadDashboard(),
                child: SingleChildScrollView(
                  controller: scrollController,
                  key: const PageStorageKey('teacher_dashboard_scroll_view'),
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teacher Smart Digital Card
                      _buildTeacherSmartCard(),

                      const SizedBox(height: 20),

                      // Action Banner: Input Presensi Siswa Cepat
                      _buildQuickAttendanceAction(context),

                      const SizedBox(height: 24),

                      // Real-time School Metrics
                      _buildSchoolStatisticsSection(),
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

  Widget _buildTeacherSmartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            Color.lerp(const Color(0xFF0F172A), _schoolColor, 0.45)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.badge_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    profile.activeSchool?.cardBadgeTitle ?? 'KARTU TENAGA PENDIDIK',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withAlpha(190),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withAlpha(120),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  (profile.activeSchool?.isAdmin == true) ? 'ADMIN AKTIF' : 'GURU AKTIF',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF93C5FD),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            profile.user.fullName,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            profile.activeSchool?.title.isNotEmpty == true
                ? profile.activeSchool!.title
                : 'Tenaga Pendidik & Pengajar',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withAlpha(180),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withAlpha(25),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOMOR INDUK PEGAWAI (NIP)',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withAlpha(140),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _cleanNip,
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.fingerprint_rounded,
                color: Colors.white70,
                size: 26,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAttendanceAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _schoolColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.edit_calendar_rounded, color: _schoolColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catat Presensi Siswa',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Input kehadiran rombel kelas harian',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _schoolColor,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const AttendanceEntrySheet(),
              );
            },
            child: const Text('Input', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolStatisticsSection() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        int totalStudents = 120;
        int totalTeachers = 18;
        int totalClassrooms = 6;
        double attRate = 98.0;

        if (state is HomeLoaded) {
          final d = state.dashboard;
          totalStudents = d.totalStudents;
          totalTeachers = d.totalTeachers;
          totalClassrooms = d.totalClassrooms;
          attRate = d.attendanceToday.attendanceRate;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistik Sekolah',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Total Siswa',
                    value: '$totalStudents',
                    icon: Icons.groups_rounded,
                    accentColor: const Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Total Guru',
                    value: '$totalTeachers',
                    icon: Icons.person_pin_rounded,
                    accentColor: const Color(0xFF0F766E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Rombel Kelas',
                    value: '$totalClassrooms',
                    icon: Icons.class_outlined,
                    accentColor: const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Presensi Hari Ini',
                    value: '${attRate.toStringAsFixed(0)}%',
                    icon: Icons.check_circle_outline_rounded,
                    accentColor: const Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              Icon(icon, color: accentColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
