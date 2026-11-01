import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 5: Academic Files & Document Services (Stitch Design)
/// Menampilkan E-Rapor Digital PDF, Surat Keterangan Aktif Belajar, dan Sinkronisasi Dapodik Kemdikbud
void _showLeavePermissionDialog(BuildContext context) {
  HapticFeedback.selectionClick();
  final reasonController = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_calendar_rounded,
              color: Color(0xFF7C3AED),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Permohonan Izin Siswa',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ajukan surat izin atau keterangan sakit untuk anak Anda langsung ke sistem sekolah:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            maxLines: 3,
            style: GoogleFonts.plusJakartaSans(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Tuliskan alasan izin (Sakit / Keperluan Keluarga)...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '✓ Permohonan izin sakit/dispensasi berhasil dikirim ke Wali Kelas!',
                ),
                backgroundColor: Color(0xFF007D55),
              ),
            );
          },
          child: const Text('Kirim Izin'),
        ),
      ],
    ),
  );
}

class ProfileAcademicServicesSection extends StatelessWidget {
  final bool isParent;
  const ProfileAcademicServicesSection({super.key, this.isParent = false});
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
        content: Text(
          'Membuka Surat Keterangan Aktif Belajar bertanda tangan digital.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDapodikNotice(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Sinkronisasi status Dapodik terverifikasi aktif di Kemdikbud RI.',
        ),
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
            isParent
                ? 'Dokumen & Layanan Orang Tua'
                : 'Berkas & Layanan Akademik',
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
                  if (isParent) ...[
                    // 1. E-Rapor Digital Anak (Khusus Orang Tua)
                    _buildServiceTile(
                      context: context,
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF004AC6),
                      iconBg: const Color(0xFFEFF6FF),
                      title: 'E-Rapor Digital Anak Semester Ganjil',
                      subtitle: 'PDF • 2.4 MB • Terverifikasi Kepala Sekolah',
                      trailing: const Icon(
                        Icons.download_rounded,
                        color: Color(0xFF004AC6),
                        size: 20,
                      ),
                      onTap: () => _downloadReport(context),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    // 2. Izin Sakit Online Anak
                    _buildServiceTile(
                      context: context,
                      icon: Icons.edit_calendar_rounded,
                      iconColor: const Color(0xFF7C3AED),
                      iconBg: const Color(0xFFF5F3FF),
                      title: 'Pengajuan Dispensasi / Izin Sakit Siswa',
                      subtitle: 'Form Permohonan Izin Siswa Online',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onTap: () => _showLeavePermissionDialog(context),
                    ),
                  ] else ...[
                    // Layanan Dokumen Administrasi Siswa (E-Rapor terpusat di Tab Akademik)
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
