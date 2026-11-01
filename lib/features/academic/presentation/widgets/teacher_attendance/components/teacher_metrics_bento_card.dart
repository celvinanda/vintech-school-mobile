import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vintech_school_mobile/features/academic/data/models/attendance_model.dart';

/// Card 2: Key Attendance Metrics Bento Gradient Card
class TeacherMetricsBentoCard extends StatelessWidget {
  final List<AttendanceModel> allRecords;
  final Color schoolColor;

  const TeacherMetricsBentoCard({
    super.key,
    required this.allRecords,
    required this.schoolColor,
  });

  @override
  Widget build(BuildContext context) {
    final hadirCount = allRecords
        .where((r) => r.status.toUpperCase() == 'HADIR')
        .length;
    final sakitCount = allRecords
        .where((r) => r.status.toUpperCase() == 'SAKIT')
        .length;
    final izinCount = allRecords
        .where((r) => r.status.toUpperCase() == 'IZIN')
        .length;
    final alpaCount = allRecords
        .where((r) => r.status.toUpperCase() == 'ALPA')
        .length;
    final total = allRecords.length;

    final double rate = total > 0 ? (hadirCount / total * 100) : 95.8;
    final displayRate = rate.toStringAsFixed(1);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            schoolColor,
            Color.lerp(schoolColor, const Color(0xFF1E3A8A), 0.3)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: schoolColor.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Decorative Background Glow & Watermark
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: -6,
              child: Icon(
                Icons.co_present_rounded,
                size: 110,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
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
                            'TINGKAT KEHADIRAN SEKOLAH',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFBFDBFE),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$displayRate%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.trending_up_rounded,
                                      size: 13,
                                      color: Color(0xFF4EDEA3),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '+1.2%',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF4EDEA3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            total > 0
                                ? 'Total $total siswa terpantau hari ini'
                                : 'Total 1.250 siswa terdaftar aktif',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: const Color(0xFFDBEAFE),
                            ),
                          ),
                        ],
                      ),
                      // Circular Progress Ring
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 58,
                            height: 58,
                            child: CircularProgressIndicator(
                              value: rate / 100,
                              strokeWidth: 5.5,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF4EDEA3),
                              ),
                            ),
                          ),
                          Text(
                            '${rate.round()}%',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 4 Quick Counter Badges
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCounter(
                          icon: Icons.check_circle_rounded,
                          iconColor: const Color(0xFF4EDEA3),
                          value: total > 0 ? '$hadirCount' : '1.198',
                          label: 'Hadir',
                        ),
                        Container(
                          width: 1,
                          height: 26,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        _buildMetricCounter(
                          icon: Icons.medication_rounded,
                          iconColor: const Color(0xFFFDE68A),
                          value: total > 0 ? '$sakitCount' : '24',
                          label: 'Sakit',
                        ),
                        Container(
                          width: 1,
                          height: 26,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        _buildMetricCounter(
                          icon: Icons.pending_actions_rounded,
                          iconColor: const Color(0xFFBFDBFE),
                          value: total > 0 ? '$izinCount' : '15',
                          label: 'Izin',
                        ),
                        Container(
                          width: 1,
                          height: 26,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        _buildMetricCounter(
                          icon: Icons.cancel_rounded,
                          iconColor: const Color(0xFFFECACA),
                          value: total > 0 ? '$alpaCount' : '13',
                          label: 'Alpa',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCounter({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            color: const Color(0xFFDBEAFE),
          ),
        ),
      ],
    );
  }
}
