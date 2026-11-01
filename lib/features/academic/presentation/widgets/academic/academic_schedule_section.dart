import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 3: Today's Class Schedule Section (Stitch Design)
/// Menampilkan jadwal pelajaran hari ini dengan indikator status live kelas, ruangan, dan guru pengampu
class AcademicScheduleSection extends StatelessWidget {
  final VoidCallback onCalendarTap;

  const AcademicScheduleSection({super.key, required this.onCalendarTap});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jadwal Hari Ini',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Kamis, 12 Maret 2026',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onCalendarTap();
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Kalender',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF003366),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(0xFF003366),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Schedule List
          _buildScheduleCard(
            timeRange: '07:30 - 09:00 WIB',
            subject: 'Matematika Peminatan',
            teacher: 'Bpk. Bambang Sutrisno, M.Pd',
            room: 'Lab MIPA 2',
            statusLabel: 'Sedang Berlangsung',
            statusColor: const Color(0xFF059669),
            statusBgColor: const Color(0xFFECFDF5),
            accentColor: const Color(0xFF10B981),
            isCurrent: true,
          ),
          const SizedBox(height: 10),
          _buildScheduleCard(
            timeRange: '09:15 - 10:45 WIB',
            subject: 'Fisika Terapan',
            teacher: 'Ibu Rina Melati, S.Si',
            room: 'Ruang 10-A',
            statusLabel: 'Berikutnya',
            statusColor: const Color(0xFF2563EB),
            statusBgColor: const Color(0xFFEFF6FF),
            accentColor: const Color(0xFF3B82F6),
            isCurrent: false,
          ),
          const SizedBox(height: 10),
          _buildScheduleCard(
            timeRange: '11:00 - 12:30 WIB',
            subject: 'Bahasa Inggris Lanjutan',
            teacher: 'Mr. David Wijaya, M.A',
            room: 'Ruang Bahasa',
            statusLabel: 'Nanti',
            statusColor: const Color(0xFF64748B),
            statusBgColor: const Color(0xFFF1F5F9),
            accentColor: const Color(0xFF94A3B8),
            isCurrent: false,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({
    required String timeRange,
    required String subject,
    required String teacher,
    required String room,
    required String statusLabel,
    required Color statusColor,
    required Color statusBgColor,
    required Color accentColor,
    required bool isCurrent,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? accentColor.withValues(alpha: 0.35)
              : const Color(0xFFECEEF0),
          width: isCurrent ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? accentColor.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: isCurrent ? 12 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left color accent bar
              Container(width: 5, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Time and Status Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: isCurrent
                                    ? accentColor
                                    : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                timeRange,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isCurrent
                                      ? accentColor
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isCurrent) ...[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                                Text(
                                  statusLabel,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Subject Title
                      Text(
                        subject,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Teacher & Room Footer
                      Row(
                        children: [
                          Icon(
                            Icons.person_pin_circle_outlined,
                            size: 14,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              teacher,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.meeting_room_outlined,
                                  size: 11,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  room,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
