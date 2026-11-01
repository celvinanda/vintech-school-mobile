import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/data/models/user_model.dart';
import '../logic/home_cubit.dart';
import '../logic/home_state.dart';

/// Halaman Profil Sekolah Resmi Vintech School
/// Direproduksi 1:1 dari Google Stitch ("Profil Sekolah - Vintech School")
/// Dilengkapi Cover Hero Kampus, Akreditasi A, Metrik Statistik Civitas,
/// Tab Interaktif (Profil & Visi, Pendidik & Staf, Program Keahlian, Fasilitas & Kontak).
class SchoolProfileScreen extends StatefulWidget {
  final UserProfileResponse profile;

  const SchoolProfileScreen({super.key, required this.profile});

  @override
  State<SchoolProfileScreen> createState() => _SchoolProfileScreenState();
}

class _SchoolProfileScreenState extends State<SchoolProfileScreen> {
  int _selectedTabIndex = 0;
  String _teacherSearchQuery = '';
  String _selectedTeacherCategory = 'all';

  final List<Map<String, dynamic>> _teachersData = [
    {
      'initials': 'BS',
      'name': 'Ir. Bambang S., M.Kom.',
      'roleBadge': 'Kajur RPL',
      'category': 'it',
      'subject': 'Pengajar AI & Cloud Architecture',
      'cert': 'Google Certified Cloud Architect',
      'avatarColor': const Color(0xFF004AC6),
      'avatarBg': const Color(0xFFDBE1FF),
    },
    {
      'initials': 'SR',
      'name': 'Siti Rahma, S.Pd., M.T.',
      'roleBadge': 'Kajur TJKT',
      'category': 'it',
      'subject': 'Pengajar Keamanan Siber & Jaringan',
      'cert': 'Cisco CCNA Certified Trainer',
      'avatarColor': const Color(0xFF007D55),
      'avatarBg': const Color(0xFFD1FAE5),
    },
    {
      'initials': 'DP',
      'name': 'Dimas Prasetyo, S.Sn.',
      'roleBadge': 'Kajur DKV',
      'category': 'it',
      'subject': 'Pengajar UI/UX & 3D Motion Graphic',
      'cert': 'Adobe Certified Professional',
      'avatarColor': const Color(0xFF4338CA),
      'avatarBg': const Color(0xFFE0E7FF),
    },
    {
      'initials': 'AW',
      'name': 'Anita Wijaya, S.E.',
      'roleBadge': 'Kajur BDIG',
      'category': 'it',
      'subject': 'Pengajar Digital Marketing & Omnichannel',
      'cert': 'Meta Certified Digital Marketer',
      'avatarColor': const Color(0xFFB45309),
      'avatarBg': const Color(0xFFFEF3C7),
    },
    {
      'initials': 'AS',
      'name': 'Dr. Arif Setiawan, M.Si.',
      'roleBadge': 'MIPA',
      'category': 'mipa',
      'subject': 'Matematika Terapan & Logika Komputasi',
      'cert': 'Pengajar Berprestasi Tk. Provinsi',
      'avatarColor': const Color(0xFF0284C7),
      'avatarBg': const Color(0xFFE0F2FE),
    },
    {
      'initials': 'CM',
      'name': 'Clara Monica, M.Hum.',
      'roleBadge': 'Bahasa',
      'category': 'bahasa',
      'subject': 'English for Tech & Global Workplace',
      'cert': 'IELTS Official Trainer Certified',
      'avatarColor': const Color(0xFFBE123C),
      'avatarBg': const Color(0xFFFFE4E6),
    },
  ];

  Color get _schoolColor =>
      AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);

  @override
  Widget build(BuildContext context) {
    final school = widget.profile.activeSchool;
    final schoolName = school?.name ?? 'SMK Vintech Nusantara';
    final schoolCode = school?.code ?? '20568912';
    final schoolLevel = school?.level ?? 'SMK';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF7F9FB),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FB), // Google Stitch: bg-surface
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF191C1E),
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Profil Sekolah',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF191C1E),
            ),
          ),
          actions: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF004AC6).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  schoolLevel.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF004AC6),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.share_outlined,
                size: 20,
                color: Color(0xFF565E74),
              ),
              tooltip: 'Salin Info Sekolah',
              onPressed: () {
                HapticFeedback.selectionClick();
                Clipboard.setData(
                  ClipboardData(
                    text:
                        '$schoolName (NPSN: $schoolCode) • Vintech School Cloud',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF191C1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    content: Text(
                      '✓ Info institusi sekolah berhasil disalin ke papan klip!',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. School Hero Showcase (Cover & Emblem & Stats)
              _buildSchoolHeroShowcase(schoolName, schoolCode),

              const SizedBox(height: 12),

              // 2. Segmented Tab Bar (Stitch Specification)
              _buildSegmentedTabBar(),

              const SizedBox(height: 16),

              // 3. Tab Content Panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildCurrentTabPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 1. HERO SHOWCASE SECTION (Stitch Specification)
  // =========================================================================
  Widget _buildSchoolHeroShowcase(String schoolName, String schoolCode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFECEEF0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF191C1E).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual Cover Banner with Gradient Overlay
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _schoolColor,
                        const Color(0xFF004AC6),
                        const Color(0xFF1D4ED8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Dual ambient orbs for architectural depth
                      Positioned(
                        top: -30,
                        right: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: 20,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      // Soft dark bottom gradient
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.55),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Top-right Accreditation Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: Color(0xFF007D55),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Akreditasi A (Unggul)',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF007D55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Identity Details & Overlapping Emblem
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Overlapping 72x72 Emblem
                      Transform.translate(
                        offset: const Offset(0, -32),
                        child: Container(
                          width: 68,
                          height: 68,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFECEEF0)),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF191C1E)
                                    .withValues(alpha: 0.10),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF004AC6), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.school_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // NPSN Tag
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'NPSN',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: const Color(0xFF565E74),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F4F6),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE0E3E5),
                                ),
                              ),
                              child: Text(
                                schoolCode,
                                style: GoogleFonts.robotoMono(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF191C1E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // School Name
                  Text(
                    schoolName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1E),
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Subtitle & Curriculum
                  Row(
                    children: [
                      const Icon(
                        Icons.hub_outlined,
                        size: 15,
                        color: Color(0xFF004AC6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Kurikulum Merdeka & Vokasi Digital',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF565E74),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Quick Stats Mosaic Grid (Stitch 4-Column Spec)
                  BlocBuilder<HomeCubit, HomeState>(
                    builder: (context, state) {
                      String totalStudents = '1.250+';
                      String totalTeachers = '78';
                      if (state is HomeLoaded) {
                        if (state.dashboard.totalStudents > 0) {
                          totalStudents = '${state.dashboard.totalStudents}';
                        }
                        if (state.dashboard.totalTeachers > 0) {
                          totalTeachers = '${state.dashboard.totalTeachers}';
                        }
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Color(0xFFECEEF0)),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildStatCell(
                              value: totalStudents,
                              label: 'Siswa',
                              color: const Color(0xFF004AC6),
                            ),
                            const SizedBox(width: 8),
                            _buildStatCell(
                              value: totalTeachers,
                              label: 'Pendidik',
                              color: const Color(0xFF007D55),
                            ),
                            const SizedBox(width: 8),
                            _buildStatCell(
                              value: '4',
                              label: 'Jurusan',
                              color: const Color(0xFF565E74),
                            ),
                            const SizedBox(width: 8),
                            _buildStatCell(
                              value: '24',
                              label: 'Industri',
                              color: const Color(0xFF191C1E),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCell({
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF565E74),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 2. STITCH SEGMENTED TAB BAR
  // =========================================================================
  Widget _buildSegmentedTabBar() {
    final tabs = [
      'Profil & Visi',
      'Pendidik & Staf',
      'Program Keahlian',
      'Fasilitas & Kontak',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFFECEEF0)),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF004AC6)
                        : const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF004AC6)
                                  .withValues(alpha: 0.20),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    tabs[index],
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF434655),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCurrentTabPanel() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildTabProfilDanVisi();
      case 1:
        return _buildTabPendidikDanStaf();
      case 2:
        return _buildTabProgramKeahlian();
      case 3:
        return _buildTabFasilitasDanKontak();
      default:
        return const SizedBox.shrink();
    }
  }

  // =========================================================================
  // TAB 1: PROFIL & VISI (Stitch Specification)
  // =========================================================================
  Widget _buildTabProfilDanVisi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sambutan Kepala Sekolah
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECEEF0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF191C1E).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBE1FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF004AC6).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        color: Color(0xFF004AC6),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. Ir. Hendra Wicaksono, M.Kom.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF191C1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kepala Sekolah SMK Vintech',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF004AC6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote_rounded,
                      size: 22,
                      color: Color(0xFF737686),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '"Kami berkomitmen melahirkan talenta digital muda yang tidak sekadar menguasai teknologi modern, tetapi memiliki integritas karakter, daya saing global, dan siap menjadi inovator terdepan di industri."',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF191C1E),
                          fontStyle: FontStyle.italic,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Visi & Misi Strategis
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECEEF0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF191C1E).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBE1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 17,
                      color: Color(0xFF004AC6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Visi & Misi Strategis',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Visi Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDBE1FF), Color(0xFFF2F4F6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF004AC6).withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VISI LEMBAGA',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: const Color(0xFF004AC6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '“Menjadi institusi pendidikan vokasi teknologi terdepan yang berkarakter, inovatif, dan berdaya saing global.”',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF191C1E),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'POIN MISI STRATEGIS',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFF565E74),
                ),
              ),
              const SizedBox(height: 8),

              _buildMisiItem(
                number: '1',
                text: 'Pembelajaran vokasi berbasis proyek industri nyata kolaboratif bersama mentor industri bersertifikasi.',
              ),
              const SizedBox(height: 6),
              _buildMisiItem(
                number: '2',
                text: 'Pembinaan kepemimpinan karakter berdaya juang mandiri, beretika profesional, dan berwawasan entrepreneur.',
              ),
              const SizedBox(height: 6),
              _buildMisiItem(
                number: '3',
                text: 'Akselerasi penguasaan teknologi terdepan (AI, Cloud Computing, Cyber Security, dan Product Design) sejak dini.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Capaian & Keunggulan (Grid 2x2)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECEEF0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF191C1E).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      size: 18,
                      color: Color(0xFF007D55),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Capaian & Keunggulan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildAchievementTile(
                      icon: Icons.workspace_premium_rounded,
                      color: const Color(0xFF007D55),
                      title: 'Juara 1 LKS',
                      subtitle: 'Web Tech Nasional',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAchievementTile(
                      icon: Icons.verified_user_rounded,
                      color: const Color(0xFF004AC6),
                      title: 'ISO 9001:2015',
                      subtitle: 'Manajemen Mutu',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildAchievementTile(
                      icon: Icons.star_rounded,
                      color: const Color(0xFFD97706),
                      title: 'SMK Pusat',
                      subtitle: 'Keunggulan Kemendikbud',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAchievementTile(
                      icon: Icons.handshake_rounded,
                      color: const Color(0xFF4338CA),
                      title: '100% Salur Kerja',
                      subtitle: 'Mitra BKK Vintech',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMisiItem({required String number, required String text}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF004AC6),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF191C1E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECEEF0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF191C1E),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: const Color(0xFF565E74),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 2: PENDIDIK & STAF (Stitch Specification)
  // =========================================================================
  Widget _buildTabPendidikDanStaf() {
    final filteredTeachers = _teachersData.where((teacher) {
      final nameMatches =
          _teacherSearchQuery.isEmpty ||
          teacher['name'].toString().toLowerCase().contains(
            _teacherSearchQuery.toLowerCase(),
          ) ||
          teacher['subject'].toString().toLowerCase().contains(
            _teacherSearchQuery.toLowerCase(),
          );
      final catMatches =
          _selectedTeacherCategory == 'all' ||
          teacher['category'] == _selectedTeacherCategory;
      return nameMatches && catMatches;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Filter Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECEEF0)),
          ),
          child: Column(
            children: [
              // Search Input
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _teacherSearchQuery = val.trim();
                    });
                  },
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFF191C1E),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: Color(0xFF565E74),
                    ),
                    hintText: 'Cari nama guru atau mata pelajaran...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF737686),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTeacherFilterChip('all', 'Semua (78)'),
                    _buildTeacherFilterChip('it', 'Kejuruan IT'),
                    _buildTeacherFilterChip('mipa', 'MIPA'),
                    _buildTeacherFilterChip('bahasa', 'Bahasa & Umum'),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Overview Stat Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF004AC6).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF004AC6).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.badge_rounded,
                    size: 18,
                    color: Color(0xFF004AC6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kualifikasi S1/S2 & Industri',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                ],
              ),
              Text(
                '100% Valid',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004AC6),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Teacher List
        if (filteredTeachers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                'Tidak ada guru yang cocok dengan pencarian.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF737686),
                ),
              ),
            ),
          )
        else
          ...filteredTeachers.map((teacher) => _buildTeacherCard(teacher)),
      ],
    );
  }

  Widget _buildTeacherFilterChip(String category, String label) {
    final isSelected = _selectedTeacherCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedTeacherCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF004AC6)
                : const Color(0xFFF2F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF565E74),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECEEF0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: teacher['avatarBg'] as Color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                teacher['initials'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: teacher['avatarColor'] as Color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        teacher['name'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF191C1E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (teacher['avatarColor'] as Color).withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        teacher['roleBadge'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: teacher['avatarColor'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  teacher['subject'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF565E74),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 13,
                      color: Color(0xFF007D55),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        teacher['cert'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF007D55),
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

  // =========================================================================
  // TAB 3: PROGRAM KEAHLIAN (Stitch Specification)
  // =========================================================================
  Widget _buildTabProgramKeahlian() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4 Jurusan Vokasi Unggulan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF191C1E),
                  ),
                ),
                Text(
                  'Kurikulum sinkronisasi bersama asosiasi industri',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF565E74),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF004AC6).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Siap Kerja',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004AC6),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Jurusan 1: RPL
        _buildMajorCard(
          icon: Icons.code_rounded,
          iconColor: const Color(0xFF004AC6),
          iconBg: const Color(0xFFDBE1FF),
          code: 'RPL',
          title: 'Rekayasa Perangkat Lunak',
          desc: 'Fokus: Web & Mobile Dev, AI Integration & Microservices',
          tags: ['Full-Stack React', 'Flutter', 'Python AI', 'PostgreSQL'],
        ),
        const SizedBox(height: 10),

        // Jurusan 2: TJKT
        _buildMajorCard(
          icon: Icons.router_rounded,
          iconColor: const Color(0xFF007D55),
          iconBg: const Color(0xFFD1FAE5),
          code: 'TJKT',
          title: 'Teknik Jaringan Komputer & Telko',
          desc:
              'Fokus: Cloud Architecture, Cyber Security, Fiber Optic Systems',
          tags: [
            'AWS Cloud',
            'Cisco Routing',
            'Ethical Hacking',
            'Linux Server',
          ],
        ),
        const SizedBox(height: 10),

        // Jurusan 3: DKV
        _buildMajorCard(
          icon: Icons.palette_rounded,
          iconColor: const Color(0xFF4338CA),
          iconBg: const Color(0xFFE0E7FF),
          code: 'DKV',
          title: 'Desain Komunikasi Visual',
          desc: 'Fokus: UI/UX Product Design, 3D Animation & Video Production',
          tags: ['Figma UX', 'Blender 3D', 'After Effects', 'Branding'],
        ),
        const SizedBox(height: 10),

        // Jurusan 4: BDIG
        _buildMajorCard(
          icon: Icons.storefront_rounded,
          iconColor: const Color(0xFFB45309),
          iconBg: const Color(0xFFFEF3C7),
          code: 'BDIG',
          title: 'Bisnis Digital & E-Commerce',
          desc:
              'Fokus: Performance Marketing, Marketplace Ops, FinTech Strategy',
          tags: [
            'Omnichannel CRM',
            'Ads Performance',
            'Data Sales',
            'Copywriting',
          ],
        ),

        const SizedBox(height: 16),

        // Mitra Industri & Sertifikasi Resmi
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECEEF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.corporate_fare_rounded,
                    size: 18,
                    color: Color(0xFF004AC6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mitra Industri & Sertifikasi Resmi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPartnerItem(
                      icon: Icons.cloud_rounded,
                      color: const Color(0xFF2563EB),
                      title: 'AWS Academy',
                      subtitle: 'Official Partner',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPartnerItem(
                      icon: Icons.dns_rounded,
                      color: const Color(0xFF16A34A),
                      title: 'Cisco Networking',
                      subtitle: 'NetAcad Member',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPartnerItem(
                      icon: Icons.domain_rounded,
                      color: const Color(0xFFDC2626),
                      title: 'Telkom Indonesia',
                      subtitle: 'Magang Vokasi',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPartnerItem(
                      icon: Icons.integration_instructions_rounded,
                      color: const Color(0xFFD97706),
                      title: 'Google Cloud',
                      subtitle: 'Education Partner',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMajorCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String code,
    required String title,
    required String desc,
    required List<String> tags,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF191C1E),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            code,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: iconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF565E74),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF434655),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF191C1E),
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF565E74),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 4: FASILITAS & KONTAK (Stitch Specification)
  // =========================================================================
  Widget _buildTabFasilitasDanKontak() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fasilitas Kampus
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECEEF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBE1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.domain_rounded,
                      size: 17,
                      color: Color(0xFF004AC6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fasilitas Kampus',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildFacilityTile(
                      icon: Icons.computer_rounded,
                      color: const Color(0xFF004AC6),
                      label: 'Lab AI & Workstations',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFacilityTile(
                      icon: Icons.local_library_rounded,
                      color: const Color(0xFF007D55),
                      label: 'Smart Digital Library',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildFacilityTile(
                      icon: Icons.videocam_rounded,
                      color: const Color(0xFF4338CA),
                      label: 'Studio Multimedia 4K',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFacilityTile(
                      icon: Icons.sports_basketball_rounded,
                      color: const Color(0xFFD97706),
                      label: 'Sport Arena & Hall',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildFacilityTile(
                      icon: Icons.cast_for_education_rounded,
                      color: const Color(0xFF0284C7),
                      label: 'Smart Interactive Class',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFacilityTile(
                      icon: Icons.coffee_rounded,
                      color: const Color(0xFF565E74),
                      label: 'Coworking Space Vokasi',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Informasi & Kontak
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECEEF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBE1FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.contact_support_rounded,
                      size: 17,
                      color: Color(0xFF004AC6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Informasi & Kontak',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildContactItem(
                icon: Icons.location_on_rounded,
                title: 'Alamat Kampus',
                subtitle: 'Jl. Pendidikan Raya No. 45, Kesamben, Kab. Blitar, Jawa Timur',
              ),
              const SizedBox(height: 12),
              _buildContactItem(
                icon: Icons.email_rounded,
                title: 'Email Resmi',
                subtitle: 'info@vintechschool.sch.id',
                isHighlighted: true,
              ),
              const SizedBox(height: 12),
              _buildContactItem(
                icon: Icons.call_rounded,
                title: 'Telepon / Hotline Tata Usaha',
                subtitle: '(0342) 889210',
              ),
              const SizedBox(height: 12),
              _buildContactItem(
                icon: Icons.schedule_rounded,
                title: 'Jam Layanan Pelayanan Siswa',
                subtitle: 'Senin - Jumat: 07.00 - 15.30 WIB',
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Action CTA Buttons
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004AC6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Membuka website resmi Vintech School...'),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.public_rounded, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Kunjungi Website Resmi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.open_in_new_rounded, size: 15),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE0E3E5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Menghubungkan ke WhatsApp Tata Usaha...'),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.chat_rounded,
                  size: 18,
                  color: Color(0xFF16A34A),
                ),
                const SizedBox(width: 8),
                Text(
                  'Hubungi Tata Usaha (WhatsApp)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF191C1E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityTile({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF191C1E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isHighlighted = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF565E74)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: const Color(0xFF565E74),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                  color: isHighlighted
                      ? const Color(0xFF004AC6)
                      : const Color(0xFF191C1E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
