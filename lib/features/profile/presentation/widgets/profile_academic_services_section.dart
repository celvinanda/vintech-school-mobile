import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../auth/data/models/user_model.dart';

/// Card 5: Academic Files & Document Services (Stitch Design)
/// Menampilkan Dokumen Akademik sesuai Peran (Siswa, Orang Tua, dan Guru/Staff)
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

void _showTeacherDutyDialog(
  BuildContext context,
  UserProfileResponse? profile,
) {
  HapticFeedback.selectionClick();
  final reasonController = TextEditingController();
  final destController = TextEditingController();
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.work_history_rounded,
              color: Color(0xFF004AC6),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pengajuan Tugas Luar Pendidik',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajukan surat tugas dinas luar, diklat MGMP, atau dispensasi mengajar langsung ke Kepala Sekolah:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Instansi / Agenda Kegiatan *',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: destController,
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Contoh: Workshop Balai Guru Penggerak / MGMP',
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Rincian & Pengganti KBM *',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: reasonController,
              maxLines: 2,
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tuliskan modul mandiri / guru piket pengganti...',
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF004AC6),
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
                  '✓ Pengajuan tugas dinas luar berhasil dikirim ke Kepala Sekolah!',
                ),
                backgroundColor: Color(0xFF007D55),
              ),
            );
          },
          child: const Text('Kirim Pengajuan'),
        ),
      ],
    ),
  );
}

void _showGtkStatusModal(BuildContext context, UserProfileResponse? profile) {
  HapticFeedback.selectionClick();
  final nip = profile?.activeSchool?.nip?.isNotEmpty == true
      ? profile!.activeSchool!.nip!
      : '-';
  final mapel = profile?.activeSchool?.specialization?.isNotEmpty == true
      ? profile!.activeSchool!.specialization!
      : '-';
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF007D55),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Info GTK & Dapodik',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Sinkron Kemdikbudristek RI • Semester Ganjil 2025/2026',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildStatusRow(
                  'Status Data Pendidik',
                  'VALID & SINKRON',
                  const Color(0xFF007D55),
                  isBadge: true,
                ),
                const Divider(height: 16, color: Color(0xFFE2E8F0)),
                _buildStatusRow('NIP / NUPTK', nip, const Color(0xFF0F172A)),
                const Divider(height: 16, color: Color(0xFFE2E8F0)),
                _buildStatusRow(
                  'Mata Pelajaran KBM',
                  mapel,
                  const Color(0xFF0F172A),
                ),
                const Divider(height: 16, color: Color(0xFFE2E8F0)),
                _buildStatusRow(
                  'Beban Mengajar Linier',
                  '24 Jam Pelajaran (JP)',
                  const Color(0xFF004AC6),
                ),
                const Divider(height: 16, color: Color(0xFFE2E8F0)),
                _buildStatusRow(
                  'Kelayakan Tunjangan (TPG)',
                  'Layak / Terbit SKTP',
                  const Color(0xFF007D55),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007D55),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Tutup Verifikasi',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatusRow(
  String label,
  String value,
  Color valueColor, {
  bool isBadge = false,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
      if (isBadge)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        )
      else
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
    ],
  );
}

class ProfileAcademicServicesSection extends StatelessWidget {
  final bool isParent;
  final bool isStaffOrTeacher;
  final UserProfileResponse? profile;

  const ProfileAcademicServicesSection({
    super.key,
    this.isParent = false,
    this.isStaffOrTeacher = false,
    this.profile,
  });

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

  void _downloadTeacherSK(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '✓ Mengunduh SK Pembagian Tugas KBM Semester Ganjil 2025/2026 (PDF)...',
        ),
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
    final sectionTitle = isStaffOrTeacher
        ? 'Dokumen & Layanan Tenaga Pendidik'
        : (isParent
              ? 'Dokumen & Layanan Orang Tua'
              : 'Berkas & Layanan Akademik');

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
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
                  if (isStaffOrTeacher) ...[
                    // 1. SK Pembagian Tugas Mengajar & KBM
                    _buildServiceTile(
                      context: context,
                      icon: Icons.assignment_outlined,
                      iconColor: const Color(0xFF004AC6),
                      iconBg: const Color(0xFFEFF6FF),
                      title: 'SK Pembagian Tugas KBM Semester Ini',
                      subtitle: 'PDF • 1.8 MB • Ditandatangani Kepala Sekolah',
                      trailing: const Icon(
                        Icons.download_rounded,
                        color: Color(0xFF004AC6),
                        size: 20,
                      ),
                      onTap: () => _downloadTeacherSK(context),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    // 2. Pengajuan Tugas Dinas Luar / Izin Pendidik
                    _buildServiceTile(
                      context: context,
                      icon: Icons.work_history_outlined,
                      iconColor: const Color(0xFF7C3AED),
                      iconBg: const Color(0xFFF5F3FF),
                      title: 'Pengajuan Tugas Luar & Dispensasi Guru',
                      subtitle: 'Form Izin Dinas Luar / Seminar / Diklat',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onTap: () => _showTeacherDutyDialog(context, profile),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    // 3. Status Info GTK & Dapodik
                    _buildServiceTile(
                      context: context,
                      icon: Icons.verified_user_outlined,
                      iconColor: const Color(0xFF007D55),
                      iconBg: const Color(0xFFECFDF5),
                      title: 'Status Info GTK & Dapodik Pendidik',
                      subtitle: 'Beban 24 JP Linier • Valid Sertifikasi (TPG)',
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onTap: () => _showGtkStatusModal(context, profile),
                    ),
                  ] else if (isParent) ...[
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
