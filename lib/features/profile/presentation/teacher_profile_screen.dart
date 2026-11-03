import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../academic/data/academic_repository.dart';
import '../../academic/data/models/student_model.dart';
import '../../auth/data/models/user_model.dart';
import '../../home/data/models/school_dashboard_model.dart';
import '../../home/logic/home_cubit.dart';
import '../../home/logic/home_state.dart';

/// Halaman Profil Pendidik & Wali Kelas (Stitch Design 1:1)
/// Menampilkan informasi identitas resmi pendidik, NIP Dapodik,
/// tugas perwalian kelas, spesialisasi mata pelajaran, serta akses kontak cepat.
class TeacherProfileScreen extends StatefulWidget {
  final String teacherName;
  final String roleTitle;
  final String classroomName;
  final String phone;
  final String nip;
  final String specialization;
  final String email;
  final UserProfileResponse profile;
  final StudentModel? student;
  final bool isPrincipal;

  const TeacherProfileScreen({
    super.key,
    required this.teacherName,
    this.roleTitle = 'Wali Kelas',
    this.classroomName = '-',
    this.phone = '',
    this.nip = '',
    this.specialization = '',
    this.email = '',
    required this.profile,
    this.student,
    this.isPrincipal = false,
  });

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  late String _currentNip;
  late String _currentSpecialization;
  late String _currentPhone;
  late String _currentEmail;

  Color get _schoolColor =>
      AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);

  @override
  void initState() {
    super.initState();
    _currentNip = widget.nip.trim();
    _currentSpecialization = widget.specialization.trim();
    _currentPhone = widget.phone.trim();
    _currentEmail = widget.email.trim();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enrichTeacherData();
    });
  }

  /// Melengkapi data NIP, spesialisasi, atau email jika belum ada
  /// dengan mencocokkan ke daftar guru di HomeCubit atau database sekolah.
  Future<void> _enrichTeacherData() async {
    if (_currentNip.isNotEmpty &&
        _currentSpecialization.isNotEmpty &&
        _currentPhone.isNotEmpty) {
      return;
    }

    try {
      // 1. Cek dari HomeCubit state terlebih dahulu (instant memory)
      final homeCubit = context.read<HomeCubit>();
      List<SchoolTeacherModel> teachers = [];
      if (homeCubit.state is HomeLoaded) {
        teachers = (homeCubit.state as HomeLoaded).dashboard.teachers;
      }

      final query = widget.teacherName.toLowerCase().replaceAll(
            RegExp(r'^(dr\.|drs\.|dra\.|bpk\.|ibu\.|h\.|hj\.|ir\.|ust\.)\s*',
                caseSensitive: false),
            '',
          ).trim();

      SchoolTeacherModel? matched;
      for (final t in teachers) {
        final tClean = t.name.toLowerCase().replaceAll(
              RegExp(r'^(dr\.|drs\.|dra\.|bpk\.|ibu\.|h\.|hj\.|ir\.|ust\.)\s*',
                  caseSensitive: false),
              '',
            ).trim();
        if (tClean.contains(query) || query.contains(tClean)) {
          matched = t;
          break;
        }
      }

      // 2. Jika belum ketemu, coba cari dari classrooms catalog
      if (matched == null) {
        final academicRepo = context.read<AcademicRepository>();
        final classrooms = academicRepo.getCachedClassrooms() ??
            await academicRepo.getClassrooms();
        for (final c in classrooms) {
          if (c.name.trim().toLowerCase() ==
              widget.classroomName.trim().toLowerCase()) {
            if (c.homeroomTeacher != null &&
                c.homeroomTeacher!.trim().isNotEmpty &&
                widget.teacherName == '-') {
              // Fallback nama jika tadi '-'
              setState(() {});
            }
          }
        }
      }

      if (mounted && matched != null) {
        setState(() {
          if (_currentNip.isEmpty && matched!.nip.isNotEmpty) {
            _currentNip = matched.nip;
          }
          if (_currentSpecialization.isEmpty &&
              matched!.specialization.isNotEmpty) {
            _currentSpecialization = matched.specialization;
          }
          if (_currentPhone.isEmpty && matched!.phone.isNotEmpty) {
            _currentPhone = matched.phone;
          }
          if (_currentEmail.isEmpty && matched!.email.isNotEmpty) {
            _currentEmail = matched.email;
          }
        });
      }
    } catch (_) {
      // Fallback diam tanpa mengganggu UX
    }
  }

  String get _initials {
    final clean = widget.teacherName
        .replaceAll(
          RegExp(
            r'^(Dr\.|Drs\.|Dra\.|Bpk\.|Ibu\.|H\.|Hj\.|Ir\.|Ust\.)\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    if (clean.isEmpty) return 'PD';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.isNotEmpty ? clean[0].toUpperCase() : 'PD';
  }

  Future<void> _launchWhatsApp() async {
    HapticFeedback.lightImpact();
    final rawPhone = _currentPhone.replaceAll(RegExp(r'\D'), '');
    if (rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor kontak WhatsApp pendidik belum terdaftar di sistem.'),
        ),
      );
      return;
    }

    final cleanPhone =
        rawPhone.startsWith('0') ? '62${rawPhone.substring(1)}' : rawPhone;

    final studentName = widget.student?.fullName ??
        widget.profile.primaryChild?.fullName ??
        widget.profile.user.fullName;
    final isParent = widget.profile.activeSchool?.isParent == true;
    final isStaff = widget.profile.activeSchool?.isStaffOrTeacher == true;

    final String greeting;
    if (isStaff) {
      greeting =
          'Halo%20Bapak%2FIbu%20${Uri.encodeComponent(widget.teacherName)},%20saya%20${Uri.encodeComponent(widget.profile.user.fullName)}%20(Pendidik%20${Uri.encodeComponent(widget.profile.activeSchool?.schoolName ?? 'Sekolah')}).';
    } else if (isParent) {
      greeting =
          'Halo%20Bapak%2FIbu%20Wali%20Kelas%20${Uri.encodeComponent(widget.teacherName)},%20saya%20${Uri.encodeComponent(widget.profile.user.fullName)}%20(Orang%20Tua%20dari%20${Uri.encodeComponent(studentName)}%20kelas%20${Uri.encodeComponent(widget.classroomName)}).%20Mohon%20izin%20berkonsultasi.';
    } else {
      greeting =
          'Halo%20Bapak%2FIbu%20Wali%20Kelas%20${Uri.encodeComponent(widget.teacherName)},%20saya%20${Uri.encodeComponent(studentName)}%20dari%20kelas%20${Uri.encodeComponent(widget.classroomName)}.%20Mohon%20izin%20bertanya%20terkait%20akademik.';
    }

    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$greeting');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Cannot launch');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membuka kontak WhatsApp...')),
        );
      }
    }
  }

  Future<void> _launchPhoneCall() async {
    HapticFeedback.lightImpact();
    final cleanPhone = _currentPhone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nomor telepon belum tersedia.'),
        ),
      );
      return;
    }
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menghubungi nomor telepon...')),
        );
      }
    }
  }

  Future<void> _launchEmail() async {
    HapticFeedback.lightImpact();
    if (_currentEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat email belum terdaftar.')),
      );
      return;
    }
    final uri = Uri.parse('mailto:$_currentEmail');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Membuka aplikasi email...')),
        );
      }
    }
  }

  void _copyNip() {
    if (_currentNip.isEmpty) return;
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: _currentNip));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('NIP $_currentNip berhasil disalin ke clipboard.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schoolName =
        widget.profile.activeSchool?.schoolName ?? 'Vintech School';
    final hasPhone = _currentPhone.isNotEmpty;
    final hasEmail = _currentEmail.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isPrincipal ? 'Profil Kepala Sekolah' : 'Profil Wali Kelas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              schoolName,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===============================================================
            // 1. HERO IDENTITY CARD
            // ===============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with status ring
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFDBEAFE),
                          border: Border.all(
                            color: const Color(0xFFBFDBFE),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF004AC6),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Full Name
                  Text(
                    widget.teacherName != '-'
                        ? widget.teacherName
                        : 'Pendidik Sekolah',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Role & Assignment Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _schoolColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _schoolColor.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.isPrincipal
                              ? Icons.school_rounded
                              : Icons.groups_rounded,
                          size: 14,
                          color: _schoolColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isPrincipal
                              ? 'Kepala Sekolah Resmi'
                              : 'Wali Kelas ${widget.classroomName}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _schoolColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // NIP Pill with Copy Button
                  InkWell(
                    onTap: _copyNip,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.badge_outlined,
                            size: 13,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _currentNip.isNotEmpty
                                ? 'NIP: $_currentNip'
                                : 'NIP Terdaftar di Kemendikbud',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                          if (_currentNip.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.copy_rounded,
                              size: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===============================================================
            // 2. QUICK COMMUNICATION ACTIONS
            // ===============================================================
            Text(
              'Layanan & Komunikasi Cepat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            // WhatsApp Primary Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _launchWhatsApp,
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: Text(
                  widget.isPrincipal
                      ? 'Chat WhatsApp Kepala Sekolah'
                      : 'Chat WhatsApp Wali Kelas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Secondary Buttons: Telepon & Email
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasPhone ? _launchPhoneCall : null,
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: Text(
                      'Panggilan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF004AC6),
                      side: const BorderSide(color: Color(0xFFBFDBFE)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasEmail ? _launchEmail : null,
                    icon: const Icon(Icons.mail_outline_rounded, size: 16),
                    label: Text(
                      'Kirim Email',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ===============================================================
            // 3. BENTO ACADEMIC & ASSIGNMENT DETAILS
            // ===============================================================
            Text(
              'Rincian Tugas & Kepegawaian',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.meeting_room_outlined,
                    iconColor: const Color(0xFF004AC6),
                    label: 'Kelas Binaan Utama',
                    value: widget.classroomName != '-'
                        ? 'Kelas ${widget.classroomName}'
                        : 'Seluruh Siswa Institusi',
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.psychology_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    label: 'Bidang Studi / Spesialisasi',
                    value: _currentSpecialization.isNotEmpty
                        ? _currentSpecialization
                        : (widget.isPrincipal
                            ? 'Manajemen & Kepemimpinan Sekolah'
                            : 'Tenaga Pendidik Pengampu'),
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.verified_user_outlined,
                    iconColor: const Color(0xFF059669),
                    label: 'Status Verifikasi Dapodik',
                    value: 'Terverifikasi Aktif Semester Ini',
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.location_on_outlined,
                    iconColor: const Color(0xFFEA580C),
                    label: 'Unit Kerja / Institusi',
                    value: schoolName,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===============================================================
            // 4. ETIKA & JAM KONSULTASI AKADEMIK
            // ===============================================================
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Color(0xFF1D4ED8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jam Layanan & Konsultasi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Layanan komunikasi akademik aktif pada jam kerja sekolah (Senin - Jumat, 07:00 - 15:30 WIB). Harap sebutkan nama dan identitas siswa saat memulai percakapan.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF3B82F6),
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
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
