import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 4: Attendance Metrics & Ringkasan Kehadiran Bulanan (Google Stitch Design)
/// Grid 2x2 status statistik kehadiran dan linear indicator tingkat kedisiplinan
class AttendanceMetricsCard extends StatelessWidget {
  final int hadirCount;
  final int izinCount;
  final int sakitCount;
  final int alpaCount;
  final double disciplineRate;

  const AttendanceMetricsCard({
    super.key,
    required this.hadirCount,
    required this.izinCount,
    required this.sakitCount,
    required this.alpaCount,
    required this.disciplineRate,
  });

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Kehadiran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF191C1E),
                      ),
                    ),
                    Text(
                      'Periode: Semester Genap 2026',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF565E74),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Maret',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF191C1E),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.expand_more_rounded, size: 16, color: Color(0xFF565E74)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 4 Metrics Grid (Stitch 2x2 Grid)
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Hadir',
                    value: '$hadirCount',
                    badgeText: '${disciplineRate.toStringAsFixed(0)}%',
                    badgeColor: const Color(0xFF007D55),
                    badgeBg: const Color(0xFF007D55).withValues(alpha: 0.12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    label: 'Izin',
                    value: '$izinCount',
                    badgeText: 'Disetujui',
                    badgeColor: const Color(0xFF004AC6),
                    badgeBg: const Color(0xFF004AC6).withValues(alpha: 0.10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Sakit',
                    value: '$sakitCount',
                    badgeText: 'Surat',
                    badgeColor: const Color(0xFFD97706),
                    badgeBg: const Color(0xFFD97706).withValues(alpha: 0.12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    label: 'Alpa',
                    value: '$alpaCount',
                    badgeText: 'Tertib',
                    badgeColor: const Color(0xFFBA1A1A),
                    badgeBg: const Color(0xFFBA1A1A).withValues(alpha: 0.10),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Semester Progress Bar (Stitch Linear Indicator)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tingkat Kedisiplinan Semester',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF191C1E),
                  ),
                ),
                Text(
                  '${disciplineRate.toStringAsFixed(0)}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF007D55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: disciplineRate / 100,
                minHeight: 8,
                backgroundColor: const Color(0xFFE0E3E5),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF007D55)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBg;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: const Color(0xFF565E74),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF191C1E),
            ),
          ),
        ],
      ),
    );
  }
}
