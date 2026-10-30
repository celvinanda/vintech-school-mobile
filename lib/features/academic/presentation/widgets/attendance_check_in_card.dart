import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 2: Interactive Attendance Check-In Status Card (Google Stitch Design)
/// Status Masuk & Pulang, aksi Pindai QR, dan Pengajuan Izin/Sakit
class AttendanceCheckInCard extends StatelessWidget {
  const AttendanceCheckInCard({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECEEF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status Presensi Hari Ini',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191C1E),
                  ),
                ),
                Text(
                  'Semester Genap',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF565E74),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Dual Status Panels (Check-in & Check-out)
            Row(
              children: [
                // Masuk Panel
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Masuk',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFF565E74),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF007D55).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Tepat Waktu',
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF007D55),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF007D55),
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '07:15',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF191C1E),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'WIB',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF565E74),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Face ID Terverifikasi',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: const Color(0xFF565E74),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Pulang Panel
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Pulang',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFF565E74),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E3E5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Belum Waktunya',
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF565E74),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Icon(
                              Icons.timelapse_rounded,
                              color: Color(0xFF565E74),
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '15:30',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF565E74),
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'WIB',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF565E74),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Selesai KBM',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            color: const Color(0xFF565E74),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Quick Action Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _handleScanCheckIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                label: Text(
                  'Pindai QR / Tap Presensi',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton.icon(
                onPressed: () => _showLeaveRequestModal(context),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF2F4F6),
                  foregroundColor: const Color(0xFF191C1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.note_alt_rounded, size: 18, color: Color(0xFF565E74)),
                label: Text(
                  'Ajukan Izin atau Sakit',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleScanCheckIn(BuildContext context) {
    HapticFeedback.mediumImpact();
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBE1FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF004AC6),
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Presensi Terverifikasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF191C1E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kehadiran Anda berhasil diverifikasi pada pukul $timeStr WIB.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: const Color(0xFF565E74),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AC6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('OK, Mengerti'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeaveRequestModal(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
            const SizedBox(height: 16),
            Text(
              'Ajukan Surat Izin / Sakit',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF191C1E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pengajuan izin akan diteruskan kepada wali kelas dan guru piket.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF565E74),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFECEEF0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF004AC6)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan melampirkan surat dokter atau surat permohonan orang tua resmi.',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF434655),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Formulir izin siswa berhasil dibuka.'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Lanjutkan Pengisian'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
