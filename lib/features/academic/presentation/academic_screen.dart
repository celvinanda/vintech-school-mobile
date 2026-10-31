import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/models/user_model.dart';
import 'widgets/academic/academic_counseling_card.dart';
import 'widgets/academic/academic_hero_card.dart';
import 'widgets/academic/academic_schedule_section.dart';
import 'widgets/academic/academic_subjects_grid.dart';
import 'widgets/academic/academic_tab_chips.dart';
import 'widgets/academic/academic_tasks_section.dart';

/// Halaman Akademik Siswa selaras 1:1 dengan Google Stitch Design ("Akademik Siswa").
/// Mengimplementasikan arsitektur modular Bento Grid:
/// 1. Top Header (School Emblem, Title "Akademik Siswa", Semester Badge)
/// 2. Academic Hero Bento Card ([AcademicHeroCard] - IPK 88.6, Peringkat Kelas, Rapor Digital)
/// 3. Filter Category Chips ([AcademicTabChips] - Jadwal, Tugas & PR, Nilai, Materi)
/// 4. Jadwal Hari Ini ([AcademicScheduleSection] - Status live kelas, guru, ruang)
/// 5. Tugas & Ujian ([AcademicTasksSection] - Progress kesiapan, countdown tenggat)
/// 6. Daftar Mata Pelajaran 2x2 Grid ([AcademicSubjectsGrid] - Nilai & kehadiran)
/// 7. Bimbingan Konseling Banner ([AcademicCounselingCard] - Janji temu guru BK)
class AcademicScreen extends StatefulWidget {
  final UserProfileResponse profile;

  const AcademicScreen({super.key, required this.profile});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen> {
  int _selectedTabIndex = 0;

  Color get _schoolColor {
    final hex = widget.profile.activeSchool?.primaryColor;
    if (hex != null && hex.isNotEmpty) {
      return AppTheme.parseHexColor(hex);
    }
    return const Color(0xFF003366);
  }

  String get _schoolName {
    return widget.profile.activeSchool?.schoolName ?? 'VINTECH ACADEMY';
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    // Simulate instantaneous background refresh
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // Sticky Pinned Top Bar - Menyatu mulus dengan Bar Notifikasi
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
                    child: _buildHeader(context),
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: _schoolColor,
                child: SingleChildScrollView(
                  key: const PageStorageKey('academic_scroll_view'),
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Academic Hero Bento Card (IPK 88.6 & Rapor)
                AcademicHeroCard(
                  classroomName: 'Kelas X-IPA-1',
                  academicPeriod: 'Semester Genap 2025/2026',
                  gpa: 88.6,
                  rankText: 'Ke-3 dari 36 Siswa',
                  onReportTap: () {
                    _showReportModal(context);
                  },
                ),
                const SizedBox(height: 16),

                // 3. Category Filter Chips
                AcademicTabChips(
                  selectedIndex: _selectedTabIndex,
                  onTabSelected: (index) {
                    setState(() => _selectedTabIndex = index);
                  },
                  primaryColor: _schoolColor,
                ),
                const SizedBox(height: 18),

                // 4. Dynamic Sections based on selected tab
                if (_selectedTabIndex == 0) ...[
                  // All Overview / Jadwal Pelajaran
                  AcademicScheduleSection(
                    onCalendarTap: () => _showCalendarNotice(context),
                  ),
                  const SizedBox(height: 18),
                  AcademicTasksSection(
                    onViewAllTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                  const SizedBox(height: 18),
                  AcademicSubjectsGrid(
                    onViewAllTap: () => setState(() => _selectedTabIndex = 2),
                  ),
                ] else if (_selectedTabIndex == 1) ...[
                  // Tugas & PR
                  AcademicTasksSection(
                    onViewAllTap: () {},
                  ),
                ] else if (_selectedTabIndex == 2) ...[
                  // Nilai & Ujian
                  AcademicSubjectsGrid(
                    onViewAllTap: () {},
                  ),
                ] else if (_selectedTabIndex == 3) ...[
                  // Materi / Modul
                  AcademicSubjectsGrid(
                    onViewAllTap: () {},
                  ),
                ],
                const SizedBox(height: 18),

                // 5. Bimbingan Konseling (BK) Card
                AcademicCounselingCard(
                  onBookTap: () => _showCounselingBookingModal(context),
                ),
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

  Widget _buildHeader(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _schoolColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _schoolColor.withValues(alpha: 0.20),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: _schoolColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akademik Siswa',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    _schoolName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Period badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Genap 25/26',
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
      ),
    );
  }

  void _showReportModal(BuildContext context) {
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
                'Rapor_Semester_Ganjil_2025.pdf',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Nilai Rata-rata: 88.6 • Peringkat 3',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download_rounded, color: Color(0xFF003366)),
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCalendarNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Membuka kalender akademik semester genap...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCounselingBookingModal(BuildContext context) {
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
                const Icon(Icons.support_agent_rounded, color: Color(0xFF0284C7), size: 24),
                const SizedBox(width: 8),
                Text(
                  'Janji Temu Konseling (BK)',
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
              'Pilih jadwal dan topik pembicaraan untuk berkonsultasi secara privat dengan guru Bimbingan Konseling.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✓ Permintaan janji temu BK berhasil dikirim.'),
                      backgroundColor: Color(0xFF007D55),
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  'Konfirmasi Jadwal Konseling',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
