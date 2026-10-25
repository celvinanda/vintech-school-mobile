import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
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
          'Tindakan ini akan membersihkan cache data modul lokal tanpa mengeluarkan Anda dari akun. Data terbaru akan otomatis dimuat ulang dari server.',
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
                            Navigator.pop(context); // back to main
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
          'Seluruh data sesi login, preferensi, dan database offline di perangkat ini akan dihapus secara total. Anda akan dialihkan ke halaman login awal.',
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = context.read<LocalStorage>();
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
            // 1. KONEKSI & CLOUD SERVER
            // =================================================================
            _buildSectionHeader('Koneksi & Cloud Server'),
            _buildCardContainer(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF2563EB), size: 20),
                  ),
                  title: Text(
                    'Server Vintech Cloud API',
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ubah',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                  onTap: () async {
                    ServerSettingsSheet.show(context);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.wifi_tethering_rounded, color: Color(0xFF0F766E), size: 20),
                  ),
                  title: Text(
                    'Status Jaringan Cloud',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    'school.vintech.cloud • Terhubung',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'ONLINE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // =================================================================
            // 2. PENYIMPANAN OFFLINE & SINKRONISASI
            // =================================================================
            _buildSectionHeader('Penyimpanan Offline Hive'),
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
                    'Database Lokal Hive (Offline-First)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    '${hive.totalCachedEntries} Modul Tersimpan • Akses Tanpa Sinyal Aktif',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  trailing: const Icon(Icons.bolt_rounded, color: Color(0xFF7C3AED), size: 20),
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
                        : 'Semua Data Tersinkronisasi',
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
                    'Bersihkan cache modul agar memuat data paling mutakhir',
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
            // 3. KEAMANAN & AKUN
            // =================================================================
            _buildSectionHeader('Keamanan & Multi-Tenant'),
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
                    'Partisi Sesi Terenkripsi',
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
            // 4. PREFERENSI APLIKASI
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
                    'Pengingat presensi dan update tagihan sekolah',
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
                    'Sensasi sentuh saat merekam absensi & navigasi',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                  value: _hapticEnabled,
                  activeTrackColor: _schoolColor,
                  onChanged: (val) {
                    if (val) HapticFeedback.lightImpact();
                    setState(() => _hapticEnabled = val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            // =================================================================
            // 5. TENTANG & SISTEM
            // =================================================================
            _buildSectionHeader('Tentang & Diagnostik'),
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
                    'Tentang Vintech School Mobile',
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
                      color: const Color(0xFFDC2626).withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626), size: 20),
                  ),
                  title: Text(
                    'Reset Data Aplikasi Lokal',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                  subtitle: Text(
                    'Hapus seluruh sesi dan database offline di HP ini',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF64748B)),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFDC2626), size: 20),
                  onTap: _confirmFactoryReset,
                ),
              ],
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
