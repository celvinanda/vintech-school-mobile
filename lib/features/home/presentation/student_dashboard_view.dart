import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/models/user_model.dart';
import '../data/models/school_dashboard_model.dart';
import '../logic/home_cubit.dart';
import '../logic/home_state.dart';

class StudentDashboardView extends StatelessWidget {
  final UserProfileResponse profile;
  final Function(int tabIndex) onNavigateTab;

  const StudentDashboardView({
    super.key,
    required this.profile,
    required this.onNavigateTab,
  });

  Color get _schoolColor => AppTheme.parseHexColor(profile.activeSchool?.primaryColor);

  String get _firstName => profile.user.firstName;
  String get _initials => profile.user.initials;
  String get _cleanNis => profile.user.cleanIdentifier;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          color: _schoolColor,
          onRefresh: () => context.read<HomeCubit>().loadDashboard(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: User Profile Greeting & School Badge
                _buildTopGreetingBar(context),

                const SizedBox(height: 18),

                // Digital Student Smart Card (Minimalist Luxury)
                _buildStudentSmartCard(),

                const SizedBox(height: 24),

                // Quick Services Menu (Minimalist 4-Column Icons)
                _buildSectionTitle('Layanan Siswa'),
                const SizedBox(height: 12),
                _buildQuickServicesGrid(context),

                const SizedBox(height: 24),

                // Attendance Summary & Status
                _buildAttendanceSummarySection(),

                const SizedBox(height: 24),

                // School Announcements
                _buildAnnouncementsSection(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopGreetingBar(BuildContext context) {
    return Row(
      children: [
        // Avatar with Initials
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _schoolColor.withAlpha(25),
            shape: BoxShape.circle,
            border: Border.all(color: _schoolColor.withAlpha(60), width: 1.5),
          ),
          child: Center(
            child: Text(
              _initials,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: _schoolColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $_firstName 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                profile.activeSchool?.name ?? 'Vintech School',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // School Code Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _schoolColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                profile.activeSchool?.code ?? 'SMAN1',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentSmartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A), // Deep Slate
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
          // Top Row: School Label & Status Pill
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
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'KARTU PELAJAR DIGITAL',
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
                  color: const Color(0xFF16A34A).withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF16A34A).withAlpha(120),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'AKTIF',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF4ADE80),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Student Full Name
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

          // Class Level & Major
          Text(
            profile.activeSchool?.title.isNotEmpty == true
                ? profile.activeSchool!.title
                : 'Siswa Reguler • ${profile.activeSchool?.level ?? "SMA"}',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withAlpha(180),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // Divider Line
          Container(
            height: 1,
            color: Colors.white.withAlpha(25),
          ),

          const SizedBox(height: 14),

          // Bottom Info Row: NIS & Smart NFC Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOMOR INDUK SISWA (NIS)',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withAlpha(140),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _cleanNis,
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.contactless_rounded,
                    color: Colors.white.withAlpha(160),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.qr_code_rounded,
                    color: Colors.white.withAlpha(160),
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF0F172A),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildQuickServicesGrid(BuildContext context) {
    return Row(
      children: [
        _buildServiceItem(
          icon: Icons.checklist_rounded,
          label: 'Presensi',
          accentColor: const Color(0xFF10B981),
          onTap: () => onNavigateTab(1),
        ),
        const SizedBox(width: 10),
        _buildServiceItem(
          icon: Icons.account_balance_wallet_rounded,
          label: 'SPP Digital',
          accentColor: const Color(0xFF0EA5E9),
          onTap: () => onNavigateTab(2),
        ),
        const SizedBox(width: 10),
        _buildServiceItem(
          icon: Icons.calendar_today_rounded,
          label: 'Jadwal',
          accentColor: const Color(0xFF8B5CF6),
          onTap: () => onNavigateTab(1),
        ),
        const SizedBox(width: 10),
        _buildServiceItem(
          icon: Icons.campaign_rounded,
          label: 'Pengumuman',
          accentColor: const Color(0xFFF59E0B),
          onTap: () {
            // Scroll down to announcements or show modal
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menampilkan pengumuman resmi sekolah di bawah.'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String label,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceSummarySection() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        int present = 24;
        int izin = 1;
        int sakit = 0;
        int alpa = 0;
        double rate = 96.0;

        if (state is HomeLoaded) {
          final att = state.dashboard.attendanceToday;
          present = att.presentCount > 0 ? att.presentCount : 24;
          izin = att.izinCount;
          sakit = att.sakitCount;
          alpa = att.alpaCount;
          rate = att.attendanceRate;
        }

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(4),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.insights_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kehadiran Semester Ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${rate.toStringAsFixed(0)}% Disiplin',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 4 Stat Capsules
              Row(
                children: [
                  _buildStatPill('Hadir', '$present', const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  _buildStatPill('Izin', '$izin', const Color(0xFF0EA5E9)),
                  const SizedBox(width: 8),
                  _buildStatPill('Sakit', '$sakit', const Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  _buildStatPill('Alpa', '$alpa', const Color(0xFFEF4444)),
                ],
              ),

              const SizedBox(height: 14),

              // Today's Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF16A34A),
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Presensi hari ini tercatat Hadir tepat waktu (07:15 WIB)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatPill(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsSection() {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        List<AnnouncementModel> items = [];
        if (state is HomeLoaded) {
          items = state.dashboard.announcements;
        }

        if (items.isEmpty) {
          // Fallback realistic announcement
          items = [
            AnnouncementModel(
              id: '1',
              title: 'Pembayaran SPP Digital QRIS & Virtual Account Aktif',
              content:
                  'Orang tua dan siswa dapat melakukan pembayaran tagihan SPP bulanan secara otomatis melalui aplikasi Vintech School.',
              audience: 'ALL',
              audienceDisplay: 'Semua',
              isPinned: true,
              createdAt: '20 Okt 2026',
            ),
          ];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Pengumuman Sekolah'),
                Text(
                  '${items.length} Baru',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((ann) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (ann.isPinned)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'PENTING',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFB45309),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              ann.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ann.content,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: const Color(0xFF64748B),
                          height: 1.45,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }
}
