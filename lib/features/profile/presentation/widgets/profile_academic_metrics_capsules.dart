import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 3: 3 Quick Metric Capsules for Student Academic Overview (Stitch Design)
/// Menampilkan Nilai Rata-rata (88.5 / A), Persentase Kehadiran (96% / Top 5), dan Status Bebas SPP (Lunas)
class ProfileAcademicMetricsCapsules extends StatelessWidget {
  final double gpa;
  final String gradeLetter;
  final int attendanceRate;
  final String attendanceRank;
  final String tuitionStatus;
  final String tuitionMonth;

  const ProfileAcademicMetricsCapsules({
    super.key,
    this.gpa = 88.5,
    this.gradeLetter = 'A',
    this.attendanceRate = 96,
    this.attendanceRank = 'Top 5',
    this.tuitionStatus = 'Lunas',
    this.tuitionMonth = 'Maret',
  });

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
                'Ikhtisar Performa Akademik',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'Semester 2',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3 Columns Row
          Row(
            children: [
              // Capsule 1: Nilai Rata-rata
              Expanded(
                child: _buildCapsule(
                  icon: Icons.auto_stories_rounded,
                  iconColor: const Color(0xFF004AC6),
                  iconBg: const Color(0xFFEFF6FF),
                  badgeLabel: gradeLetter,
                  badgeColor: const Color(0xFF004AC6),
                  badgeBg: const Color(0xFFDBEAFE),
                  value: '$gpa',
                  subtitle: 'Rata-rata Nilai',
                ),
              ),
              const SizedBox(width: 8),

              // Capsule 2: Kehadiran
              Expanded(
                child: _buildCapsule(
                  icon: Icons.checklist_rounded,
                  iconColor: const Color(0xFF007D55),
                  iconBg: const Color(0xFFECFDF5),
                  badgeLabel: attendanceRank,
                  badgeColor: const Color(0xFF007D55),
                  badgeBg: const Color(0xFFA7F3D0),
                  value: '$attendanceRate%',
                  subtitle: 'Kehadiran',
                ),
              ),
              const SizedBox(width: 8),

              // Capsule 3: Status SPP
              Expanded(
                child: _buildCapsule(
                  icon: Icons.verified_rounded,
                  iconColor: const Color(0xFF0F766E),
                  iconBg: const Color(0xFFF0FDFA),
                  badgeLabel: tuitionStatus,
                  badgeColor: const Color(0xFF0F766E),
                  badgeBg: const Color(0xFFCCFBF1),
                  value: tuitionMonth,
                  subtitle: 'Bebas SPP',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCapsule({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String badgeLabel,
    required Color badgeColor,
    required Color badgeBg,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
