import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../logic/home_cubit.dart';
import '../../logic/home_state.dart';

/// Komponen Ringkasan Kehadiran Semester Ini (Stitch Attendance Bento Card)
/// Dilengkapi 4 Stat Capsules & Live Status Banner Hari Ini
class StudentAttendanceSummaryCard extends StatelessWidget {
  final Function(int tabIndex) onNavigateTab;

  const StudentAttendanceSummaryCard({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          int present = 24;
          int izin = 1;
          int sakit = 0;
          int alpa = 0;
          double rate = 96.0;

          if (state is HomeLoaded) {
            final att = state.dashboard.attendanceToday;
            present = att.presentCount > 0 ? att.presentCount : 24;
            izin = att.izinCount;
            sakit = att.sakitCount;
            alpa = att.alpaCount;
            rate = att.attendanceRate > 0 ? att.attendanceRate : 96.0;
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFECEEF0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with 96% Discipline Rate Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF004AC6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Kehadiran Semester Ini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF191C1E),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007D55).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${rate.toStringAsFixed(0)}% Disiplin',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF007D55),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 4 Stat Capsules Row
                Row(
                  children: [
                    _StatCapsule(label: 'Hadir', count: '$present', color: const Color(0xFF007D55)),
                    const SizedBox(width: 8),
                    _StatCapsule(label: 'Izin', count: '$izin', color: const Color(0xFF004AC6)),
                    const SizedBox(width: 8),
                    _StatCapsule(label: 'Sakit', count: '$sakit', color: const Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    _StatCapsule(label: 'Alpa', count: '$alpa', color: const Color(0xFFBA1A1A)),
                  ],
                ),

                const SizedBox(height: 14),

                // Today's Live Status Banner
                Material(
                  color: const Color(0xFF6FFBBE).withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onNavigateTab(1);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4EDEA3).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF007D55),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Presensi Hari Ini: Tepat Waktu',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF191C1E),
                                  ),
                                ),
                                Text(
                                  'Tercatat pukul 07:15 WIB di Gerbang Utama',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: const Color(0xFF434655),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF565E74),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCapsule extends StatelessWidget {
  final String label;
  final String count;
  final Color color;

  const _StatCapsule({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F6), // Surface Container Low
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF565E74),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
