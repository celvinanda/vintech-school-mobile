import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/update/ota_update_service.dart';
import '../../../core/widgets/server_settings_sheet.dart';
import '../../academic/data/academic_repository.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../auth/presentation/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserProfileResponse profile;

  const SettingsScreen({super.key, required this.profile});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _hapticEnabled = true;
  bool _devModeEnabled = true;
  bool _isSyncing = false;

  Color get _schoolColor => AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);

  Future<void> _triggerManualSync() async {
    final storage = context.read<LocalStorage>();
    final pendingCount = storage.hive.totalPendingOutbox;
    if (pendingCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua data offline sudah tersinkronisasi sempurna dengan server.'),
          backgroundColor: Color(0xFF0F172A),
        ),
      );
      return;
    }

    setState(() => _isSyncing = true);
    try {
      final academicRepo = context.read<AcademicRepository>();
      final synced = await academicRepo.flushOfflineOutbox();
      if (!mounted) return;
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Berhasil menyinkronkan $synced data presensi ke server!'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal sinkronisasi data: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  void _confirmClearCache() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Segarkan Cache Offline?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Text(
          'Tindakan ini akan membersihkan cache modul lokal tanpa mengeluarkan sesi login Anda. Data terbaru akan otomatis dimuat ulang dari server.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final storage = context.read<LocalStorage>();
              await storage.hive.clearCacheOnly();
              if (mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Cache offline berhasil disegarkan.'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            child: const Text('Ya, Segarkan'),
          ),
        ],
      ),
    );
  }

  void _showHiveInspectorModal() {
    final storage = context.read<LocalStorage>();
    final hive = storage.hive;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
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
                    color: const Color(0xFF7C3AED).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storage_rounded, color: Color(0xFF7C3AED), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Inspektur Database Hive',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInspectorRow(
              title: 'vintech_session_box',
              subtitle: 'Token, kredensial sesi & lookup sekolah',
              count: '${hive.totalSessionEntries} entri',
              color: const Color(0xFF2563EB),
            ),
            const Divider(height: 16, color: Color(0xFFF1F5F9)),
            _buildInspectorRow(
              title: 'vintech_offline_cache_box',
              subtitle: 'Cache kartu pelajar, riwayat presensi & tagihan',
              count: '${hive.totalCachedEntries} entri',
              color: const Color(0xFF7C3AED),
            ),
            const Divider(height: 16, color: Color(0xFFF1F5F9)),
            _buildInspectorRow(
              title: 'vintech_offline_outbox_box',
              subtitle: 'Antrean transaksi presensi offline menunggu sinkron',
              count: '${hive.totalPendingOutbox} antrean',
              color: const Color(0xFFD97706),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectorRow({
    required String title,
    required String subtitle,
    required String count,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _copyBearerToken() {
    final storage = context.read<LocalStorage>();
    final token = storage.getToken() ?? widget.profile.auth?.accessToken ?? '';
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token autentikasi tidak tersedia.')),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: 'Bearer $token'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Bearer Token berhasil disalin untuk pengujian API!'),
        backgroundColor: Color(0xFF0F172A),
      ),
    );
  }

  void _showOtaUpdateModal(BuildContext context) {
    final ota = context.read<OtaUpdateService>();
    final storage = context.read<LocalStorage>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isRestartReady = ota.status == UpdateStatus.restartRequired;
          final isOutdated = ota.status == UpdateStatus.outdated;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF7C3AED), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pembaruan Kode OTA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
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
                  'Teknologi Shorebird OTA memungkinkan pembaruan fitur dan perbaikan kode instan tanpa mengunduh file APK baru dari luar.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: const Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isRestartReady
                        ? const Color(0xFFFFFBEB)
                        : (isOutdated ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isRestartReady
                          ? const Color(0xFFFDE68A)
                          : (isOutdated ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'STATUS SHOREBIRD',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isRestartReady
                                  ? const Color(0xFFD97706)
                                  : (isOutdated ? const Color(0xFF2563EB) : const Color(0xFF16A34A)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isRestartReady
                                  ? 'SIAP DITERAPKAN'
                                  : (isOutdated ? 'PATCH TERSEDIA' : 'KODE TERBARU'),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Patch Aktif: #${ota.activePatchNumber ?? "Base Release"}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (ota.isDownloading) ...[
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(),
                        const SizedBox(height: 6),
                        Text(
                          'Mengunduh patch bytecode (~300 KB)...',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
              if (isRestartReady)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    await ota.prepareForRestart(storage);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ Sesi tersimpan aman. Silakan muat ulang (restart) aplikasi.'),
                          backgroundColor: Color(0xFF0F172A),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text('Muat Ulang Sekarang'),
                )
              else if (isOutdated)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: ota.isDownloading
                      ? null
                      : () async {
                          setModalState(() {});
                          await ota.downloadPatch(storage: storage);
                          setModalState(() {});
                          setState(() {});
                        },
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Unduh Patch'),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: ota.isChecking
                      ? null
                      : () async {
                          setModalState(() {});
                          await ota.checkForUpdate();
                          setModalState(() {});
                          setState(() {});
                        },
                  child: const Text('Periksa Ulang'),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showSwitchSchoolDialog() {
    final memberships = widget.profile.memberships;
    if (memberships.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun Anda saat ini terdaftar pada 1 institusi sekolah.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Sekolah Aktif',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            ...memberships.map((m) {
              final isCurrent = m.schoolCode == widget.profile.activeSchool?.code;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isCurrent ? _schoolColor.withAlpha(18) : const Color(0xFFF8FAFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isCurrent ? _schoolColor : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _schoolColor.withAlpha(30),
                      child: Icon(Icons.school_rounded, color: _schoolColor, size: 20),
                    ),
                    title: Text(
                      m.schoolName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      '${m.schoolCode} • ${m.roleLabel}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12),
                    ),
                    trailing: isCurrent
                        ? Icon(Icons.check_circle_rounded, color: _schoolColor)
                        : null,
                    onTap: isCurrent
                        ? null
                        : () {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            context.read<AuthCubit>().switchSchool(m.schoolCode);
                          },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _confirmFactoryReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Seluruh Data Aplikasi?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: AppTheme.danger,
          ),
        ),
        content: Text(
          'Seluruh data sesi login, preferensi, dan database offline di HP ini akan dihapus secara total. Anda akan dialihkan ke halaman login awal.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final storage = context.read<LocalStorage>();
              await storage.resetAll();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Ya, Reset Aplikasi'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final storage = context.read<LocalStorage>();
    final pendingCount = storage.hive.totalPendingOutbox;
    bool clearLocalCache = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Keluar dari Akun?',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sesi aktif Anda akan diakhiri dan Anda akan kembali ke halaman Login.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: const Color(0xFF475569),
                ),
              ),
              if (pendingCount > 0) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_upload_outlined, color: Color(0xFFD97706), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Terdapat $pendingCount data presensi offline. Data ini aman di perangkat dan akan disinkronkan saat akun Anda login kembali.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              InkWell(
                onTap: () {
                  setDialogState(() {
                    clearLocalCache = !clearLocalCache;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: clearLocalCache,
                          activeColor: AppTheme.danger,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (val) {
                            setDialogState(() {
                              clearLocalCache = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hapus riwayat data offline dari HP ini (Gunakan bila memakai HP bersama)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                backgroundColor: AppTheme.danger,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await context.read<AuthCubit>().logout(clearLocalCache: clearLocalCache);
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text('Ya, Keluar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.read<LocalStorage>();
    final ota = context.read<OtaUpdateService>();
    final hive = storage.hive;
    final user = widget.profile.user;
    final school = widget.profile.activeSchool;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan & Sistem',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================================
            // 1. PREFERENSI APLIKASI
            // =================================================================
            _buildSectionHeader('Preferensi Aplikasi'),
            _buildCardContainer(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  secondary: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF3B82F6), size: 20),
                  ),
                  title: Text(
                    'Notifikasi & Peringatan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'Pengingat presensi dan status tagihan sekolah',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                  value: _notificationsEnabled,
                  activeTrackColor: _schoolColor,
                  onChanged: (val) {
                    setState(() => _notificationsEnabled = val);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  secondary: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.vibration_rounded, color: Color(0xFF8B5CF6), size: 20),
                  ),
                  title: Text(
                    'Umpan Balik Getar (Haptic)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'Sensasi getar saat merekam absensi & navigasi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                  value: _hapticEnabled,
                  activeTrackColor: _schoolColor,
                  onChanged: (val) {
                    if (val) HapticFeedback.lightImpact();
                    setState(() => _hapticEnabled = val);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.language_rounded, color: Color(0xFF059669), size: 20),
                  ),
                  title: Text(
                    'Bahasa Tampilan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'Bahasa Indonesia (Default)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ID',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // =================================================================
            // 2. DATA & PENYIMPANAN OFFLINE
            // =================================================================
            _buildSectionHeader('Data & Penyimpanan Offline'),
            _buildCardContainer(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storage_rounded, color: Color(0xFF7C3AED), size: 20),
                  ),
                  title: Text(
                    'Penyimpanan Offline Hive',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    '${hive.totalCachedEntries} Modul Tersimpan • Akses 0 ms Tanpa Sinyal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'AKTIF',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.outbox_rounded, color: Color(0xFFD97706), size: 20),
                  ),
                  title: Text(
                    'Antrean Sinkronisasi (Outbox)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    hive.totalPendingOutbox > 0
                        ? '${hive.totalPendingOutbox} Data Menunggu Terhubung'
                        : 'Semua Data Tersinkronisasi Sempurna',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  trailing: _isSyncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : (hive.totalPendingOutbox > 0
                          ? ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD97706),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _triggerManualSync,
                              icon: const Icon(Icons.sync_rounded, size: 14),
                              label: Text(
                                'Sync',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20)),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.refresh_rounded, color: Color(0xFF475569), size: 20),
                  ),
                  title: Text(
                    'Segarkan Cache Offline',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'Muat ulang data modul terbaru dari server',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
                  onTap: _confirmClearCache,
                ),
              ],
            ),

            const SizedBox(height: 22),

            // =================================================================
            // 3. AKUN & KEAMANAN
            // =================================================================
            _buildSectionHeader('Akun & Keamanan'),
            _buildCardContainer(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _schoolColor.withAlpha(22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.school_rounded, color: _schoolColor, size: 20),
                  ),
                  title: Text(
                    'Institusi Sekolah',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    '${school?.name ?? '-'} (${school?.code ?? '-'})',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  trailing: widget.profile.memberships.length > 1
                      ? TextButton(
                          onPressed: _showSwitchSchoolDialog,
                          child: Text(
                            'Ganti',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: _schoolColor,
                            ),
                          ),
                        )
                      : null,
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16A34A).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 20),
                  ),
                  title: Text(
                    'Partisi Sesi Multi-Tenant',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'ID: ${user.cleanIdentifier} • Terisolasi Bebas Bocor Antar Akun',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  trailing: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // =================================================================
            // 4. OPSI PENGEMBANG & DIAGNOSTIK (DEVELOPER OPTIONS)
            // =================================================================
            _buildSectionHeader(
              'Opsi Pengembang & Diagnostik',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEA580C).withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'DEV TOOLS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFEA580C),
                  ),
                ),
              ),
            ),
            _buildCardContainer(
              children: [
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  secondary: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.developer_mode_rounded, color: Color(0xFFEA580C), size: 20),
                  ),
                  title: Text(
                    'Developer Mode',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'Menampilkan diagnostik endpoint & database',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                  value: _devModeEnabled,
                  activeTrackColor: const Color(0xFFEA580C),
                  onChanged: (val) {
                    setState(() => _devModeEnabled = val);
                  },
                ),
                if (_devModeEnabled) ...[
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.dns_rounded, color: Color(0xFF2563EB), size: 20),
                    ),
                    title: Text(
                      'Endpoint Server API',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      storage.getBaseUrl(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Ubah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ),
                    onTap: () => ServerSettingsSheet.show(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0891B2).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.analytics_outlined, color: Color(0xFF0891B2), size: 20),
                    ),
                    title: Text(
                      'Inspeksi Database Hive',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      'Session: ${hive.totalSessionEntries} • Cache: ${hive.totalCachedEntries} • Outbox: ${hive.totalPendingOutbox}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
                    onTap: _showHiveInspectorModal,
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4F46E5).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.key_rounded, color: Color(0xFF4F46E5), size: 20),
                    ),
                    title: Text(
                      'Salin Bearer Auth Token',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      'Gunakan untuk pengujian cURL / Postman',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF4F46E5)),
                      tooltip: 'Salin Token',
                      onPressed: _copyBearerToken,
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Color(0xFF7C3AED), size: 20),
                    ),
                    title: Text(
                      'Diagnostik Engine Shorebird OTA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      'Engine: ${ota.isShorebirdAvailable ? "Production Release" : "Standby (Debug/AVD)"} • Patch: #${ota.activePatchNumber ?? "Base"}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
                    onTap: () => _showOtaUpdateModal(context),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    secondary: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.science_rounded, color: Color(0xFF0D9488), size: 20),
                    ),
                    title: Text(
                      'Simulasi OTA Patch (Dev Test)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      'Simulasikan patch baru di emulator untuk menguji alur',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                    ),
                    value: ota.isDevSimulated,
                    activeTrackColor: const Color(0xFF0D9488),
                    onChanged: (val) {
                      ota.toggleDevSimulation(val);
                      setState(() {});
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFDC2626), size: 20),
                    ),
                    title: Text(
                      'Reset Database Lokal (Factory Reset)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                    subtitle: Text(
                      'Bersihkan seluruh sesi & data offline di HP',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFDC2626), size: 20),
                    onTap: _confirmFactoryReset,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 22),

            // =================================================================
            // 5. TENTANG APLIKASI
            // =================================================================
            _buildSectionHeader('Tentang Aplikasi'),
            _buildCardContainer(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64748B).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Color(0xFF475569), size: 20),
                  ),
                  title: Text(
                    'Vintech School Mobile',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'Versi 1.1.0 • Clean Modern Architecture',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Vintech School',
                      applicationVersion: '1.1.0 (Clean Modern UI)',
                      applicationLegalese: '© 2026 Vintech Cloud Platform. Seluruh Hak Cipta Dilindungi.',
                      applicationIcon: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _schoolColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF7C3AED), size: 20),
                  ),
                  title: Text(
                    'Pembaruan Kode OTA (Shorebird)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    ota.status == UpdateStatus.restartRequired
                        ? 'Patch #${ota.activePatchNumber} siap! Ketuk untuk menerapkan'
                        : (ota.status == UpdateStatus.outdated
                            ? 'Patch kode baru tersedia • Ketuk untuk mengunduh'
                            : (ota.status == UpdateStatus.unavailable
                                ? 'Engine Siap (Production Release Standby)'
                                : 'Kode Mutakhir • Patch #${ota.activePatchNumber ?? "Base"}')),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: ota.status == UpdateStatus.restartRequired
                          ? const Color(0xFFD97706)
                          : (ota.status == UpdateStatus.outdated
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF64748B)),
                      fontWeight: ota.status == UpdateStatus.restartRequired ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                  trailing: ota.isChecking || ota.isDownloading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : (ota.status == UpdateStatus.restartRequired
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Text(
                                'Terapkan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            )
                          : const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20)),
                  onTap: () => _showOtaUpdateModal(context),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // =================================================================
            // 6. LOGOUT BUTTON
            // =================================================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                  backgroundColor: const Color(0xFFFEF2F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  'Keluar Akun',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
