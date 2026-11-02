import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/data/models/user_model.dart';

/// Komponen Digital Student Smart Card (Hero Bento Section)
/// Selaras 1:1 dengan Google Stitch "Vintech School Dashboard"
class StudentSmartCard extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;

  const StudentSmartCard({
    super.key,
    required this.profile,
    required this.schoolColor,
  });

  bool get _isParent => profile.activeSchool?.isParent == true;
  String get _cleanNis => _isParent && profile.primaryChild != null
      ? profile.primaryChild!.nis
      : profile.user.cleanIdentifier;
  String get _nisn => _isParent && profile.primaryChild?.nisn != null
      ? profile.primaryChild!.nisn!
      : (_cleanNis.isNotEmpty ? '008$_cleanNis' : '0082914820');

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
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
            // Watermark Accent 1
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
            // Watermark Accent 2
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
                  // Top Row: Header Badge & Status Pill
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
                            profile.activeSchool?.cardBadgeTitle ??
                                'KARTU PELAJAR DIGITAL',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFCBD5E1),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007D55)
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF6FFBBE)
                                .withValues(alpha: 0.45),
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
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF6FFBBE),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'OTA #1 ⚡',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFFBAE6FD),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Middle Identity: Name, Grade/Class, NFC Badge
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
                              style: GoogleFonts.plusJakartaSans(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                              style: GoogleFonts.plusJakartaSans(
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

                  // Bottom Identity: NIS, NISN & Interactive Scan ID Token
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
                                  style: GoogleFonts.plusJakartaSans(
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
                                  style: GoogleFonts.plusJakartaSans(
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
                              showStudentQrModal(context);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6.5,
                              ),
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
                                    style: GoogleFonts.plusJakartaSans(
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
      ),
    );
  }

  void showStudentQrModal(BuildContext context) {
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
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF565E74),
                      size: 20,
                    ),
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
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF565E74),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Barcode / QR Simulation
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
                  color: schoolColor,
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
                    style: GoogleFonts.plusJakartaSans(
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
}
