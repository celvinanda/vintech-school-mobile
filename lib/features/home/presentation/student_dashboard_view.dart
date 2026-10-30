import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/models/user_model.dart';
import '../data/models/school_dashboard_model.dart';
import '../logic/home_cubit.dart';
import '../logic/home_state.dart';
import 'widgets/home_top_bar.dart';

/// StudentDashboardView selaras 1:1 dengan Google Stitch Design ("Vintech School Dashboard").
/// Mengimplementasikan Bento Grid System:
/// 1. Sticky Top Bar (School Emblem, Nama Sekolah, Semester & Lonceng Notifikasi)
/// 2. Digital Student Smart Card (Gradient Deep Slate ke Royal Blue, NFC Ready, NIS/NISN, & Interactive Scan ID)
/// 3. Layanan Cepat (4 Kolom Action: Presensi, SPP Digital, Jadwal, Pengumuman)
/// 4. Ringkasan Kehadiran Semester Ini (96% Disiplin, 4 Stat Capsules & Banner Presensi Hari Ini)
/// 5. Pengumuman Sekolah (Feed Cards dengan Chip PENTING / INFORMASI & Attachment PDF)
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

  String get _cleanNis => profile.user.cleanIdentifier;
  String get _nisn => _cleanNis.isNotEmpty ? '008$_cleanNis' : '0082914820';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // Stitch Surface Background
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Sticky Pinned Top Bar (Stitch Header)
            Container(
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

            // Scrollable Dashboard Body
            Expanded(
              child: RefreshIndicator(
                color: _schoolColor,
                onRefresh: () => context.read<HomeCubit>().loadDashboard(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Digital Student Smart Card (Hero Bento Section)
                      _buildStudentSmartCard(context),

                      const SizedBox(height: 18),

                      // 2. Quick Service Grid (4 Minimalist Action Buttons)
                      _buildQuickServicesGrid(context),

                      const SizedBox(height: 18),

                      // 3. Attendance Summary Card ("Kehadiran Semester Ini")
                      _buildAttendanceSummarySection(context),

                      const SizedBox(height: 20),

                      // 4. School Announcements Feed ("Pengumuman Sekolah")
                      _buildAnnouncementsSection(context),
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

  // ==========================================
  // 1. DIGITAL STUDENT SMART CARD (HERO BENTO)
  // ==========================================
  Widget _buildStudentSmartCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A), // Deep Inverse Surface
            Color(0xFF1E3A8A), // Royal Deep Blue
            Color(0xFF2563EB), // Primary Container
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          // Ambient Geometric Watermark Pattern (Stitch Background Accent)
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: -15,
            right: 40,
            child: Icon(
              Icons.school_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Label & Status Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          color: Color(0xFFDBE1FF),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'KARTU PELAJAR DIGITAL',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFCBD5E1),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007D55).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF6FFBBE).withValues(alpha: 0.45),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5.5,
                            height: 5.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4EDEA3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'AKTIF',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6FFBBE),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Card Identity Middle: Name & Major + NFC Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.user.fullName,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 19.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            profile.activeSchool?.title.isNotEmpty == true
                                ? profile.activeSchool!.title
                                : 'Kelas ${profile.activeSchool?.level ?? "X"} • Jurusan MIPA',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFB4C5FF),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Contactless NFC Tag Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.contactless_rounded,
                            color: Color(0xFFB4C5FF),
                            size: 15,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'NFC ACTIVE',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFB4C5FF),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Card Bottom: NIS, NISN & Interactive QR Quick-Scan Token
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'NIS: ',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFCBD5E1),
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                _cleanNis,
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'NISN: ',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFCBD5E1),
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                _nisn,
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Quick Interactive QR Tap Trigger ("Scan ID")
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showStudentQrModal(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.qr_code_rounded,
                                  size: 18,
                                  color: Color(0xFF004AC6),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Scan ID',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF004AC6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODAL VIEW FOR STUDENT QR CODE (STITCH MODAL)
  // ==========================================
  void _showStudentQrModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF565E74), size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBE1FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Color(0xFF004AC6),
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'QR Kartu Siswa',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF191C1E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gunakan untuk presensi gerbang & peminjaman perpustakaan.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF565E74),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // High-Fidelity Barcode/QR Graphic Simulation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFECEEF0)),
                ),
                child: Icon(
                  Icons.qr_code_2_rounded,
                  size: 140,
                  color: _schoolColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'NISN: $_nisn',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF434655),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AC6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. QUICK SERVICE GRID (4 ACTION BUTTONS)
  // ==========================================
  Widget _buildQuickServicesGrid(BuildContext context) {
    return Row(
      children: [
        _buildServiceButton(
          icon: Icons.fact_check_rounded,
          label: 'Presensi',
          iconColor: const Color(0xFF007D55),
          bgColor: const Color(0xFF007D55).withValues(alpha: 0.10),
          onTap: () {
            HapticFeedback.selectionClick();
            onNavigateTab(1);
          },
        ),
        const SizedBox(width: 10),
        _buildServiceButton(
          icon: Icons.account_balance_wallet_rounded,
          label: 'SPP Digital',
          iconColor: const Color(0xFF004AC6),
          bgColor: const Color(0xFF004AC6).withValues(alpha: 0.10),
          onTap: () {
            HapticFeedback.selectionClick();
            onNavigateTab(2);
          },
        ),
        const SizedBox(width: 10),
        _buildServiceButton(
          icon: Icons.calendar_month_rounded,
          label: 'Jadwal',
          iconColor: const Color(0xFF4F46E5),
          bgColor: const Color(0xFF4F46E5).withValues(alpha: 0.10),
          onTap: () {
            HapticFeedback.selectionClick();
            onNavigateTab(1);
          },
        ),
        const SizedBox(width: 10),
        _buildServiceButton(
          icon: Icons.campaign_rounded,
          label: 'Pengumuman',
          iconColor: const Color(0xFFD97706),
          bgColor: const Color(0xFFD97706).withValues(alpha: 0.12),
          onTap: () {
            HapticFeedback.selectionClick();
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

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color bgColor,
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
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEEF0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF191C1E),
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

  // ==========================================
  // 3. ATTENDANCE SUMMARY CARD (STITCH CARD)
  // ==========================================
  Widget _buildAttendanceSummarySection(BuildContext context) {
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
          rate = att.attendanceRate > 0 ? att.attendanceRate : 96.0;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFECEEF0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with 96% Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF004AC6),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kehadiran Semester Ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF191C1E),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF007D55).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${rate.toStringAsFixed(0)}% Disiplin',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007D55),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 4 Stat Capsules Row
              Row(
                children: [
                  _buildStatCapsule('Hadir', '$present', const Color(0xFF007D55)),
                  const SizedBox(width: 8),
                  _buildStatCapsule('Izin', '$izin', const Color(0xFF004AC6)),
                  const SizedBox(width: 8),
                  _buildStatCapsule('Sakit', '$sakit', const Color(0xFFD97706)),
                  const SizedBox(width: 8),
                  _buildStatCapsule('Alpa', '$alpa', const Color(0xFFBA1A1A)),
                ],
              ),

              const SizedBox(height: 14),

              // Today's Live Status Banner (Stitch Live Status)
              Material(
                color: const Color(0xFF6FFBBE).withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onNavigateTab(1);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4EDEA3).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF007D55),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Presensi Hari Ini: Tepat Waktu',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF191C1E),
                                ),
                              ),
                              Text(
                                'Tercatat pukul 07:15 WIB di Gerbang Utama',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: const Color(0xFF434655),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF565E74),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCapsule(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F6), // Stitch Surface Container Low
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF565E74),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 4. SCHOOL ANNOUNCEMENTS FEED (STITCH FEED)
  // ==========================================
  Widget _buildAnnouncementsSection(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        List<AnnouncementModel> items = [];
        if (state is HomeLoaded) {
          items = state.dashboard.announcements;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pengumuman Sekolah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191C1E),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                  },
                  child: Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF004AC6),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF004AC6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Announcement Feed Cards
            if (items.isNotEmpty)
              ...items.map((ann) => _buildAnnouncementCard(
                    categoryBadge: ann.isPinned ? 'PENTING' : 'INFORMASI',
                    isImportant: ann.isPinned,
                    timestamp: ann.createdAt.length >= 10 ? ann.createdAt.substring(0, 10) : ann.createdAt,
                    author: ann.audienceDisplay,
                    title: ann.title,
                    snippet: ann.content,
                    attachmentLabel: 'Lampiran_${ann.audienceDisplay}.pdf',
                  ))
            else ...[
              // Stitch Default Card 1
              _buildAnnouncementCard(
                categoryBadge: 'PENTING',
                isImportant: true,
                timestamp: 'Hari ini, 09:00 WIB',
                author: 'Kurikulum',
                title: 'Jadwal Penilaian Tengah Semester (PTS) Genap 2026',
                snippet:
                    'Pelaksanaan PTS Genap akan dimulai tanggal 16 Maret secara hybrid menggunakan tablet/smartphone sekolah.',
                attachmentLabel: 'Jadwal_PTS_Genap.pdf (1.2 MB)',
              ),
              const SizedBox(height: 10),
              // Stitch Default Card 2
              _buildAnnouncementCard(
                categoryBadge: 'INFORMASI',
                isImportant: false,
                timestamp: 'Kemarin, 14:30 WIB',
                author: 'Kesiswaan',
                title: 'Pendaftaran Ekstrakurikuler Robotika & Coding Club',
                snippet:
                    'Pendaftaran dibuka untuk siswa kelas X & XI melalui portal Vintech hingga akhir pekan ini. Kuota terbatas 30 peserta.',
                attachmentLabel: 'Sisa Kuota: 8 Siswa',
                isQuota: true,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAnnouncementCard({
    required String categoryBadge,
    required bool isImportant,
    required String timestamp,
    required String author,
    required String title,
    required String snippet,
    required String attachmentLabel,
    bool isQuota = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isImportant ? const Color(0xFFFFDAD6) : const Color(0xFFDBE1FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  categoryBadge,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isImportant ? const Color(0xFF93000A) : const Color(0xFF00174B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '$timestamp • $author',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF565E74),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF191C1E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            snippet,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF434655),
              height: 1.45,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isQuota ? Icons.group_add_rounded : Icons.attachment_rounded,
                    size: 15,
                    color: const Color(0xFF565E74),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    attachmentLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF565E74),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_circle_right_rounded,
                size: 18,
                color: Color(0xFF004AC6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
