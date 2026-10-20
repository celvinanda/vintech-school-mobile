import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../auth/presentation/school_lookup_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfileResponse profile;

  const ProfileScreen({super.key, required this.profile});

  Color get _schoolColor => AppTheme.parseHexColor(profile.activeSchool?.primaryColor);

  void _showSwitchSchoolDialog(BuildContext context) {
    final memberships = profile.memberships;
    if (memberships.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Akun Anda saat ini hanya terdaftar pada 1 sekolah.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Beralih Sekolah'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: memberships.map((m) {
            final isCurrent = m.schoolCode == profile.activeSchool?.code;
            return ListTile(
              title: Text(m.schoolName),
              subtitle: Text('${m.schoolCode} • ${m.roleLabel}'),
              trailing: isCurrent ? const Icon(Icons.check_circle, color: AppTheme.success) : null,
              onTap: isCurrent
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      context.read<AuthCubit>().switchSchool(m.schoolCode);
                    },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showServerSettingsModal(BuildContext context) {
    final storage = context.read<LocalStorage>();
    final serverController = TextEditingController(text: storage.getBaseUrl());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konfigurasi Server Vintech API',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aplikasi terhubung ke Server Resmi Vintech Cloud (https://school.vintech.cloud).',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: serverController,
              decoration: const InputDecoration(
                labelText: 'Backend Base URL',
                hintText: 'https://school.vintech.cloud',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cloud_done_rounded, size: 16),
                    onPressed: () {
                      serverController.text = 'https://school.vintech.cloud';
                    },
                    label: const Text('Resmi (Cloud)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () {
                      serverController.text = 'http://10.0.2.2:8001';
                    },
                    child: const Text('Lokal AVD'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await storage.saveBaseUrl(serverController.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Server URL diperbarui: ${serverController.text.trim()}'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  }
                },
                child: const Text('Simpan URL'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = profile.user;
    final school = profile.activeSchool;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // User Avatar & Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _schoolColor.withAlpha(20),
                      shape: BoxShape.circle,
                      border: Border.all(color: _schoolColor, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _schoolColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.username} • ${school?.role ?? 'User'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Active School Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sekolah Terhubung',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      if (profile.memberships.length > 1)
                        InkWell(
                          onTap: () => _showSwitchSchoolDialog(context),
                          child: Text(
                            'Ganti Sekolah',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _schoolColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _schoolColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.school, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              school?.name ?? 'Sekolah',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textMain,
                              ),
                            ),
                            Text(
                              'Kode: ${school?.code ?? '-'} • ${school?.city ?? ''}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings & Tools List
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_ethernet_rounded, color: Color(0xFF2563EB)),
                    title: const Text('Pengaturan Server API'),
                    subtitle: Text(context.read<LocalStorage>().getBaseUrl(),
                        style: const TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showServerSettingsModal(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined, color: Color(0xFFD97706)),
                    title: const Text('Notifikasi & Pengumuman'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF0F766E)),
                    title: const Text('Tentang Vintech School v1.0.0'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Vintech School',
                        applicationVersion: '1.0.0 (Clean Architecture)',
                        applicationLegalese: '© 2026 Vintech Cloud Platform',
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.danger,
                  side: const BorderSide(color: AppTheme.danger),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Keluar dari Akun?'),
                      content: const Text('Sesi aktif pada perangkat ini akan diakhiri.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await context.read<AuthCubit>().logout();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const SchoolLookupScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          child: const Text('Keluar'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar Akun'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
