import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 1: Live Clock & Geo-Radius Status Card (Google Stitch Design)
/// Menggunakan timer mandiri agar update detik jam terisolasi dan tidak me-rebuild seluruh layar
class AttendanceLiveClockCard extends StatefulWidget {
  final String schoolName;

  const AttendanceLiveClockCard({
    super.key,
    required this.schoolName,
  });

  @override
  State<AttendanceLiveClockCard> createState() => _AttendanceLiveClockCardState();
}

class _AttendanceLiveClockCardState extends State<AttendanceLiveClockCard> {
  Timer? _ticker;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatLiveDate(DateTime dt) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final dayName = days[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  String _formatLiveTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

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
            // Top Row: Live Date & GPS Connected Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: Color(0xFF565E74),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatLiveDate(_currentTime),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF565E74),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF007D55),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Terkoneksi GPS',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF007D55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Middle Row: Big Live Clock + Limit Text + Schedule Icon Container
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatLiveTime(_currentTime),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF191C1E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'WIB',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF565E74),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Batas jam masuk: 07:30 WIB',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF565E74),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF004AC6).withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF004AC6),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Radius Notification Chip (Stitch Design)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F6), // Surface Container Low
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF007D55),
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF434655),
                        ),
                        children: [
                          const TextSpan(text: 'Dalam radius valid: '),
                          TextSpan(
                            text: widget.schoolName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF191C1E),
                            ),
                          ),
                          const TextSpan(text: ' (Gerbang Utama)'),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
}
