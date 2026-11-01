import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vintech_school_mobile/features/academic/presentation/attendance_entry_sheet.dart';
import 'package:vintech_school_mobile/features/auth/data/models/user_model.dart';

import '../dialogs/teacher_download_report_dialog.dart';
import '../dialogs/teacher_medical_validation_dialog.dart';
import '../dialogs/teacher_scan_rfid_dialog.dart';

/// Card 3: Quick Actions Grid (Aksi Cepat Guru - 4 Grid Cards)
class TeacherQuickActionsGrid extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;

  const TeacherQuickActionsGrid({
    super.key,
    required this.profile,
    required this.schoolColor,
  });

  @override
  Widget build(BuildContext context) {
    final advisoryClass =
        profile.activeSchool?.classroomNameField ?? 'XII RPL 1';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aksi Cepat Guru',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Akses Kilat',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Action 1: Input Presensi Kelas (Primary Blue)
            Expanded(
              child: _buildActionTile(
                backgroundColor: schoolColor,
                icon: Icons.edit_square,
                iconColor: Colors.white,
                iconBg: Colors.white.withValues(alpha: 0.20),
                trailing: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFBFDBFE),
                  size: 18,
                ),
                title: 'Input Presensi',
                titleColor: Colors.white,
                subtitle: '$advisoryClass • Jam Ke-4',
                subtitleColor: const Color(0xFFDBEAFE),
                onTap: () {
                  HapticFeedback.selectionClick();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (_) => const AttendanceEntrySheet(),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            // Action 2: Scan RFID/QR (Gerbang 1)
            Expanded(
              child: _buildActionTile(
                backgroundColor: Colors.white,
                icon: Icons.qr_code_scanner_rounded,
                iconColor: schoolColor,
                iconBg: const Color(0xFFEFF6FF),
                trailing: Text(
                  'Gerbang 1',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                title: 'Scan RFID/QR',
                titleColor: const Color(0xFF0F172A),
                subtitle: 'Tap Kartu Masuk',
                subtitleColor: const Color(0xFF64748B),
                onTap: () => TeacherScanRfidDialog.show(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Action 3: Validasi Izin Sakit
            Expanded(
              child: _buildActionTile(
                backgroundColor: Colors.white,
                icon: Icons.assignment_turned_in_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFF5F3FF),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '2 Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: 'Validasi Izin',
                titleColor: const Color(0xFF0F172A),
                subtitle: 'Menunggu respon guru',
                subtitleColor: const Color(0xFF64748B),
                onTap: () => TeacherMedicalValidationDialog.show(context),
              ),
            ),
            const SizedBox(width: 10),
            // Action 4: Rekap & Unduh
            Expanded(
              child: _buildActionTile(
                backgroundColor: Colors.white,
                icon: Icons.summarize_rounded,
                iconColor: const Color(0xFF007D55),
                iconBg: const Color(0xFFECFDF5),
                trailing: const Icon(
                  Icons.file_download_outlined,
                  color: Color(0xFF64748B),
                  size: 18,
                ),
                title: 'Rekap & Unduh',
                titleColor: const Color(0xFF0F172A),
                subtitle: 'Format PDF/Excel',
                subtitleColor: const Color(0xFF64748B),
                onTap: () => TeacherDownloadReportDialog.show(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required Color backgroundColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required Widget trailing,
    required String title,
    required Color titleColor,
    required String subtitle,
    required Color subtitleColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFECEEF0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 19, color: iconColor),
                  ),
                  trailing,
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: subtitleColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
