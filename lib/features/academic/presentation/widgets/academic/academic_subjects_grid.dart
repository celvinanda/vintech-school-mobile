import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 5: Subjects Overview 2x2 Bento Grid (Stitch Design)
/// Menampilkan ringkasan capaian nilai, predikat huruf, dan persentase kehadiran per mata pelajaran
class AcademicSubjectsGrid extends StatelessWidget {
  final VoidCallback onViewAllTap;

  const AcademicSubjectsGrid({super.key, required this.onViewAllTap});

  static const List<_SubjectItem> _subjects = [
    _SubjectItem(
      title: 'Matematika Pem.',
      code: 'MIPA-101',
      score: 92,
      gradeLetter: 'A',
      attendance: 100,
      teacher: 'Bpk. Bambang',
      accentColor: Color(0xFF003366),
    ),
    _SubjectItem(
      title: 'Fisika Terapan',
      code: 'MIPA-102',
      score: 88,
      gradeLetter: 'A-',
      attendance: 96,
      teacher: 'Ibu Rina',
      accentColor: Color(0xFF007D55),
    ),
    _SubjectItem(
      title: 'Kimia Dasar',
      code: 'MIPA-103',
      score: 85,
      gradeLetter: 'B+',
      attendance: 94,
      teacher: 'Ibu Siti',
      accentColor: Color(0xFFD97706),
    ),
    _SubjectItem(
      title: 'Biologi Molekuler',
      code: 'MIPA-104',
      score: 90,
      gradeLetter: 'A',
      attendance: 98,
      teacher: 'Bpk. Hendra',
      accentColor: Color(0xFF7C3AED),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Mata Pelajaran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onViewAllTap();
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
                        'Semua Nilai',
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

          // 2x2 Grid using Rows for zero layout jump & smooth scrolling
          Row(
            children: [
              Expanded(child: _buildSubjectCard(context, _subjects[0])),
              const SizedBox(width: 10),
              Expanded(child: _buildSubjectCard(context, _subjects[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildSubjectCard(context, _subjects[2])),
              const SizedBox(width: 10),
              Expanded(child: _buildSubjectCard(context, _subjects[3])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, _SubjectItem item) {
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
          // Top row: Code badge + Grade Letter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.code,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: item.accentColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.gradeLetter,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            item.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item.teacher,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Score bar & value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nilai: ${item.score}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item.accentColor,
                ),
              ),
              Text(
                'Hadir ${item.attendance}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: item.score / 100.0,
              minHeight: 5,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(item.accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectItem {
  final String title;
  final String code;
  final int score;
  final String gradeLetter;
  final int attendance;
  final String teacher;
  final Color accentColor;

  const _SubjectItem({
    required this.title,
    required this.code,
    required this.score,
    required this.gradeLetter,
    required this.attendance,
    required this.teacher,
    required this.accentColor,
  });
}
