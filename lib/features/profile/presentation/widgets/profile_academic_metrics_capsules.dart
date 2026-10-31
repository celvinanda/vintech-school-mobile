import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/data/models/user_model.dart';

/// Card 3: 3 Quick Metric Capsules for Academic Overview (Stitch Design)
/// Menampilkan indikator performa yang cerdas dan adaptif sesuai peran (Siswa / Guru)
class ProfileAcademicMetricsCapsules extends StatelessWidget {
  final UserProfileResponse? profile;
  final double gpa;
  final String gradeLetter;
  final int attendanceRate;
  final String attendanceRank;
  final String tuitionStatus;
  final String tuitionMonth;

  const ProfileAcademicMetricsCapsules({
    super.key,
    this.profile,
    this.gpa = 88.5,
    this.gradeLetter = 'A',
    this.attendanceRate = 96,
    this.attendanceRank = 'Top 5',
    this.tuitionStatus = 'Lunas',
    this.tuitionMonth = 'November',
  });

  bool get _isStaffOrTeacher => profile?.activeSchool?.isStaffOrTeacher == true;

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
                _isStaffOrTeacher ? 'Ikhtisar Tugas & Jam Kerja' : 'Ikhtisar Performa Akademik',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'TP 2026/2027',
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
              // Capsule 1
              Expanded(
                child: _buildCapsule(
                  icon: _isStaffOrTeacher ? Icons.schedule_rounded : Icons.auto_stories_rounded,
                  iconColor: const Color(0xFF004AC6),
                  iconBg: const Color(0xFFEFF6FF),
                  badgeLabel: _isStaffOrTeacher ? 'Normal' : gradeLetter,
                  badgeColor: const Color(0xFF004AC6),
                  badgeBg: const Color(0xFFDBEAFE),
                  value: _isStaffOrTeacher ? '24 JP' : '$gpa',
                  subtitle: _isStaffOrTeacher ? 'Jam Mengajar' : 'Rata-rata Nilai',
                ),
              ),
              const SizedBox(width: 8),

              // Capsule 2
              Expanded(
                child: _buildCapsule(
                  icon: Icons.checklist_rounded,
                  iconColor: const Color(0xFF007D55),
                  iconBg: const Color(0xFFECFDF5),
                  badgeLabel: _isStaffOrTeacher ? 'Tepat Waktu' : attendanceRank,
                  badgeColor: const Color(0xFF007D55),
                  badgeBg: const Color(0xFFA7F3D0),
                  value: _isStaffOrTeacher ? '98%' : '$attendanceRate%',
                  subtitle: _isStaffOrTeacher ? 'Presensi Guru' : 'Kehadiran',
                ),
              ),
              const SizedBox(width: 8),

              // Capsule 3
              Expanded(
                child: _buildCapsule(
                  icon: _isStaffOrTeacher ? Icons.meeting_room_rounded : Icons.verified_rounded,
                  iconColor: const Color(0xFF0F766E),
                  iconBg: const Color(0xFFF0FDFA),
                  badgeLabel: _isStaffOrTeacher ? 'Binaan' : tuitionStatus,
                  badgeColor: const Color(0xFF0F766E),
                  badgeBg: const Color(0xFFCCFBF1),
                  value: _isStaffOrTeacher ? (profile?.activeSchool?.classroomName ?? 'X-IPA-1') : tuitionMonth,
                  subtitle: _isStaffOrTeacher ? 'Wali Kelas' : 'Status SPP',
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
