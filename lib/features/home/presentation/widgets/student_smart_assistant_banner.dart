import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/storage/local_storage.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../billing/logic/billing_cubit.dart';
import '../../../billing/logic/billing_state.dart';

/// Bento 0: Asisten Cerdas Kontekstual Siswa (Google Stitch Design)
/// Menganalisis kondisi real-time berdasarkan:
/// 1. Waktu KBM & Jam Sekolah (Pagi, Sesi Aktif, Sore, Malam)
/// 2. Status Outbox Presensi Offline (Hive Cache Engine)
/// 3. Status Tagihan SPP Belum Lunas
/// 4. Shortcut Aksi Cerdas yang Relevan
class StudentSmartAssistantBanner extends StatelessWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final VoidCallback? onAttendanceTap;
  final VoidCallback? onBillingTap;
  final VoidCallback? onAcademicTap;

  const StudentSmartAssistantBanner({
    super.key,
    required this.profile,
    required this.schoolColor,
    this.onAttendanceTap,
    this.onBillingTap,
    this.onAcademicTap,
  });

  _AssistantContext _resolveContext(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final timeInMinutes = hour * 60 + minute;

    // Cek status outbox presensi offline
    final pendingOutbox = context.watch<LocalStorage>().hive.totalPendingOutbox;

    // Cek status SPP
    final billingState = context.watch<BillingCubit>().state;
    final unpaidInvoices = billingState is BillingLoaded
        ? billingState.invoices.where((inv) => !inv.isPaid).length
        : 0;

    // 1. Prioritas Utama: Peringatan Data Offline Belum Terkirim
    if (pendingOutbox > 0) {
      return _AssistantContext(
        badgeText: 'Sinkronisasi Hive Siap',
        badgeColor: const Color(0xFFD97706),
        badgeBg: const Color(0xFFFEF3C7),
        icon: Icons.sync_problem_rounded,
        title: '$pendingOutbox Presensi Tersimpan Offline',
        message: 'Data kehadiran Anda aman di memori lokal. Sistem otomatis menyinkronkan begitu internet terhubung.',
        actionLabel: 'Cek Status',
        onAction: onAttendanceTap,
      );
    }

    // 2. Prioritas Jam Pagi: 06:00 - 07:45 (Waktu Presensi Masuk)
    if (timeInMinutes >= 360 && timeInMinutes <= 465) {
      return _AssistantContext(
        badgeText: 'Gerbang Sekolah Terbuka',
        badgeColor: const Color(0xFF007D55),
        badgeBg: const Color(0xFFE8F5E9),
        icon: Icons.how_to_reg_rounded,
        title: 'Selamat Pagi, ${profile.user.firstName}!',
        message: 'Pastikan Anda telah melakukan presensi masuk hari ini sebelum pukul 07:30 WIB.',
        actionLabel: 'Buka Presensi',
        onAction: onAttendanceTap,
      );
    }

    // 3. Sesi KBM Berlangsung: 07:45 - 14:30
    if (timeInMinutes > 465 && timeInMinutes <= 870) {
      return _AssistantContext(
        badgeText: 'Sesi Belajar Aktif',
        badgeColor: const Color(0xFF004AC6),
        badgeBg: const Color(0xFFEFF6FF),
        icon: Icons.menu_book_rounded,
        title: 'Kegiatan Belajar Mengajar',
        message:
            'Fokus dan tertib di kelas ${profile.activeSchool?.classroomName ?? "X-IPA-1"}. Cek jadwal & materi pelajaran berkala.',
        actionLabel: 'Jadwal Hari Ini',
        onAction: onAcademicTap,
      );
    }

    // 4. Prioritas Pengingat SPP jika ada yang jatuh tempo
    if (unpaidInvoices > 0) {
      return _AssistantContext(
        badgeText: 'Informasi Administrasi',
        badgeColor: const Color(0xFF2563EB),
        badgeBg: const Color(0xFFEFF6FF),
        icon: Icons.receipt_long_rounded,
        title: 'Tagihan SPP Belum Lunas',
        message:
            'Terdapat $unpaidInvoices tagihan SPP aktif. Pembayaran dapat dilakukan via Virtual Account & QRIS.',
        actionLabel: 'Lihat Tagihan',
        onAction: onBillingTap,
      );
    }

    // 5. Sore / Malam Hari: 14:30 - 23:59 (Review Tugas & Rapor)
    return _AssistantContext(
      badgeText: 'Kilas Akademik',
      badgeColor: const Color(0xFF7C3AED),
      badgeBg: const Color(0xFFF5F3FF),
      icon: Icons.auto_awesome_rounded,
      title: 'KBM Selesai Hari Ini',
      message: 'Periksa kesiapan tugas esok hari, pantau capaian nilai rata-rata, dan istirahat yang cukup.',
      actionLabel: 'Rapor Digital',
      onAction: onAcademicTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctx = _resolveContext(context);

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Badge Status & Icon Asisten
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4.5,
                  ),
                  decoration: BoxDecoration(
                    color: ctx.badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(ctx.icon, size: 14, color: ctx.badgeColor),
                      const SizedBox(width: 6),
                      Text(
                        ctx.badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: ctx.badgeColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.smart_toy_outlined,
                  size: 17,
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Judul Asisten
            Text(
              ctx.title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 4),

            // Deskripsi Kontekstual
            Text(
              ctx.message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),

            if (ctx.actionLabel != null && ctx.onAction != null) ...[
              const SizedBox(height: 14),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ctx.onAction!();
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: schoolColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ctx.actionLabel!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: schoolColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: schoolColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssistantContext {
  final String badgeText;
  final Color badgeColor;
  final Color badgeBg;
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  _AssistantContext({
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBg,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
}
