import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../academic/data/models/student_model.dart';
import '../../../auth/data/models/user_model.dart';

/// Card 2: Profile Hero Bento Card (Stitch Design)
/// Menampilkan Foto Profil Siswa/Guru, Status Aktif, NIS/NIP, serta Akses Kartu Digital & QR
class ProfileHeroCard extends StatefulWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final VoidCallback onOpenDigitalCard;
  final StudentModel? student;
  const ProfileHeroCard({
    super.key,
    required this.profile,
    required this.schoolColor,
    required this.onOpenDigitalCard,
    this.student,
  });
  @override
  State<ProfileHeroCard> createState() => _ProfileHeroCardState();
}

class _ProfileHeroCardState extends State<ProfileHeroCard> {
  bool _isNisCopied = false;
  bool get _isStaffOrTeacher =>
      widget.profile.activeSchool?.isStaffOrTeacher == true;
  bool get _isParent => widget.profile.activeSchool?.isParent == true;
  String get _nis => _isParent
      ? (widget.student?.nis ??
            widget.profile.primaryChild?.nis ??
            widget.profile.user.cleanIdentifier)
      : widget.profile.user.cleanIdentifier;
  String get _nisn =>
      widget.student?.nisn ??
      (widget.profile.activeSchool?.isStudent == true
          ? '0081234501'
          : (_isParent ? (widget.profile.primaryChild?.nisn ?? '-') : '-'));
  String get _classroomName =>
      widget.student?.classroomName ??
      widget.profile.activeSchool?.classroomName ??
      (_isParent
          ? (widget.profile.primaryChild?.classroomName ?? 'Siswa Terikat')
          : 'Kelas X-IPA-1');
  String get _schoolName =>
      widget.profile.activeSchool?.schoolName ??
      'SMA Negeri 1 Nusantara Jakarta';
  String get _roleLabel =>
      widget.profile.activeSchool?.roleDisplayLabel ??
      (_isParent ? 'Wali Murid' : 'Siswa Aktif');
  String get _initials {
    final name = widget.profile.user.fullName.trim();
    if (name.isEmpty) return 'ST';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _copyNis() async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _nis));
    setState(() => _isNisCopied = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Nomor Induk Siswa ($_nis) tersalin ke clipboard!'),
          backgroundColor: const Color(0xFF007D55),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isNisCopied = false);
      }
    });
  }

  void _handleChangePhoto() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih foto formal terbaru dari galeri perangkat Anda.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFECEEF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Ambient Decorative Blur Orb
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.schoolColor.withValues(alpha: 0.15),
                        const Color(0xFF4EDEA3).withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar & Camera Edit Button
                    Stack(
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF1F5F9),
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _initials,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: widget.schoolColor,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: widget.schoolColor,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              onTap: _handleChangePhoto,
                              customBorder: const CircleBorder(),
                              child: const Padding(
                                padding: EdgeInsets.all(7),
                                child: Icon(
                                  Icons.photo_camera_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Status Chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF007D55),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _roleLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF007D55),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            'TP 2026/2027 Ganjil',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Student/Staff Name & Title
                    Text(
                      widget.profile.user.fullName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isStaffOrTeacher
                          ? '${widget.profile.activeSchool?.title.isNotEmpty == true ? widget.profile.activeSchool!.title : _roleLabel} • $_schoolName'
                          : '$_classroomName • $_schoolName',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    if (_isParent) ...[
                      // Linked Child Card Container (Stitch Design)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: widget.schoolColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    border: Border.all(
                                      color: widget.schoolColor.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.school_rounded,
                                      color: widget.schoolColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Siswa Terikat (Anak Anda)',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        widget.student?.fullName ??
                                            widget
                                                .profile
                                                .primaryChild
                                                ?.fullName ??
                                            'Siswa Terikat',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.schoolColor.withValues(
                                      alpha: 0.10,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _classroomName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: widget.schoolColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(height: 1, color: Color(0xFFE2E8F0)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'NIS: ',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      _nis,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    InkWell(
                                      onTap: _copyNis,
                                      borderRadius: BorderRadius.circular(4),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: Icon(
                                          _isNisCopied
                                              ? Icons.check_rounded
                                              : Icons.copy_rounded,
                                          size: 13,
                                          color: _isNisCopied
                                              ? const Color(0xFF007D55)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'NISN: ',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    Text(
                                      _nisn,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // 2-Column ID Info Box (Standard Student / Teacher)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isStaffOrTeacher
                                        ? 'NIP / ID Pegawai'
                                        : (_isParent
                                              ? 'NIS Anak'
                                              : 'NIS / Induk'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        _nis,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        onTap: _copyNis,
                                        borderRadius: BorderRadius.circular(4),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: Icon(
                                            _isNisCopied
                                                ? Icons.check_rounded
                                                : Icons.copy_rounded,
                                            size: 13,
                                            color: _isNisCopied
                                                ? const Color(0xFF007D55)
                                                : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: const Color(0xFFE2E8F0),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isStaffOrTeacher
                                        ? 'Status Jabatan'
                                        : (_isParent
                                              ? 'NISN Anak'
                                              : 'NISN Nasional'),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isStaffOrTeacher ? _roleLabel : _nisn,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    // Action Button (Full-Width Minimalist)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          widget.onOpenDigitalCard();
                        },
                        icon: const Icon(Icons.badge_rounded, size: 18),
                        label: Text(
                          _isParent
                              ? 'Kartu Pelajar Digital Anak'
                              : (_isStaffOrTeacher
                                    ? 'Kartu ID Pegawai Digital'
                                    : 'Kartu Pelajar Digital'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.schoolColor,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
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
      ),
    );
  }
}
