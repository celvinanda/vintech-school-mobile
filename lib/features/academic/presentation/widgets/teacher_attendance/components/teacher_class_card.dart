import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/class_attendance_info.dart';

/// Kartu Monitoring Status Kehadiran per Rombel / Kelas
class TeacherClassCard extends StatelessWidget {
  final ClassAttendanceInfo classInfo;
  final Color schoolColor;
  final VoidCallback onAction;

  const TeacherClassCard({
    super.key,
    required this.classInfo,
    required this.schoolColor,
    required this.onAction,
  });

  bool get _isWarning => classInfo.statusKey == 'pending';
  bool get _isPrimary => classInfo.statusKey == 'waiting';

  String get _actionButtonLabel {
    if (classInfo.statusKey == 'locked') return 'Detail Siswa';
    if (classInfo.statusKey == 'pending') return 'Ingatkan Guru';
    return 'Input Sekarang';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECEEF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    classInfo.className,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: classInfo.badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      classInfo.badgeTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: classInfo.badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: classInfo.statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      classInfo.statusIcon,
                      size: 12,
                      color: classInfo.statusTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      classInfo.statusLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: classInfo.statusTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            classInfo.roomSubtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          // Progress & Multi-Segment Indicator
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      classInfo.progressText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    Text(
                      classInfo.cloudSyncText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF007D55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: classInfo.hadirCount > 0
                            ? classInfo.hadirCount
                            : 1,
                        child: Container(
                          height: 5,
                          color: classInfo.hadirCount > 0
                              ? const Color(0xFF007D55)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      if (classInfo.sakitCount > 0)
                        Expanded(
                          flex: classInfo.sakitCount,
                          child: Container(
                            height: 5,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      if (classInfo.izinCount > 0)
                        Expanded(
                          flex: classInfo.izinCount,
                          child: Container(
                            height: 5,
                            color: const Color(0xFF004AC6),
                          ),
                        ),
                      if (classInfo.alpaCount > 0)
                        Expanded(
                          flex: classInfo.alpaCount,
                          child: Container(
                            height: 5,
                            color: const Color(0xFFDC2626),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${classInfo.hadirCount} Hadir',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${classInfo.sakitCount} Sakit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '${classInfo.izinCount} Izin',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '${classInfo.alpaCount} Alpa',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                classInfo.footerNote,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  color: const Color(0xFF64748B),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPrimary
                      ? schoolColor
                      : (_isWarning
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFF1F5F9)),
                  foregroundColor: _isPrimary
                      ? Colors.white
                      : (_isWarning
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF0F172A)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: _isWarning
                        ? const BorderSide(color: Color(0xFFFECACA))
                        : BorderSide.none,
                  ),
                ),
                onPressed: onAction,
                child: Text(
                  _actionButtonLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
