import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../academic/data/academic_repository.dart';
import '../../billing/data/billing_repository.dart';
import '../../auth/logic/auth_state.dart';
import '../../academic/data/models/student_model.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/logic/auth_cubit.dart';
import 'widgets/profile_academic_metrics_capsules.dart';
import 'widgets/profile_academic_services_section.dart';
import 'widgets/profile_digital_card_modal.dart';
import 'widgets/profile_hero_card.dart';
import 'widgets/profile_registered_info_section.dart';

/// Halaman Profil & Akun Siswa selaras 1:1 dengan Google Stitch Design ("Profil Siswa").
/// Mengimplementasikan arsitektur modular Bento Grid:
/// 1. Top Header App Bar & Settings ([ProfileTopBar])
/// 2. Profile Hero Bento Card ([ProfileHeroCard] - Foto, NIS/NISN, Kartu Digital)
/// 3. Quick Academic Capsules ([ProfileAcademicMetricsCapsules] - IPK 88.5, Hadir 96%, Bebas SPP)
/// 4. Kontak & Data Terdaftar ([ProfileRegisteredInfoSection] - Wali Kelas WA, Orang Tua Call, Domisili)
/// 5. Berkas & Layanan Akademik ([ProfileAcademicServicesSection] - E-Rapor PDF, Surat Aktif, Dapodik)
/// 6. Ganti Institusi Multi-Tenant (Bila terdaftar di >1 sekolah)
class ProfileScreen extends StatefulWidget {
  final UserProfileResponse profile;
  final ScrollController? scrollController;
  const ProfileScreen({
    super.key,
    required this.profile,
    this.scrollController,
  });
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StudentModel? _student;
  int _attendanceRate = 0;
  String _attendanceRank = '0 Hadir';
  final double _gpa = 0.0;
  final String _gradeLetter = '-';
  String _tuitionStatus = 'Lunas';
  String _tuitionMonth = 'November';
  UserProfileResponse get profile {
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      return authState.profile;
    }
    return widget.profile;
  }

  Color get _schoolColor =>
      AppTheme.parseHexColor(profile.activeSchool?.primaryColor);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLiveStudentData();
    });
  }

  Future<void> _loadLiveStudentData() async {
    final isParent = profile.activeSchool?.isParent == true;
    final isStudent = profile.activeSchool?.isStudent == true;
    final targetNis = isParent
        ? (profile.primaryChild?.nis ?? '')
        : (isStudent ? profile.user.cleanIdentifier : '');
    if (targetNis.isEmpty) {
      if (mounted && isParent && profile.primaryChild != null) {
        setState(() => _student = profile.primaryChild);
      }
      return;
    }
    final academicRepo = context.read<AcademicRepository>();
    final billingRepo = context.read<BillingRepository>();
    // 1. Ambil data StudentModel lengkap
    try {
      final st = await academicRepo.getStudentByNis(targetNis);
      if (mounted && st != null) {
        setState(() => _student = st);
      } else if (mounted && isParent && profile.primaryChild != null) {
        setState(() => _student = profile.primaryChild);
      }
    } catch (_) {
      if (mounted && isParent && profile.primaryChild != null) {
        setState(() => _student = profile.primaryChild);
      }
    }
    // 2. Ambil data Presensi riil
    try {
      final attendances = await academicRepo.getAttendances(
        studentNis: targetNis,
      );
      if (mounted && attendances.isNotEmpty) {
        final presentCount = attendances
            .where((a) => a.status.toUpperCase() == 'HADIR')
            .length;
        final total = attendances.length;
        final rate = total > 0 ? (presentCount / total * 100).round() : 0;
        setState(() {
          _attendanceRate = rate;
          _attendanceRank = '$presentCount Hadir';
        });
      } else if (mounted) {
        setState(() {
          _attendanceRate = 0;
          _attendanceRank = '0 Hadir';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _attendanceRate = 0;
          _attendanceRank = '0 Hadir';
        });
      }
    }
    // 3. Ambil data Tagihan SPP riil
    try {
      final invoices = await billingRepo.getInvoices(studentNis: targetNis);
      if (mounted && invoices.isNotEmpty) {
        final unpaidList = invoices.where((i) => i.isUnpaid).toList();
        if (unpaidList.isNotEmpty) {
          final firstUnpaid = unpaidList.first;
          setState(() {
            _tuitionStatus = 'Belum Lunas';
            _tuitionMonth = firstUnpaid.periodLabel.isNotEmpty
                ? firstUnpaid.periodLabel
                : 'Bulan Ini';
          });
        } else {
          final paidList = invoices.where((i) => i.isPaid).toList();
          setState(() {
            _tuitionStatus = 'Lunas';
            if (paidList.isNotEmpty) {
              _tuitionMonth = paidList.first.periodLabel.isNotEmpty
                  ? paidList.first.periodLabel
                  : 'Lunas';
            }
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    await Future.wait([
      context.read<AuthCubit>().checkSession(),
      _loadLiveStudentData(),
    ]);
  }

  void _showDigitalCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ProfileDigitalCardModal(
        profile: profile,
        schoolColor: _schoolColor,
        student: _student,
      ),
    );
  }

  void _showSwitchSchoolDialog(BuildContext context) {
    final memberships = profile.memberships;
    if (memberships.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Akun Anda saat ini terdaftar pada 1 institusi sekolah.',
          ),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
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
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Sekolah Aktif',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            ...memberships.map((m) {
              final isCurrent = m.schoolCode == profile.activeSchool?.code;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isCurrent
                      ? _schoolColor.withValues(alpha: 0.10)
                      : const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isCurrent ? _schoolColor : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _schoolColor.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.school_rounded,
                        color: _schoolColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      m.schoolName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${m.schoolCode} • ${m.roleLabel}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                    trailing: isCurrent
                        ? Icon(Icons.check_circle_rounded, color: _schoolColor)
                        : null,
                    onTap: isCurrent
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            context.read<AuthCubit>().switchSchool(
                              m.schoolCode,
                            );
                          },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Register subscription to AuthCubit inside build tree
    context.watch<AuthCubit>();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // Stitch Surface Background
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: _schoolColor,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          key: const PageStorageKey('profile_scroll_view'),
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Profile Hero Bento Card
              ProfileHeroCard(
                profile: profile,
                schoolColor: _schoolColor,
                student: _student,
                onOpenDigitalCard: () => _showDigitalCard(context),
              ),
              const SizedBox(height: 16),
              // 3. Quick Academic Capsules
              ProfileAcademicMetricsCapsules(
                profile: profile,
                gpa: _gpa,
                gradeLetter: _gradeLetter,
                attendanceRate: _attendanceRate,
                attendanceRank: _attendanceRank,
                tuitionStatus: _tuitionStatus,
                tuitionMonth: _tuitionMonth,
              ),
              const SizedBox(height: 16),
              // 4. Registered Contact & Guardian Information
              ProfileRegisteredInfoSection(profile: profile, student: _student),
              const SizedBox(height: 16),
              // 5. Academic Files & Documents
              ProfileAcademicServicesSection(
                isParent: profile.activeSchool?.isParent == true,
                isStaffOrTeacher:
                    profile.activeSchool?.isStaffOrTeacher == true,
                profile: profile,
              ),
              const SizedBox(height: 16),
              // 6. Switch School (if multi-school membership)
              if (profile.memberships.length > 1) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => _showSwitchSchoolDialog(context),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text('Ganti Institusi Sekolah'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _schoolColor,
                      side: BorderSide(
                        color: _schoolColor.withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
              // Security & Cloud footer note
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Data terenkripsi dan tersimpan aman di Cloud Vintech',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
