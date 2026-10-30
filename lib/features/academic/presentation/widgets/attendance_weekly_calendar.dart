import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 3: Weekly Strip Mini-Calendar (Google Stitch Design)
/// Menampilkan kalender strip 7 hari (Senin - Minggu) dengan status dot kehadiran
class AttendanceWeeklyCalendar extends StatelessWidget {
  const AttendanceWeeklyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

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
                Text(
                  'Pekan Ini',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF191C1E),
                  ),
                ),
                Text(
                  'Minggu ke-2 • Maret',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF565E74),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dayDate = monday.add(Duration(days: index));
                final isToday = dayDate.day == now.day && dayDate.month == now.month;
                final isWeekend = index >= 5;

                Color dotColor;
                if (index < now.weekday - 1) {
                  dotColor = const Color(0xFF007D55); // Hari lewat: Hadir
                } else if (isToday) {
                  dotColor = const Color(0xFF004AC6); // Hari ini
                } else {
                  dotColor = const Color(0xFFE0E3E5); // Mendatang
                }

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 6 ? 0 : 5),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFFDBE1FF) // Stitch primary fixed
                          : const Color(0xFFF2F4F6),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: const Color(0xFF004AC6).withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Opacity(
                      opacity: isWeekend ? 0.55 : 1.0,
                      child: Column(
                        children: [
                          Text(
                            dayLabels[index],
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                              color: isToday ? const Color(0xFF00174B) : const Color(0xFF565E74),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dayDate.day.toString().padLeft(2, '0'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                              color: isToday ? const Color(0xFF00174B) : const Color(0xFF191C1E),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
