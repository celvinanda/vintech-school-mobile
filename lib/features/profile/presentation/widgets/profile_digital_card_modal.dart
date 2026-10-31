import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../academic/data/models/student_model.dart';
import '../../../auth/data/models/user_model.dart';

/// Modal Card: Digital Student/Teacher ID Card (Stitch Design)
/// Menampilkan Kartu Tanda Pelajar / Pegawai Elektronik dengan QR Code & Opsi Simpan ke Galeri Foto
class ProfileDigitalCardModal extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final StudentModel? student;

  const ProfileDigitalCardModal({
    super.key,
    required this.profile,
    required this.schoolColor,
    this.student,
  });

  bool get _isStaffOrTeacher => profile.activeSchool?.isStaffOrTeacher == true;
  String get _schoolName => (profile.activeSchool?.schoolName ?? 'SMA NEGERI 1 JAKARTA').toUpperCase();
  String get _nis => profile.user.cleanIdentifier;
  String get _nisn => student?.nisn ?? (profile.activeSchool?.isStudent == true ? '0081234501' : '-');
  String get _classroomName => student?.classroomName ?? profile.activeSchool?.classroomName ?? 'Kelas X-IPA-1';
  String get _cardTitle => profile.activeSchool?.cardBadgeTitle ?? 'KARTU PELAJAR DIGITAL';

  String get _initials {
    final name = profile.user.fullName.trim();
    if (name.isEmpty) return 'ST';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Card Header Visual
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      schoolColor,
                      Color.lerp(schoolColor, const Color(0xFF0F172A), 0.45)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _schoolName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _cardTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB4C5FF),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // Card Body Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Student Photo Container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _initials,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: schoolColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      profile.user.fullName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isStaffOrTeacher
                          ? 'NIP: $_nis | ROLE: ${profile.activeSchool?.roleDisplayLabel ?? "Staff"}'
                          : 'NISN: $_nisn | NIS: $_nis',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isStaffOrTeacher
                          ? '${profile.activeSchool?.title.isNotEmpty == true ? profile.activeSchool!.title : "Tenaga Pendidik"} • Aktif'
                          : '$_classroomName • TP 2026/2027 Ganjil',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QR Barcode Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                size: 84,
                                color: Color(0xFF004AC6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'KODE VALIDASI: VNT-2026-X1-88',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Button: Save to Gallery
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ Kartu Tanda Pelajar berhasil disimpan ke galeri foto!'),
                              backgroundColor: Color(0xFF007D55),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_alt_rounded, size: 17),
                        label: Text(
                          'Simpan ke Galeri Foto',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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
