import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/logic/auth_cubit.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfileResponse profile;

  const ProfileScreen({super.key, required this.profile});

  Color get _schoolColor => AppTheme.parseHexColor(profile.activeSchool?.primaryColor);

  void _showSwitchSchoolDialog(BuildContext context) {
    final memberships = profile.memberships;
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
              final isCurrent = m.schoolCode == profile.activeSchool?.code;
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

  void _showDigitalCardModal(BuildContext context) {
    final user = profile.user;
    final school = profile.activeSchool;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _schoolColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.badge_rounded, color: _schoolColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        school?.cardBadgeTitle ?? 'KARTU IDENTITAS DIGITAL',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          letterSpacing: 0.5,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _schoolColor,
                      Color.lerp(_schoolColor, const Color(0xFF0F172A), 0.55) ?? const Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _schoolColor.withAlpha(90),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (school?.name ?? 'VINTECH SCHOOL').toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'KODE: ${school?.code ?? '-'} • ${school?.level ?? 'Sekolah'}',
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white.withAlpha(200),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF22C55E), width: 0.8),
                          ),
                          child: Text(
                            'AKTIF',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF4ADE80),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              user.initials,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${school?.roleDisplayLabel ?? 'Pengguna'} • ID: ${user.cleanIdentifier}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white.withAlpha(210),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, color: Colors.white.withAlpha(40)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IDENTIFIER RESMI',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withAlpha(160),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '@${user.username}',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: List.generate(
                            18,
                            (index) => Container(
                              margin: const EdgeInsets.only(left: 2.5),
                              width: (index % 3 == 0) ? 3.5 : ((index % 2 == 0) ? 2 : 1),
                              height: 24,
                              color: Colors.white.withAlpha((index % 4 == 0) ? 120 : 220),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Kartu identitas ini sah dan terverifikasi secara multi-tenant pada sistem Vintech School Cloud.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
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
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF475569)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ?trailing,
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Profil & Akun',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              tooltip: 'Pengaturan & Sistem',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                padding: const EdgeInsets.all(8),
              ),
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF1E293B),
                size: 20,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(profile: profile),
                  ),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // =================================================================
            // 1. MINIMALIST EXECUTIVE PROFILE HEADER
            // =================================================================
            Center(
              child: Column(
                children: [
                  // Avatar with Online Badge
                  Stack(
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: _schoolColor.withAlpha(20),
                          shape: BoxShape.circle,
                          border: Border.all(color: _schoolColor.withAlpha(90), width: 2.5),
                        ),
                        child: Center(
                          child: Text(
                            user.initials,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _schoolColor,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Full Name
                  Text(
                    user.fullName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Role & School Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _schoolColor.withAlpha(18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _schoolColor.withAlpha(60), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _schoolColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${school?.roleDisplayLabel ?? 'Pengguna Aktif'} • ${school?.name ?? 'Vintech School'}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: _schoolColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Digital ID Card Action Pill
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _schoolColor,
                      side: BorderSide(color: _schoolColor.withAlpha(90), width: 1.2),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () => _showDigitalCardModal(context),
                    icon: const Icon(Icons.badge_outlined, size: 16),
                    label: Text(
                      school?.cardBadgeTitle ?? 'Kartu Identitas Digital',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================================
            // 2. UNIFIED CLEAN INFORMATION CARD
            // =================================================================
            Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  // Institusi Sekolah
                  _buildTile(
                    icon: Icons.school_rounded,
                    title: 'Institusi Sekolah',
                    subtitle: '${school?.name ?? '-'} (${school?.code ?? '-'})',
                    trailing: profile.memberships.length > 1
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _schoolColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'Ganti',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _schoolColor,
                              ),
                            ),
                          )
                        : null,
                    onTap: profile.memberships.length > 1 ? () => _showSwitchSchoolDialog(context) : null,
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // Nomor Identitas (NIS/NIP)
                  _buildTile(
                    icon: Icons.badge_outlined,
                    title: school?.isStudent == true ? 'Nomor Induk Siswa (NIS)' : 'Nomor Induk Pegawai (NIP)',
                    subtitle: user.cleanIdentifier,
                    trailing: IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF94A3B8)),
                      tooltip: 'Salin ID',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: user.cleanIdentifier));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ID berhasil disalin ke clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // Username Sistem
                  _buildTile(
                    icon: Icons.alternate_email_rounded,
                    title: 'Username Sistem',
                    subtitle: '@${user.username}',
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // Email Terdaftar
                  _buildTile(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email Terdaftar',
                    subtitle: user.email.isNotEmpty ? user.email : 'Tidak terdaftar',
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  // Status Autentikasi
                  _buildTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Status Autentikasi',
                    subtitle: 'Terverifikasi Aktif • Multi-Tenant',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'AKTIF',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================================
            // 3. SUBTLE FOOTER NOTE
            // =================================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    'Data tersimpan aman pada sistem cloud sekolah',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
