import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../academic/data/models/student_model.dart';
import '../teacher_profile_screen.dart';
import '../../../auth/data/models/user_model.dart';
import '../parent_edit_profile_screen.dart';

/// Card 4: Registered Contact & Guardian Information (Stitch Design)
/// Menampilkan Wali Kelas / Pimpinan, Kontak Orang Tua / TU, Email, dan Alamat Institusi
class ProfileRegisteredInfoSection extends StatelessWidget {
  final UserProfileResponse profile;
  final StudentModel? student;
  final String homeroomTeacherName;
  final String homeroomTeacherPhone;
  final String parentName;
  final String parentPhone;
  final String address;

  const ProfileRegisteredInfoSection({
    super.key,
    required this.profile,
    this.student,
    this.homeroomTeacherName = '-',
    this.homeroomTeacherPhone = '',
    this.parentName = '-',
    this.parentPhone = '-',
    this.address = '-',
  });

  bool get _isStaffOrTeacher => profile.activeSchool?.isStaffOrTeacher == true;
  bool get _isParent => profile.activeSchool?.isParent == true;
  String get _classroomName =>
      student?.classroomName ?? profile.activeSchool?.classroomName ?? '-';
  String get _effectiveParentName => student?.parentName?.isNotEmpty == true
      ? student!.parentName!
      : parentName;
  String get _effectiveParentPhone => student?.parentPhone?.isNotEmpty == true
      ? student!.parentPhone!
      : parentPhone;

  String get _effectiveHomeroomName {
    if (student?.homeroomTeacherName != null &&
        student!.homeroomTeacherName!.trim().isNotEmpty) {
      return student!.homeroomTeacherName!.trim();
    }
    if (profile.activeSchool?.homeroomTeacher != null &&
        profile.activeSchool!.homeroomTeacher!.trim().isNotEmpty) {
      return profile.activeSchool!.homeroomTeacher!.trim();
    }
    if (profile.user.homeroomTeacher.trim().isNotEmpty) {
      return profile.user.homeroomTeacher.trim();
    }
    if (homeroomTeacherName.trim().isNotEmpty && homeroomTeacherName != '-') {
      return homeroomTeacherName.trim();
    }
    return '-';
  }

  String get _effectiveHomeroomPhone {
    if (student?.homeroomTeacherPhone != null &&
        student!.homeroomTeacherPhone!.trim().isNotEmpty) {
      return student!.homeroomTeacherPhone!.trim();
    }
    if (profile.activeSchool?.homeroomTeacherPhone != null &&
        profile.activeSchool!.homeroomTeacherPhone!.trim().isNotEmpty) {
      return profile.activeSchool!.homeroomTeacherPhone!.trim();
    }
    if (profile.user.homeroomTeacherPhone.trim().isNotEmpty) {
      return profile.user.homeroomTeacherPhone.trim();
    }
    return homeroomTeacherPhone.trim();
  }

  String get _effectiveHomeroomNip {
    if (student?.homeroomTeacherNip != null &&
        student!.homeroomTeacherNip!.trim().isNotEmpty) {
      return student!.homeroomTeacherNip!.trim();
    }
    if (profile.activeSchool?.homeroomTeacherNip != null &&
        profile.activeSchool!.homeroomTeacherNip!.trim().isNotEmpty) {
      return profile.activeSchool!.homeroomTeacherNip!.trim();
    }
    if (profile.user.homeroomTeacherNip.trim().isNotEmpty) {
      return profile.user.homeroomTeacherNip.trim();
    }
    return '';
  }

  String get _effectiveHomeroomSpecialization {
    if (student?.homeroomTeacherSpecialization != null &&
        student!.homeroomTeacherSpecialization!.trim().isNotEmpty) {
      return student!.homeroomTeacherSpecialization!.trim();
    }
    if (profile.activeSchool?.homeroomTeacherSpecialization != null &&
        profile.activeSchool!.homeroomTeacherSpecialization!.trim().isNotEmpty) {
      return profile.activeSchool!.homeroomTeacherSpecialization!.trim();
    }
    if (profile.user.homeroomTeacherSpecialization.trim().isNotEmpty) {
      return profile.user.homeroomTeacherSpecialization.trim();
    }
    return '';
  }

  String get _effectiveHomeroomEmail {
    if (student?.homeroomTeacherEmail != null &&
        student!.homeroomTeacherEmail!.trim().isNotEmpty) {
      return student!.homeroomTeacherEmail!.trim();
    }
    if (profile.activeSchool?.homeroomTeacherEmail != null &&
        profile.activeSchool!.homeroomTeacherEmail!.trim().isNotEmpty) {
      return profile.activeSchool!.homeroomTeacherEmail!.trim();
    }
    if (profile.user.homeroomTeacherEmail.trim().isNotEmpty) {
      return profile.user.homeroomTeacherEmail.trim();
    }
    return '';
  }

  void _openHomeroomProfile(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherProfileScreen(
          teacherName: _isStaffOrTeacher
              ? _effectivePrincipalName
              : _effectiveHomeroomName,
          roleTitle: _isStaffOrTeacher
              ? 'Kepala Sekolah / Pimpinan'
              : 'Wali Kelas $_classroomName',
          classroomName: _classroomName,
          phone: _effectiveHomeroomPhone,
          nip: _effectiveHomeroomNip,
          specialization: _effectiveHomeroomSpecialization,
          email: _effectiveHomeroomEmail,
          profile: profile,
          student: student,
          isPrincipal: _isStaffOrTeacher,
        ),
      ),
    );
  }

  String get _effectivePrincipalName {
    if (profile.activeSchool?.principalName != null &&
        profile.activeSchool!.principalName!.isNotEmpty) {
      return profile.activeSchool!.principalName!;
    }
    return 'Kepala Sekolah';
  }

  String get _principalInitials {
    final clean = _effectivePrincipalName
        .replaceAll(
          RegExp(
            r'^(Dr\.|Drs\.|Dra\.|Bpk\.|Ibu\.|H\.|Hj\.|Ir\.|Ust\.)\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    if (clean.isEmpty) return 'KS';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.isNotEmpty ? clean[0].toUpperCase() : 'KS';
  }

  String get _homeroomInitials {
    final clean = _effectiveHomeroomName
        .replaceAll(
          RegExp(
            r'^(Dra\.|Dr\.|Drs\.|Bpk\.|Ibu\.|H\.|Hj\.)\s*',
            caseSensitive: false,
          ),
          '',
        )
        .trim();
    if (clean.isEmpty) return 'WK';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean.isNotEmpty ? clean[0].toUpperCase() : 'WK';
  }

  String get _effectiveAddress {
    if (profile.user.address.isNotEmpty) {
      return profile.user.address;
    }
    return address.isNotEmpty && address != '-' ? address : 'Belum dilengkapi';
  }

  String get _effectiveEmail {
    if (profile.user.email.isNotEmpty) {
      return profile.user.email;
    }
    return 'Belum terdaftar';
  }

  String get _effectiveUserPhone {
    if (profile.user.phone.isNotEmpty &&
        profile.user.phone != '+62 812-3456-7890') {
      return profile.user.phone;
    }
    if (_isParent) {
      final childPhone =
          student?.parentPhone ?? profile.primaryChild?.parentPhone;
      if (childPhone != null && childPhone.isNotEmpty) return childPhone;
      return 'Belum terdaftar';
    }
    return 'Belum terdaftar';
  }

  Future<void> _launchWa(BuildContext context) async {
    HapticFeedback.lightImpact();
    final childName =
        student?.fullName ?? profile.primaryChild?.fullName ?? 'Anak Kami';
    final greeting = _isStaffOrTeacher
        ? 'Halo%20Bapak%2FIbu%20Kepala%20Sekolah,%20saya%20${profile.user.fullName}%20(Pendidik%20${profile.activeSchool?.schoolName ?? 'Sekolah'}).'
        : (_isParent
              ? 'Halo%20Bapak%2FIbu%20Wali%20Kelas,%20saya%20${profile.user.fullName}%20(Orang%20Tua%20dari%20$childName).'
              : 'Halo%20Bapak%2FIbu%20Wali%20Kelas,%20saya%20${profile.user.fullName}.');
    final rawPhone = _effectiveHomeroomPhone.replaceAll(RegExp(r'\D'), '');
    if (rawPhone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nomor kontak belum terdaftar di sistem sekolah.'),
          ),
        );
      }
      return;
    }
    final cleanPhone = rawPhone.startsWith('0')
        ? '62${rawPhone.substring(1)}'
        : rawPhone;
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$greeting');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isStaffOrTeacher
                  ? 'Membuka kontak WhatsApp Kepala Sekolah...'
                  : 'Membuka kontak WhatsApp Wali Kelas...',
            ),
          ),
        );
      }
    }
  }

  Future<void> _launchParentCall(BuildContext context) async {
    HapticFeedback.lightImpact();
    final cleanPhone = _effectiveParentPhone.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nomor telepon orang tua belum terdaftar di sistem.'),
          ),
        );
      }
      return;
    }
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menghubungi nomor telepon orang tua...'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isStaffOrTeacher
                ? 'Informasi Kontak & Dinas Pendidik'
                : (_isParent
                      ? 'Kontak & Informasi Terdaftar'
                      : 'Informasi Terdaftar'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Container(
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
                // 1. Wali Kelas Cardlet
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openHomeroomProfile(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 19,
                            backgroundColor: const Color(0xFFDBEAFE),
                            child: Text(
                              _isStaffOrTeacher
                                  ? _principalInitials
                                  : _homeroomInitials,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF004AC6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _isStaffOrTeacher
                                          ? 'Kepala Sekolah / Pimpinan'
                                          : (_isParent
                                                ? 'Wali Kelas Anak'
                                                : 'Wali Kelas ($_classroomName)'),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 10,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  _isStaffOrTeacher
                                      ? _effectivePrincipalName
                                      : _effectiveHomeroomName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _launchWa(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.chat_rounded,
                                    size: 13,
                                    color: Color(0xFF007D55),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isStaffOrTeacher ? 'Chat WA Dinas' : 'Chat WA',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
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
                    ),
                  ),
                ),
                if (!_isParent && !_isStaffOrTeacher) ...[
                  const SizedBox(height: 10),
                  // Orang Tua Cardlet (khusus akun Siswa)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 19,
                          backgroundColor: Color(0xFFE2E8F0),
                          child: Text(
                            'OT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Orang Tua / Wali Siswa',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _effectiveParentName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _launchParentCall(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.call_rounded,
                                  size: 13,
                                  color: Color(0xFF004AC6),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Hubungi',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF004AC6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                // Data Pendidik / Kontak & Domisili Terdaftar
                if (_isStaffOrTeacher &&
                    profile.activeSchool?.nip != null &&
                    profile.activeSchool!.nip!.isNotEmpty) ...[
                  _buildInfoTile(
                    icon: Icons.badge_outlined,
                    label: 'NIP / NUPTK Pendidik',
                    value: profile.activeSchool!.nip!,
                  ),
                  const SizedBox(height: 10),
                ],
                if (_isStaffOrTeacher &&
                    profile.activeSchool?.specialization != null &&
                    profile.activeSchool!.specialization!.isNotEmpty) ...[
                  _buildInfoTile(
                    icon: Icons.school_outlined,
                    label: 'Bidang Studi / Mata Pelajaran',
                    value: profile.activeSchool!.specialization!,
                  ),
                  const SizedBox(height: 10),
                ],
                _buildInfoTile(
                  icon: Icons.phone_android_rounded,
                  label: _isStaffOrTeacher
                      ? 'Nomor WhatsApp Dinas Pendidik'
                      : (_isParent
                            ? 'Nomor WhatsApp Orang Tua'
                            : 'Nomor Telepon / WhatsApp'),
                  value: _effectiveUserPhone,
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.mail_outline_rounded,
                  label: _isStaffOrTeacher
                      ? 'Email Resmi Pendidik'
                      : (_isParent
                            ? 'Email Orang Tua Terdaftar'
                            : 'Email Siswa'),
                  value: _effectiveEmail,
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.pin_drop_outlined,
                  label: _isStaffOrTeacher
                      ? 'Alamat Domisili Pendidik'
                      : (_isParent
                            ? 'Alamat Domisili Keluarga'
                            : 'Alamat Domisili'),
                  value: _effectiveAddress,
                ),
                if (_isParent || _isStaffOrTeacher) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ParentEditProfileScreen(
                              profile: profile,
                              student: student,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: Text(
                        _isStaffOrTeacher
                            ? 'Perbarui Data Kontak Pendidik'
                            : 'Perbarui Data Kontak & Domisili TU',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF004AC6),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        backgroundColor: const Color(0xFFF8FAFC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
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
              const SizedBox(height: 1),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
