import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog untuk mengunduh rekapitulasi presensi (PDF / Excel)
class TeacherDownloadReportDialog {
  static void show(BuildContext context) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Rekapitulasi Presensi KBM',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih format unduhan rekapitulasi presensi kehadiran siswa periode semester berjalan:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              leading: const Icon(
                Icons.picture_as_pdf_rounded,
                color: Color(0xFFDC2626),
              ),
              title: Text(
                'Laporan Resmi (PDF)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Format cetak standar Dapodik & tanda tangan Kepsek',
                style: GoogleFonts.plusJakartaSans(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '✓ Mengunduh Rekapitulasi Presensi Semester (PDF)...',
                    ),
                    backgroundColor: Color(0xFF007D55),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              leading: const Icon(
                Icons.table_chart_rounded,
                color: Color(0xFF007D55),
              ),
              title: Text(
                'Lembar Kerja (Excel .xlsx)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                'Data tabular lengkap dengan persentase kehadiran',
                style: GoogleFonts.plusJakartaSans(fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '✓ Mengunduh Rekapitulasi Presensi Tabular (Excel)...',
                    ),
                    backgroundColor: Color(0xFF007D55),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
