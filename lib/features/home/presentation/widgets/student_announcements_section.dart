import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/school_dashboard_model.dart';
import '../../logic/home_cubit.dart';
import '../../logic/home_state.dart';

/// Komponen Feed Pengumuman Sekolah (Stitch Announcements Feed)
/// Menampilkan pengumuman resmi dengan badge kategori, snippet, dan lampiran
class StudentAnnouncementsSection extends StatelessWidget {
  const StudentAnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          List<AnnouncementModel> items = [];
          if (state is HomeLoaded) {
            items = state.dashboard.announcements;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pengumuman Sekolah',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF191C1E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                    },
                    child: Row(
                      children: [
                        Text(
                          'Lihat Semua',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF004AC6),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Color(0xFF004AC6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Announcement Feed Cards
              if (items.isNotEmpty)
                ...items.map((ann) => AnnouncementCardItem(
                      categoryBadge: ann.isPinned ? 'PENTING' : 'INFORMASI',
                      isImportant: ann.isPinned,
                      timestamp: ann.createdAt.length >= 10 ? ann.createdAt.substring(0, 10) : ann.createdAt,
                      author: ann.audienceDisplay,
                      title: ann.title,
                      snippet: ann.content,
                      attachmentLabel: 'Lampiran_${ann.audienceDisplay}.pdf',
                    ))
              else ...[
                // Default Stitch Card 1
                const AnnouncementCardItem(
                  categoryBadge: 'PENTING',
                  isImportant: true,
                  timestamp: 'Hari ini, 09:00 WIB',
                  author: 'Kurikulum',
                  title: 'Jadwal Penilaian Tengah Semester (PTS) Genap 2026',
                  snippet:
                      'Pelaksanaan PTS Genap akan dimulai tanggal 16 Maret secara hybrid menggunakan tablet/smartphone sekolah.',
                  attachmentLabel: 'Jadwal_PTS_Genap.pdf (1.2 MB)',
                ),
                const SizedBox(height: 10),
                // Default Stitch Card 2
                const AnnouncementCardItem(
                  categoryBadge: 'INFORMASI',
                  isImportant: false,
                  timestamp: 'Kemarin, 14:30 WIB',
                  author: 'Kesiswaan',
                  title: 'Pendaftaran Ekstrakurikuler Robotika & Coding Club',
                  snippet:
                      'Pendaftaran dibuka untuk siswa kelas X & XI melalui portal Vintech hingga akhir pekan ini. Kuota terbatas 30 peserta.',
                  attachmentLabel: 'Sisa Kuota: 8 Siswa',
                  isQuota: true,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class AnnouncementCardItem extends StatelessWidget {
  final String categoryBadge;
  final bool isImportant;
  final String timestamp;
  final String author;
  final String title;
  final String snippet;
  final String attachmentLabel;
  final bool isQuota;

  const AnnouncementCardItem({
    super.key,
    required this.categoryBadge,
    required this.isImportant,
    required this.timestamp,
    required this.author,
    required this.title,
    required this.snippet,
    required this.attachmentLabel,
    this.isQuota = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: isImportant ? const Color(0xFFFFDAD6) : const Color(0xFFDBE1FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  categoryBadge,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isImportant ? const Color(0xFF93000A) : const Color(0xFF00174B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '$timestamp • $author',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF565E74),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF191C1E),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            snippet,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF434655),
              height: 1.45,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isQuota ? Icons.group_add_rounded : Icons.attachment_rounded,
                    size: 15,
                    color: const Color(0xFF565E74),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    attachmentLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF565E74),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_circle_right_rounded,
                size: 18,
                color: Color(0xFF004AC6),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
