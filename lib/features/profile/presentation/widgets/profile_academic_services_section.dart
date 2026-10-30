import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 5: Academic Files & Document Services (Stitch Design)
/// Menampilkan E-Rapor Digital PDF, Surat Keterangan Aktif Belajar, dan Sinkronisasi Dapodik Kemdikbud
class ProfileAcademicServicesSection extends StatelessWidget {
  const ProfileAcademicServicesSection({super.key});

  void _downloadReport(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Mengunduh E-Rapor Semester Ganjil 2025/2026 (PDF)...'),
        backgroundColor: Color(0xFF007D55),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showCertificateNotice(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Membuka Surat Keterangan Aktif Belajar bertanda tangan digital.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDapodikNotice(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sinkronisasi status Dapodik terverifikasi aktif di Kemdikbud RI.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Berkas & Layanan Akademik',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFECEEF0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  // 1. E-Rapor
                  _buildServiceTile(
                    context: context,
                    icon: Icons.description_outlined,
                    iconColor: const Color(0xFF004AC6),
                    iconBg: const Color(0xFFEFF6FF),
                    title: 'E-Rapor Semester Ganjil 2025/2026',
                    subtitle: 'PDF • 2.4 MB • Terverifikasi',
                    trailing: const Icon(
                      Icons.download_rounded,
                      color: Color(0xFF004AC6),
                      size: 20,
                    ),
                    onTap: () => _downloadReport(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // 2. Surat Keterangan Aktif
                  _buildServiceTile(
                    context: context,
                    icon: Icons.verified_outlined,
                    iconColor: const Color(0xFF007D55),
                    iconBg: const Color(0xFFECFDF5),
                    title: 'Surat Keterangan Aktif Belajar',
                    subtitle: 'Tanda Tangan Elektronik Kepala Sekolah',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onTap: () => _showCertificateNotice(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // 3. Dapodik
                  _buildServiceTile(
                    context: context,
                    icon: Icons.badge_outlined,
                    iconColor: const Color(0xFF7C3AED),
                    iconBg: const Color(0xFFF5F3FF),
                    title: 'Data Pokok Pendidikan (Dapodik)',
                    subtitle: 'Sinkronisasi Data Kemdikbud RI',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onTap: () => _showDapodikNotice(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
