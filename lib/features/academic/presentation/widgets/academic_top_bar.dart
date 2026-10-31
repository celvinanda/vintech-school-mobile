import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vintech_school_mobile/features/home/presentation/widgets/top_bar/top_bar_emblem.dart';
import '../../../auth/data/models/user_model.dart';

/// Top Bar Akademik Modular & Cerdas
/// Selaras 1:1 dengan tema Top Bar Beranda:
/// - Kiri: Emblem Ikon Akademik 40x40 dengan gradien warna sekolah
/// - Tengah: Judul "AKADEMIK & RAPOR" dan konteks Semester / Kelas
/// - Kanan: Badge IPK Pintar + Tombol Aksi Rapor Digital 40x40 Lingkaran
class AcademicTopBar extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final VoidCallback onReportTap;
  final VoidCallback? onRefresh;
  final double gpa;
  final String? academicPeriod;

  const AcademicTopBar({
    super.key,
    required this.profile,
    required this.schoolColor,
    required this.onReportTap,
    this.onRefresh,
    this.gpa = 88.6,
    this.academicPeriod = 'Semester Genap 2025/2026',
  });

  @override
  Widget build(BuildContext context) {
    final school = profile.activeSchool;
    final classroomName = school?.classroomName ?? 'Kelas X-IPA-1';

    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Modular Emblem Akademik
          TopBarEmblem(
            schoolColor: schoolColor,
            icon: Icons.auto_stories_rounded,
            onTap: onReportTap,
          ),
          const SizedBox(width: 12),

          // 2. Smart Title & Contextual Period
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onReportTap();
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AKADEMIK & RAPOR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    '$academicPeriod • $classroomName',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 3. GPA Capsule Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: schoolColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: schoolColor.withValues(alpha: 0.20),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 13,
                  color: schoolColor,
                ),
                const SizedBox(width: 3),
                Text(
                  '$gpa',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: schoolColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 4. Circular Report Action Button (Seragam dengan Lonceng Beranda)
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onReportTap();
              },
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFECEEF0), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.description_outlined,
                    color: Color(0xFF475569),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
