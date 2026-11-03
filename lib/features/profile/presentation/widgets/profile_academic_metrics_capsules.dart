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
    this.gpa = 0.0,
    this.gradeLetter = '-',
    this.attendanceRate = 0,
    this.attendanceRank = '0 Hadir',
    this.tuitionStatus = '-',
    this.tuitionMonth = '-',
  });
  bool get _isStaffOrTeacher => profile?.activeSchool?.isStaffOrTeacher == true;
  bool get _isParent => profile?.activeSchool?.isParent == true;
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isStaffOrTeacher
                ? 'Ikhtisar Tugas & Jam Kerja'
                : (_isParent
                      ? 'Ikhtisar Pemantauan Anak'
                      : 'Ikhtisar Performa Akademik'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          // 3 Columns Row
          Row(
            children: [
              // Capsule 1
              Expanded(
                child: _buildCapsule(
                  icon: _isStaffOrTeacher
                      ? Icons.schedule_rounded
                      : Icons.auto_stories_rounded,
                  iconColor: const Color(0xFF004AC6),
                  iconBg: const Color(0xFFEFF6FF),
                  badgeLabel: _isStaffOrTeacher
                      ? '-'
                      : (gpa <= 0 ? '-' : gradeLetter),
                  badgeColor: _isStaffOrTeacher
                      ? const Color(0xFF64748B)
                      : (gpa <= 0
                            ? const Color(0xFF64748B)
                            : const Color(0xFF004AC6)),
                  badgeBg: _isStaffOrTeacher
                      ? const Color(0xFFF1F5F9)
                      : (gpa <= 0
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFDBEAFE)),
                  value: _isStaffOrTeacher
                      ? '0 JP'
                      : (gpa <= 0
                            ? '0'
                            : (gpa == gpa.roundToDouble()
                                  ? '${gpa.toInt()}'
                                  : '$gpa')),
                  subtitle: _isStaffOrTeacher
                      ? 'Beban KBM'
                      : (_isParent ? 'Rata Nilai Anak' : 'Rata-rata Nilai'),
                ),
              ),
              const SizedBox(width: 8),
              // Capsule 2
              Expanded(
                child: _buildCapsule(
                  icon: Icons.checklist_rounded,
                  iconColor: const Color(0xFF007D55),
                  iconBg: const Color(0xFFECFDF5),
                  badgeLabel: attendanceRate <= 0 ? '0 Hadir' : attendanceRank,
                  badgeColor: attendanceRate <= 0
                      ? const Color(0xFF64748B)
                      : const Color(0xFF007D55),
                  badgeBg: attendanceRate <= 0
                      ? const Color(0xFFF1F5F9)
                      : const Color(0xFFA7F3D0),
                  value: '$attendanceRate%',
                  subtitle: _isStaffOrTeacher
                      ? 'Presensi Guru'
                      : (_isParent ? 'Presensi Anak' : 'Kehadiran'),
                ),
              ),
              const SizedBox(width: 8),
              // Capsule 3
              Expanded(
                child: _buildCapsule(
                  icon: _isStaffOrTeacher
                      ? Icons.meeting_room_rounded
                      : (_isParent
                            ? Icons.account_balance_wallet_rounded
                            : Icons.verified_rounded),
                  iconColor: _isStaffOrTeacher
                      ? ((profile
                                    ?.activeSchool
                                    ?.classroomNameField
                                    ?.isNotEmpty ==
                                true)
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF64748B))
                      : (tuitionStatus == 'Belum Lunas'
                            ? const Color(0xFFDC2626)
                            : (tuitionStatus == 'Lunas'
                                  ? const Color(0xFF0F766E)
                                  : const Color(0xFF64748B))),
                  iconBg: _isStaffOrTeacher
                      ? ((profile
                                    ?.activeSchool
                                    ?.classroomNameField
                                    ?.isNotEmpty ==
                                true)
                            ? const Color(0xFFF0FDFA)
                            : const Color(0xFFF1F5F9))
                      : (tuitionStatus == 'Belum Lunas'
                            ? const Color(0xFFFEF2F2)
                            : (tuitionStatus == 'Lunas'
                                  ? const Color(0xFFF0FDFA)
                                  : const Color(0xFFF1F5F9))),
                  badgeLabel: _isStaffOrTeacher
                      ? ((profile
                                    ?.activeSchool
                                    ?.classroomNameField
                                    ?.isNotEmpty ==
                                true)
                            ? 'Wali Kelas'
                            : '-')
                      : tuitionStatus,
                  badgeColor: _isStaffOrTeacher
                      ? ((profile
                                    ?.activeSchool
                                    ?.classroomNameField
                                    ?.isNotEmpty ==
                                true)
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF64748B))
                      : (tuitionStatus == 'Belum Lunas'
                            ? const Color(0xFFDC2626)
                            : (tuitionStatus == 'Lunas'
                                  ? const Color(0xFF0F766E)
                                  : const Color(0xFF64748B))),
                  badgeBg: _isStaffOrTeacher
                      ? ((profile
                                    ?.activeSchool
                                    ?.classroomNameField
                                    ?.isNotEmpty ==
                                true)
                            ? const Color(0xFFCCFBF1)
                            : const Color(0xFFF1F5F9))
                      : (tuitionStatus == 'Belum Lunas'
                            ? const Color(0xFFFEE2E2)
                            : (tuitionStatus == 'Lunas'
                                  ? const Color(0xFFCCFBF1)
                                  : const Color(0xFFF1F5F9))),
                  value: _isStaffOrTeacher
                      ? (profile
                                    ?.activeSchool
                                    ?.classroomNameField
                                    ?.isNotEmpty ==
                                true
                            ? profile!.activeSchool!.classroomNameField!
                            : '-')
                      : (tuitionMonth.isNotEmpty ? tuitionMonth : '-'),
                  subtitle: _isStaffOrTeacher
                      ? 'Kelas Binaan'
                      : (_isParent ? 'Tagihan SPP Anak' : 'Status SPP'),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1.5,
                ),
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
