import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../academic/data/models/student_model.dart';
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
    this.homeroomTeacherName = 'Dra. Sri Wahyuni, M.Pd',
    this.homeroomTeacherPhone = '6281200000000',
    this.parentName = 'Bpk. Pratama',
    this.parentPhone = '0811992201',
    this.address = 'Jl. Budi Utomo No. 7, Sawah Besar, Jakarta Pusat',
  });

  bool get _isStaffOrTeacher => profile.activeSchool?.isStaffOrTeacher == true;
  bool get _isParent => profile.activeSchool?.isParent == true;
  String get _classroomName =>
      student?.classroomName ??
      profile.activeSchool?.classroomName ??
      'X-IPA-1';
  String get _effectiveParentName => student?.parentName ?? parentName;
  String get _effectiveParentPhone => student?.parentPhone ?? parentPhone;

  String get _effectiveHomeroomName {
    if (student?.homeroomTeacherName != null &&
        student!.homeroomTeacherName!.isNotEmpty) {
      return student!.homeroomTeacherName!;
    }
    return homeroomTeacherName;
  }

  String get _effectiveHomeroomPhone {
    if (student?.homeroomTeacherPhone != null &&
        student!.homeroomTeacherPhone!.isNotEmpty) {
      return student!.homeroomTeacherPhone!;
    }
    return homeroomTeacherPhone;
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
    if (_isParent) {
      return 'Belum dilengkapi (Ketuk Ubah Kontak TU)';
    }
    return address;
  }

  String get _effectiveEmail {
    if (profile.user.email.isNotEmpty) {
      return profile.user.email;
    }
    return _isParent
        ? 'Belum terdaftar di sistem TU'
        : 'aditya.putra@student.sman1jkt.sch.id';
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
      return 'Belum terdaftar (Ketuk Ubah Kontak TU)';
    }
    return profile.user.phone.isNotEmpty
        ? profile.user.phone
        : '+62 812-3456-7890';
  }

  Future<void> _launchWa(BuildContext context) async {
    HapticFeedback.lightImpact();
    final childName =
        student?.fullName ?? profile.primaryChild?.fullName ?? 'Anak Kami';
    final greeting = _isParent
        ? 'Halo%20Bapak%2FIbu%20Wali%20Kelas,%20saya%20${profile.user.fullName}%20(Orang%20Tua%20dari%20$childName).'
        : 'Halo%20Bapak%2FIbu%20Wali%20Kelas,%20saya%20${profile.user.fullName}.';
    final rawPhone = _effectiveHomeroomPhone.replaceAll(RegExp(r'\D'), '');
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
          const SnackBar(
            content: Text('Membuka kontak WhatsApp Wali Kelas...'),
          ),
        );
      }
    }
  }

  Future<void> _launchParentCall(BuildContext context) async {
    HapticFeedback.lightImpact();
    final cleanPhone = _effectiveParentPhone.replaceAll(RegExp(r'\D'), '');
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
            _isParent ? 'Kontak & Informasi Terdaftar' : 'Informasi Terdaftar',
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
                Container(
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
                          _isStaffOrTeacher ? 'HW' : _homeroomInitials,
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
                            const SizedBox(height: 1),
                            Text(
                              _isStaffOrTeacher
                                  ? 'Dr. H. Hendra Wijaya, M.Pd.'
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
                                'Chat WA',
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
                if (!_isParent) ...[
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
                // Data Kontak & Domisili Terdaftar
                _buildInfoTile(
                  icon: Icons.phone_android_rounded,
                  label: _isParent
                      ? 'Nomor WhatsApp Orang Tua'
                      : 'Nomor Telepon / WhatsApp',
                  value: _effectiveUserPhone,
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.mail_outline_rounded,
                  label: _isParent
                      ? 'Email Orang Tua Terdaftar'
                      : 'Email Siswa',
                  value: _effectiveEmail,
                ),
                const SizedBox(height: 10),
                _buildInfoTile(
                  icon: Icons.pin_drop_outlined,
                  label: _isParent
                      ? 'Alamat Domisili Keluarga'
                      : 'Alamat Domisili',
                  value: _effectiveAddress,
                ),
                if (_isParent) ...[
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
                        'Perbarui Data Kontak & Domisili TU',
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
