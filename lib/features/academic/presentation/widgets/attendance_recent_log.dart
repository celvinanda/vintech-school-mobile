import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/attendance_model.dart';

/// Card 5: Recent Attendance Log / Riwayat Presensi Terbaru (Google Stitch Design)
/// Menampilkan log presensi beberapa hari terakhir dengan status badge
class AttendanceRecentLog extends StatelessWidget {
  final List<AttendanceModel> personalRecords;

  const AttendanceRecentLog({super.key, required this.personalRecords});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riwayat Presensi Terbaru',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF191C1E),
                ),
              ),
              Text(
                '4 Hari Terakhir',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF004AC6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List of recent items
          if (personalRecords.isNotEmpty)
            ...personalRecords.map(
              (item) => _RecentItemTile(
                dayDate: item.date,
                statusBadge: item.statusDisplay,
                statusColor: item.status == 'HADIR'
                    ? const Color(0xFF007D55)
                    : (item.status == 'IZIN'
                          ? const Color(0xFF004AC6)
                          : (item.status == 'SAKIT'
                                ? const Color(0xFFD97706)
                                : const Color(0xFFBA1A1A))),
                statusBg: item.status == 'HADIR'
                    ? const Color(0xFF007D55).withValues(alpha: 0.12)
                    : (item.status == 'IZIN'
                          ? const Color(0xFF004AC6).withValues(alpha: 0.10)
                          : (item.status == 'SAKIT'
                                ? const Color(0xFFD97706)
                                      .withValues(alpha: 0.12)
                                : const Color(0xFFBA1A1A)
                                      .withValues(alpha: 0.10))),
                details: item.notes.isNotEmpty
                    ? item.notes
                    : 'Presensi tercatat di sistem',
                icon: item.status == 'HADIR'
                    ? Icons.check_rounded
                    : (item.status == 'IZIN'
                          ? Icons.info_outline_rounded
                          : (item.status == 'SAKIT'
                                ? Icons.healing_rounded
                                : Icons.cancel_outlined)),
              ),
            )
          else ...[
            // Stitch Default Item 1: Hari Ini
            const _RecentItemTile(
              dayDate: 'Kamis, 12 Maret 2026',
              statusBadge: 'Tepat Waktu',
              statusColor: Color(0xFF007D55),
              statusBg: Color(0x1F007D55),
              details: 'Masuk: 07:15 WIB • Gerbang Utama SMA Negeri 1 Jakarta',
              icon: Icons.check_rounded,
            ),
            const SizedBox(height: 8),
            // Stitch Default Item 2: Rabu
            const _RecentItemTile(
              dayDate: 'Rabu, 11 Maret 2026',
              statusBadge: 'Lengkap',
              statusColor: Color(0xFF004AC6),
              statusBg: Color(0x1A004AC6),
              details: 'Masuk: 07:18 WIB | Pulang: 15:32 WIB',
              icon: Icons.check_rounded,
            ),
            const SizedBox(height: 8),
            // Stitch Default Item 3: Selasa
            const _RecentItemTile(
              dayDate: 'Selasa, 10 Maret 2026',
              statusBadge: 'Izin Sakit',
              statusColor: Color(0xFF003EA8),
              statusBg: Color(0xFFDAE2FD),
              details: 'Disetujui oleh Wali Kelas (Surat Dokter)',
              icon: Icons.verified_rounded,
            ),
            const SizedBox(height: 8),
            // Stitch Default Item 4: Senin
            const _RecentItemTile(
              dayDate: 'Senin, 09 Maret 2026',
              statusBadge: 'Lengkap',
              statusColor: Color(0xFF004AC6),
              statusBg: Color(0x1A004AC6),
              details: 'Masuk: 07:22 WIB | Pulang: 15:35 WIB • Upacara Bendera',
              icon: Icons.check_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentItemTile extends StatelessWidget {
  final String dayDate;
  final String statusBadge;
  final Color statusColor;
  final Color statusBg;
  final String details;
  final IconData icon;

  const _RecentItemTile({
    required this.dayDate,
    required this.statusBadge,
    required this.statusColor,
    required this.statusBg,
    required this.details,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: statusBg, shape: BoxShape.circle),
            child: Icon(icon, color: statusColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dayDate,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF191C1E),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusBadge,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  details,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF565E74),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
