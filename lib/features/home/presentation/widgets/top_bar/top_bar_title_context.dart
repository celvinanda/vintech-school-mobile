import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sub-komponen 2: Smart Title & Contextual Header
/// Komponen cerdas yang otomatis mendeteksi:
/// 1. Sapaan berbasis waktu lokal (Pagi / Siang / Sore / Malam)
/// 2. Nama depan pengguna & status peranan
/// 3. Indikator multi-sekolah (jika memiliki akun di lebih dari 1 sekolah)
class TopBarTitleContext extends StatelessWidget {
  final String schoolName;
  final String fullName;
  final String? classroomName;
  final String? academicPeriod;
  final bool isStaffOrTeacher;
  final bool hasMultipleSchools;
  final VoidCallback onTap;

  const TopBarTitleContext({
    super.key,
    required this.schoolName,
    required this.fullName,
    this.classroomName,
    this.academicPeriod = 'Semester Genap 2025/2026',
    this.isStaffOrTeacher = false,
    this.hasMultipleSchools = false,
    required this.onTap,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  String get _firstName {
    final clean = fullName.trim();
    if (clean.isEmpty) {
      return isStaffOrTeacher ? 'Guru' : 'Siswa';
    }
    return clean.split(' ').first;
  }

  String get _subtitle {
    if (classroomName != null && classroomName!.isNotEmpty) {
      return '$_greeting, $_firstName • $classroomName';
    }
    return '$_greeting, $_firstName';
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: School Name + Dropdown indicator if multi-school
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    schoolName.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasMultipleSchools) ...[
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 16,
                      color: Color(0xFF004AC6),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),

            // Bottom Subtitle: Dynamic Time Greeting & Class Context
            Row(
              children: [
                Flexible(
                  child: Text(
                    _subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
