import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/presentation/main_navigation_screen.dart';
import '../data/models/school_lookup_model.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';
import 'school_lookup_screen.dart';

class LoginScreen extends StatefulWidget {
  final SchoolLookupModel? school;

  const LoginScreen({super.key, this.school});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  Color get _activeThemeColor => widget.school != null
      ? AppTheme.parseHexColor(widget.school!.primaryColor)
      : AppTheme.defaultPrimary;

  @override
  void initState() {
    super.initState();
    // Default demo account
    _usernameController.text = 'siswa.sman1jkt.20261001';
    _passwordController.text = 'siswa123';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
            schoolCode: widget.school?.code,
          );
    }
  }

  void _showServerSettingsModal() {
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
              'Pengaturan Server Backend',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aplikasi secara bawaan terhubung ke Server Resmi Vintech Cloud (https://school.vintech.cloud).',
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
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Base URL disimpan: ${serverController.text.trim()}'),
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

  void _fillAccount(String username, String password) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSpecificSchool = widget.school != null;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => MainNavigationScreen(profile: state.profile),
            ),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: isSpecificSchool
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () {
                    // Back to universal login
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                )
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Direktori Profil Sekolah',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SchoolLookupScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Pengaturan Server API',
              onPressed: _showServerSettingsModal,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Branding (Universal vs Dedicated School)
                  if (isSpecificSchool)
                    _buildDedicatedSchoolHeader()
                  else
                    _buildUniversalHeader(),

                  const SizedBox(height: 28),

                  // Smart Discovery Highlight Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sistem cerdas Vintech otomatis mendeteksi sekolah dan peran Anda (Siswa, Wali Murid, atau Guru).',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              color: const Color(0xFF475569),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Username / NISN / NIP / Email
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'ID Pengguna / Username / NISN / NIP',
                      hintText: 'Contoh: siswa.sman1jkt.20261001',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'ID Pengguna wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Input Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Kata sandi wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Login Button
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _activeThemeColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isLoading ? null : _onLogin,
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Masuk ke Akun',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Quick 1-Click Demo Accounts
                  _buildQuickDemoAccountsSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUniversalHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vintech School',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Sistem Informasi & Presensi Terpadu',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Masuk ke Akun Anda',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Satu pintu akses terpadu untuk Siswa, Guru, dan Wali Murid.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildDedicatedSchoolHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _activeThemeColor.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _activeThemeColor.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _activeThemeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.domain_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.school!.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textMain,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.school!.code} • ${widget.school!.levelDisplay}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _activeThemeColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Ganti'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDemoAccountsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flash_on_rounded,
                color: Color(0xFFD97706),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'AKUN DEMO CEPAT (1-KLIK UJI COBA):',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Siswa Category
          _buildRoleSectionLabel('🎓 Akun Siswa (Pelajar):'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildDemoChip(
                label: 'Siswa SMAN 1 Jakarta',
                username: 'siswa.sman1jkt.20261001',
                password: 'siswa123',
                color: const Color(0xFF10a83d),
              ),
              _buildDemoChip(
                label: 'Siswa SMK Vintech Bandung',
                username: 'siswa.smkvintech.20262001',
                password: 'siswa123',
                color: const Color(0xFF0ea5e9),
              ),
              _buildDemoChip(
                label: 'Siswa SMP Al-Hikmah',
                username: 'siswa.smpalhikmah.20263001',
                password: 'siswa123',
                color: const Color(0xFF10b981),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Guru Category
          _buildRoleSectionLabel('👨‍🏫 Akun Guru (Tenaga Pendidik):'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildDemoChip(
                label: 'Guru SMAN 1 (Fisika)',
                username: 'guru.sman1jkt.198609182011012004',
                password: 'guru123',
                color: const Color(0xFF10a83d),
              ),
              _buildDemoChip(
                label: 'Guru SMK Vintech (RPL)',
                username: 'guru.smkvintech.199205112018011005',
                password: 'guru123',
                color: const Color(0xFF0ea5e9),
              ),
              _buildDemoChip(
                label: 'Guru SMP Al-Hikmah (Tahfidz)',
                username: 'guru.smpalhikmah.198501012012011009',
                password: 'guru123',
                color: const Color(0xFF10b981),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Admin Category
          _buildRoleSectionLabel('🏢 Akun Admin Sekolah:'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildDemoChip(
                label: 'Admin SMAN 1',
                username: 'admin.sman1',
                password: 'admin123',
                color: const Color(0xFF475569),
              ),
              _buildDemoChip(
                label: 'Admin SMK Vintech',
                username: 'admin.smkvintech',
                password: 'admin123',
                color: const Color(0xFF475569),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF64748B),
      ),
    );
  }

  Widget _buildDemoChip({
    required String label,
    required String username,
    required String password,
    required Color color,
  }) {
    final isSelected = _usernameController.text == username;

    return InkWell(
      onTap: () => _fillAccount(username, password),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(25) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFCBD5E1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
