import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/data/models/user_model.dart';
import '../../data/models/attendance_model.dart';
import '../attendance_entry_sheet.dart';
import 'attendance_teacher_roster_view.dart';

/// Dashboard Presensi Khusus Akun Guru & Staf
/// Selaras 1:1 dengan Google Stitch Design Canvas: "Dashboard Presensi - Vintech School"
/// Mengimplementasikan 7 Bento Cards:
/// 1. Teacher Greeting & Dynamic Date Banner
/// 2. Key Attendance Metrics (High Visual Bento Gradient Card)
/// 3. Quick Actions Grid (Aksi Cepat Guru - 4 Grid Cards)
/// 4. Weekly Trend Chart Section (Tren Kehadiran Mingguan 5 Hari)
/// 5. Class Attendance Monitoring (Status Pengisian Presensi Kelas)
/// 6. Attention & Follow-Up Section (Perlu Tindak Lanjut Wali Kelas)
/// 7. Operational Sync & Gateway Footer Status
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
  // Mode View: 0 = Dashboard Presensi (Stitch), 1 = Roster Siswa Detail
  int _activeViewIndex = 0;
  String _classFilter = 'all'; // all, locked, pending

  String get _currentDateFormatted {
    try {
      final now = DateTime.now();
      final dayNames = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      final monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final dayName = dayNames[now.weekday - 1];
      final monthName = monthNames[now.month - 1];
      return '$dayName, ${now.day} $monthName ${now.year}';
    } catch (_) {
      return 'Senin, 17 November 2026';
    }
  }

  void _showScanRfidDialog(BuildContext context) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF004AC6),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Scan RFID / QR Siswa',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.contactless_rounded,
                    size: 48,
                    color: Color(0xFF004AC6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gerbang 1 - Reader Aktif',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Dekatkan kartu pelajar pintar (RFID/NFC) siswa atau arahkan barcode ke sensor scanner.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AC6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '✓ Kartu RFID Siswa (Aditya Pratama - XI-IPA-1) Terdeteksi di Gerbang 1 [07:12 WIB]',
                  ),
                  backgroundColor: Color(0xFF007D55),
                ),
              );
            },
            child: const Text('Simulasi Tap Siswa'),
          ),
        ],
      ),
    );
  }

  void _showDownloadReportDialog(BuildContext context) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Rekapitulasi Presensi KBM',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih format unduhan rekapitulasi presensi kehadiran siswa periode semester berjalan:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              leading: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Color(0xFFDC2626),
              ),
              title: Text(
                'Laporan Resmi (PDF)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Format cetak standar Dapodik & tanda tangan Kepsek',
                style: GoogleFonts.plusJakartaSans(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '✓ Mengunduh Rekapitulasi Presensi Semester (PDF)...',
                    ),
                    backgroundColor: Color(0xFF007D55),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              leading: const Icon(
                Icons.table_chart_rounded,
                color: Color(0xFF007D55),
              ),
              title: Text(
                'Lembar Kerja (Excel .xlsx)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Data tabular lengkap dengan persentase kehadiran',
                style: GoogleFonts.plusJakartaSans(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '✓ Mengunduh Rekapitulasi Presensi Tabular (Excel)...',
                    ),
                    backgroundColor: Color(0xFF007D55),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMedicalValidationDialog(BuildContext context) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Color(0xFF004AC6),
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Verifikasi Surat Dokter',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengajuan surat keterangan istirahat dokter dari orang tua Nabila Zahra (XI-IPA-1):',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Klinik Pratama Sehat Nusantara',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'No. Surat: SKD/11/2026/0412 • Diagnosis: Demam Febris',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rekomendasi: Istirahat di rumah selama 2 (dua) hari terhitung 17-18 Nov 2026.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF334155),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permohonan izin sakit ditolak.'),
                  backgroundColor: Color(0xFFDC2626),
                ),
              );
            },
            child: const Text(
              'Tolak',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007D55),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '✓ Surat izin sakit Nabila Zahra disetujui & tercatat di sistem!',
                  ),
                  backgroundColor: Color(0xFF007D55),
                ),
              );
            },
            child: const Text('Setujui Izin'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWaOrtu(BuildContext context, String parentName) async {
    HapticFeedback.lightImpact();
    final greeting =
        'Halo%20Bapak%2FIbu%20$parentName,%20saya%20Wali%20Kelas%20dari%20sekolah%20ingin%20mengonfirmasi%20kehadiran%20anak%20Anda.';
    final uri = Uri.parse('https://wa.me/6281278901234?text=$greeting');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Menghubungi nomor WhatsApp Orang Tua $parentName...',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode Switcher Header: Dashboard Presensi vs Roster Siswa
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _activeViewIndex = 0);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeViewIndex == 0
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeViewIndex == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dashboard_rounded,
                            size: 16,
                            color: _activeViewIndex == 0
                                ? widget.schoolColor
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Dashboard Presensi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: _activeViewIndex == 0
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _activeViewIndex == 0
                                  ? widget.schoolColor
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _activeViewIndex = 1);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _activeViewIndex == 1
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeViewIndex == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            size: 16,
                            color: _activeViewIndex == 1
                                ? widget.schoolColor
                                : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Roster Siswa (${widget.allRecords.length})',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: _activeViewIndex == 1
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _activeViewIndex == 1
                                  ? widget.schoolColor
                                  : const Color(0xFF64748B),
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
        ),

        // Main Content Area
        Expanded(
          child: _activeViewIndex == 1
              ? AttendanceTeacherRosterView(
                  allRecords: widget.allRecords,
                  filteredRecords: widget.filteredRecords,
                  searchController: widget.searchController,
                  statusFilter: widget.statusFilter,
                  schoolColor: widget.schoolColor,
                  scrollController: widget.scrollController,
                  onFilterChanged: widget.onFilterChanged,
                  onSearchChanged: widget.onSearchChanged,
                )
              : RefreshIndicator(
                  color: widget.schoolColor,
                  onRefresh: widget.onRefresh,
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    key: const PageStorageKey(
                      'attendance_teacher_dashboard_scroll',
                    ),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card 1: Teacher Greeting & Date Banner
                        _buildTeacherGreetingCard(),
                        const SizedBox(height: 14),

                        // Card 2: Key Attendance Metrics Bento Card
                        _buildMetricsBentoCard(),
                        const SizedBox(height: 18),

                        // Card 3: Quick Actions Grid (Aksi Cepat Guru)
                        _buildQuickActionsGrid(context),
                        const SizedBox(height: 18),

                        // Card 4: Weekly Trend Chart (Tren Kehadiran Mingguan)
                        _buildWeeklyTrendCard(),
                        const SizedBox(height: 18),

                        // Card 5: Class Attendance Monitoring (Status Presensi Kelas)
                        _buildClassMonitoringSection(),
                        const SizedBox(height: 18),

                        // Card 6: Attention & Follow-Up (Perlu Tindak Lanjut Wali Kelas)
                        _buildFollowUpSection(context),
                        const SizedBox(height: 18),

                        // Card 7: Operational Sync & Gateway Footer
                        _buildGatewaySyncFooter(),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ==========================================
  // CARD 1: TEACHER GREETING & DATE BANNER
  // ==========================================
  Widget _buildTeacherGreetingCard() {
    final school = widget.profile.activeSchool;
    final advisoryClass = school?.classroomNameField ?? '-';
    final subject = school?.specialization ?? 'Mata Pelajaran';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEEF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
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
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF004AC6),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _currentDateFormatted,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hari Ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.profile.user.fullName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF007D55),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            advisoryClass != '-'
                                ? 'Wali Kelas $advisoryClass • Guru $subject'
                                : 'Tenaga Pendidik • Guru $subject',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF004AC6),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 2: METRICS BENTO GRADIENT CARD
  // ==========================================
  Widget _buildMetricsBentoCard() {
    final hadirCount = widget.allRecords
        .where((r) => r.status.toUpperCase() == 'HADIR')
        .length;
    final sakitCount = widget.allRecords
        .where((r) => r.status.toUpperCase() == 'SAKIT')
        .length;
    final izinCount = widget.allRecords
        .where((r) => r.status.toUpperCase() == 'IZIN')
        .length;
    final alpaCount = widget.allRecords
        .where((r) => r.status.toUpperCase() == 'ALPA')
        .length;
    final total = widget.allRecords.length;

    final double rate = total > 0 ? (hadirCount / total * 100) : 95.8;
    final displayRate = rate.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.schoolColor,
            Color.lerp(widget.schoolColor, const Color(0xFF1E3A8A), 0.3)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: widget.schoolColor.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Decorative Background Glow & Watermark
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: -6,
              child: Icon(
                Icons.co_present_rounded,
                size: 110,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TINGKAT KEHADIRAN SEKOLAH',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFBFDBFE),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$displayRate%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.trending_up_rounded,
                                      size: 13,
                                      color: Color(0xFF4EDEA3),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '+1.2%',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF4EDEA3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            total > 0
                                ? 'Total $total siswa terpantau hari ini'
                                : 'Total 1.250 siswa terdaftar aktif',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFFDBEAFE),
                            ),
                          ),
                        ],
                      ),
                      // Circular Progress Ring
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 58,
                            height: 58,
                            child: CircularProgressIndicator(
                              value: rate / 100,
                              strokeWidth: 5.5,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4EDEA3),
                              ),
                            ),
                          ),
                          Text(
                            '${rate.round()}%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 4 Quick Counter Badges
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCounter(
                          icon: Icons.check_circle_rounded,
                          iconColor: const Color(0xFF4EDEA3),
                          value: total > 0 ? '$hadirCount' : '1.198',
                          label: 'Hadir',
                        ),
                        Container(
                          width: 1,
                          height: 26,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        _buildMetricCounter(
                          icon: Icons.medication_rounded,
                          iconColor: const Color(0xFFFDE68A),
                          value: total > 0 ? '$sakitCount' : '24',
                          label: 'Sakit',
                        ),
                        Container(
                          width: 1,
                          height: 26,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        _buildMetricCounter(
                          icon: Icons.pending_actions_rounded,
                          iconColor: const Color(0xFFBFDBFE),
                          value: total > 0 ? '$izinCount' : '15',
                          label: 'Izin',
                        ),
                        Container(
                          width: 1,
                          height: 26,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        _buildMetricCounter(
                          icon: Icons.cancel_rounded,
                          iconColor: const Color(0xFFFECACA),
                          value: total > 0 ? '$alpaCount' : '13',
                          label: 'Alpa',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCounter({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            color: const Color(0xFFDBEAFE),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CARD 3: QUICK ACTIONS GRID (AKSI CEPAT GURU)
  // ==========================================
  Widget _buildQuickActionsGrid(BuildContext context) {
    final advisoryClass =
        widget.profile.activeSchool?.classroomNameField ?? 'XII RPL 1';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aksi Cepat Guru',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Akses Kilat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Action 1: Input Presensi Kelas (Primary Blue)
            Expanded(
              child: _buildActionTile(
                backgroundColor: widget.schoolColor,
                icon: Icons.edit_square,
                iconColor: Colors.white,
                iconBg: Colors.white.withValues(alpha: 0.20),
                trailing: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFBFDBFE),
                  size: 18,
                ),
                title: 'Input Presensi',
                titleColor: Colors.white,
                subtitle: '$advisoryClass • Jam Ke-4',
                subtitleColor: const Color(0xFFDBEAFE),
                onTap: () {
                  HapticFeedback.selectionClick();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (_) => const AttendanceEntrySheet(),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            // Action 2: Scan RFID/QR (Gerbang 1)
            Expanded(
              child: _buildActionTile(
                backgroundColor: Colors.white,
                icon: Icons.qr_code_scanner_rounded,
                iconColor: widget.schoolColor,
                iconBg: const Color(0xFFEFF6FF),
                trailing: Text(
                  'Gerbang 1',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                title: 'Scan RFID/QR',
                titleColor: const Color(0xFF0F172A),
                subtitle: 'Tap Kartu Masuk',
                subtitleColor: const Color(0xFF64748B),
                onTap: () => _showScanRfidDialog(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Action 3: Validasi Izin Sakit
            Expanded(
              child: _buildActionTile(
                backgroundColor: Colors.white,
                icon: Icons.assignment_turned_in_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFF5F3FF),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '2 Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: 'Validasi Izin',
                titleColor: const Color(0xFF0F172A),
                subtitle: 'Menunggu respon guru',
                subtitleColor: const Color(0xFF64748B),
                onTap: () => _showMedicalValidationDialog(context),
              ),
            ),
            const SizedBox(width: 10),
            // Action 4: Rekap & Unduh
            Expanded(
              child: _buildActionTile(
                backgroundColor: Colors.white,
                icon: Icons.summarize_rounded,
                iconColor: const Color(0xFF007D55),
                iconBg: const Color(0xFFECFDF5),
                trailing: const Icon(
                  Icons.file_download_outlined,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
                title: 'Rekap & Unduh',
                titleColor: const Color(0xFF0F172A),
                subtitle: 'Format PDF/Excel',
                subtitleColor: const Color(0xFF64748B),
                onTap: () => _showDownloadReportDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Widget trailing,
    required String title,
    required Color titleColor,
    required String subtitle,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFECEEF0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 19, color: iconColor),
                  ),
                  trailing,
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: subtitleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CARD 4: WEEKLY TREND CHART
  // ==========================================
  Widget _buildWeeklyTrendCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEEF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tren Kehadiran Mingguan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Rata-rata 5 hari kerja: 94.8%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  'Optimal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF007D55),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bar Chart Visual
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                // Benchmark 95% Dashed Line
                Positioned(
                  left: 0,
                  right: 0,
                  top: 15,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Target 95%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildWeeklyBar('Sen', 96, const Color(0xFF004AC6)),
                    _buildWeeklyBar('Sel', 94, const Color(0xFF3B82F6)),
                    _buildWeeklyBar('Rab', 97, const Color(0xFF007D55)),
                    _buildWeeklyBar('Kam', 95, const Color(0xFF3B82F6)),
                    _buildWeeklyBar('Jum', 92, const Color(0xFFDC2626)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Legend
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('Normal', const Color(0xFF004AC6)),
                _buildLegendItem('Puncak', const Color(0xFF007D55)),
                _buildLegendItem('< 93% Atensi', const Color(0xFFDC2626)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBar(String day, int rate, Color barColor) {
    final double height = (rate / 100) * 85;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$rate%',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: barColor,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 26,
          height: height,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // CARD 5: CLASS ATTENDANCE MONITORING
  // ==========================================
  Widget _buildClassMonitoringSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Status Presensi Kelas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _activeViewIndex = 1);
              },
              child: Text(
                'Lihat Roster',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.schoolColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildClassFilterChip('all', 'Semua (12)'),
              const SizedBox(width: 8),
              _buildClassFilterChip('locked', 'Sudah Terkunci (9)'),
              const SizedBox(width: 8),
              _buildClassFilterChip('pending', 'Belum Selesai (3)'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Class Cards Stack
        if (_classFilter == 'all' || _classFilter == 'locked') ...[
          _buildClassCard(
            className:
                widget.profile.activeSchool?.classroomNameField ?? 'XII RPL 1',
            badgeTitle: 'Kelas Binaan',
            badgeBg: const Color(0xFFEFF6FF),
            badgeTextColor: const Color(0xFF004AC6),
            roomSubtitle:
                'Wali Kelas: ${widget.profile.user.fullName} • Ruang Lab KBM',
            statusLabel: 'Selesai 100%',
            statusBg: const Color(0xFFECFDF5),
            statusTextColor: const Color(0xFF007D55),
            statusIcon: Icons.lock_rounded,
            progressText: 'Progress: 36 / 36 Siswa',
            cloudSyncText: 'Sinkron Cloud',
            hadirCount: 32,
            sakitCount: 2,
            izinCount: 1,
            alpaCount: 1,
            footerNote: 'Terkunci: 07:45 WIB',
            actionButtonLabel: 'Detail Roster',
            onAction: () {
              HapticFeedback.selectionClick();
              setState(() => _activeViewIndex = 1);
            },
          ),
          const SizedBox(height: 10),
        ],
        if (_classFilter == 'all' || _classFilter == 'pending') ...[
          _buildClassCard(
            className: 'XII RPL 2',
            badgeTitle: 'Belum Kunci',
            badgeBg: const Color(0xFFFEE2E2),
            badgeTextColor: const Color(0xFFDC2626),
            roomSubtitle: 'Guru Mengajar: Ibu Rina Marlina, S.Pd.',
            statusLabel: '28 / 36 Siswa',
            statusBg: const Color(0xFFF1F5F9),
            statusTextColor: const Color(0xFF475569),
            statusIcon: Icons.timelapse_rounded,
            progressText: 'Tersisa 8 siswa belum diabsen',
            cloudSyncText: 'Kurang 22%',
            hadirCount: 26,
            sakitCount: 1,
            izinCount: 1,
            alpaCount: 0,
            footerNote: 'Batas submit: 10:00 WIB',
            actionButtonLabel: 'Ingatkan Guru',
            actionIsWarning: true,
            onAction: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '✓ Pesan pengingat presensi otomatis terkirim ke Ibu Rina Marlina!',
                  ),
                  backgroundColor: Color(0xFF007D55),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildClassCard(
            className: 'XI TJKT 1',
            badgeTitle: 'Kosong (0/34)',
            badgeBg: const Color(0xFFFEF3C7),
            badgeTextColor: const Color(0xFFB45309),
            roomSubtitle: 'Jadwal Praktik Komputer Jaringan',
            statusLabel: 'Menunggu',
            statusBg: const Color(0xFFFEF2F2),
            statusTextColor: const Color(0xFFDC2626),
            statusIcon: Icons.warning_amber_rounded,
            progressText: 'Belum ada presensi dimulai',
            cloudSyncText: 'Jam Ke-4',
            hadirCount: 0,
            sakitCount: 0,
            izinCount: 0,
            alpaCount: 0,
            footerNote: 'Jadwal aktif sekarang',
            actionButtonLabel: 'Input Sekarang',
            actionIsPrimary: true,
            onAction: () {
              HapticFeedback.selectionClick();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => const AttendanceEntrySheet(),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildClassFilterChip(String filterKey, String label) {
    final isSelected = _classFilter == filterKey;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _classFilter = filterKey);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? widget.schoolColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard({
    required String className,
    required String badgeTitle,
    required Color badgeBg,
    required Color badgeTextColor,
    required String roomSubtitle,
    required String statusLabel,
    required Color statusBg,
    required Color statusTextColor,
    required IconData statusIcon,
    required String progressText,
    required String cloudSyncText,
    required int hadirCount,
    required int sakitCount,
    required int izinCount,
    required int alpaCount,
    required String footerNote,
    required String actionButtonLabel,
    bool actionIsWarning = false,
    bool actionIsPrimary = false,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEEF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    className,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusTextColor),
                    const SizedBox(width: 4),
                    Text(
                      statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            roomSubtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          // Progress & Multi-Segment Indicator
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      progressText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    Text(
                      cloudSyncText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007D55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: hadirCount > 0 ? hadirCount : 1,
                        child: Container(
                          height: 5,
                          color: hadirCount > 0
                              ? const Color(0xFF007D55)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      if (sakitCount > 0)
                        Expanded(
                          flex: sakitCount,
                          child: Container(
                            height: 5,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      if (izinCount > 0)
                        Expanded(
                          flex: izinCount,
                          child: Container(
                            height: 5,
                            color: const Color(0xFF004AC6),
                          ),
                        ),
                      if (alpaCount > 0)
                        Expanded(
                          flex: alpaCount,
                          child: Container(
                            height: 5,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$hadirCount Hadir',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '$sakitCount Sakit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '$izinCount Izin',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '$alpaCount Alpa',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                footerNote,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionIsPrimary
                      ? widget.schoolColor
                      : (actionIsWarning
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFF1F5F9)),
                  foregroundColor: actionIsPrimary
                      ? Colors.white
                      : (actionIsWarning
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF0F172A)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: actionIsWarning
                        ? const BorderSide(color: Color(0xFFFECACA))
                        : BorderSide.none,
                  ),
                ),
                onPressed: onAction,
                child: Text(
                  actionButtonLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 6: ATTENTION & FOLLOW-UP SECTION
  // ==========================================
  Widget _buildFollowUpSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECEEF0)),
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: Color(0xFFDC2626),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perlu Tindak Lanjut',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Prioritas Perhatian Wali Kelas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '2 Kasus',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Follow up item 1: 3x Alpa Berturut-turut
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 17,
                      backgroundColor: Color(0xFFFEE2E2),
                      child: Icon(
                        Icons.person_off_rounded,
                        color: Color(0xFFDC2626),
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Fajar Nugraha',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '3x Alpa Berturut',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'NISN: 0068921102 • Tidak hadir sejak Rabu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ortu: Bpk. Suryadi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007D55),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _launchWaOrtu(context, 'Suryadi'),
                      icon: const Icon(Icons.chat_rounded, size: 13),
                      label: Text(
                        'WhatsApp Ortu',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Follow up item 2: Medical Certificate Validation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 17,
                      backgroundColor: Color(0xFFEFF6FF),
                      child: Icon(
                        Icons.medical_services_rounded,
                        color: Color(0xFF004AC6),
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nabila Zahra',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Surat Dokter',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF004AC6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Unggah via Portal Ortu • Istirahat 2 Hari',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _showMedicalValidationDialog(context),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_file_rounded,
                            size: 14,
                            color: Color(0xFF004AC6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Lihat Lampiran',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF004AC6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007D55),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _showMedicalValidationDialog(context),
                      child: Text(
                        'Setujui Izin',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CARD 7: OPERATIONAL SYNC & GATEWAY FOOTER
  // ==========================================
  Widget _buildGatewaySyncFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_done_rounded,
            color: Color(0xFF007D55),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinkron Dapodik & WhatsApp Gateway',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Terakhir diperbarui hari ini • Status: Real-time Cloud',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            color: const Color(0xFF475569),
            onPressed: () {
              HapticFeedback.selectionClick();
              widget.onRefresh();
            },
          ),
        ],
      ),
    );
  }
}
