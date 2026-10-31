import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/server_settings_sheet.dart';
import '../../home/presentation/main_navigation_screen.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Default demo student
    _usernameController.text = 'siswa.sman1jkt.20261001';
    _passwordController.text = 'siswa123';

    // Pastikan keyboard tidak auto-fokus saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            _usernameController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  void _fillAccount(String username, String password) {
    FocusScope.of(context).unfocus();
    setState(() {
      _usernameController.text = username;
      _passwordController.text = password;
    });
  }

  void _simulateBiometric() {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF191C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.fingerprint_rounded, color: Color(0xFF4EDEA3), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Memverifikasi Face ID / Sidik Jari...',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        _onLogin();
      }
    });
  }

  void _showForgotPasswordDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBE1FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      color: Color(0xFF004AC6),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bantuan Lupa Kata Sandi',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF191C1E),
                          ),
                        ),
                        Text(
                          'Pemulihan kredensial akses akun',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF565E74),
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
                  color: const Color(0xFFF7F9FB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE6E8EA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.mark_chat_unread_outlined,
                      size: 18,
                      color: Color(0xFF004AC6),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Untuk keamanan data siswa, reset kata sandi dikirimkan otomatis melalui WhatsApp ke nomor wali murid terdaftar.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: const Color(0xFF434655),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004AC6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFF191C1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: Text(
                          'Tautan reset sandi telah dikirim ke WhatsApp wali murid.',
                          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'Kirim Tautan ke WhatsApp Wali',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTuContactSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFDBE1FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Color(0xFF004AC6),
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Layanan Tata Usaha (TU)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF191C1E),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hubungi staf tata usaha sekolah untuk bantuan NISN, aktivasi akun, dan verifikasi administrasi.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: const Color(0xFF565E74),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE6E8EA)),
                ),
                leading: const Icon(Icons.chat_rounded, color: Color(0xFF16A34A)),
                title: Text(
                  'WhatsApp Helpdesk TU',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '+62 821-8888-0199 (Senin - Jumat 07:00 - 16:00)',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF737686)),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Membuka kontak WhatsApp Helpdesk Tata Usaha...'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Text(
                state.message,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500),
              ),
            ),
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFFF7F9FB),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F9FB), // Google Stitch: bg-surface
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Subtle Ambient Glows (Stitch Design Specification)
                Positioned(
                  top: -80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFDBE1FF).withValues(alpha: 0.40),
                            const Color(0xFFDBE1FF).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  right: -40,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFDAE2FD).withValues(alpha: 0.35),
                          const Color(0xFFDAE2FD).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. Scrollable Login Content (Presisi Full Viewport Centering)
                Positioned.fill(
                  child: SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                              const SizedBox(height: 10),

                              // Stitch Header: Emblem Logo
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF004AC6), Color(0xFF2563EB)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF004AC6)
                                          .withValues(alpha: 0.25),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Stitch Header: Badge Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBE1FF).withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'PORTAL SISWA & AKADEMIK',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFF004AC6),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Stitch Header: Title
                              Text(
                                'Vintech School',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF191C1E),
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Stitch Header: Subtitle
                              Text(
                                'Masuk ke akun Anda untuk mengakses presensi, jadwal & kartu ujian.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  color: const Color(0xFF565E74),
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Input 1: ID Pengguna / NISN / NIP
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'ID Pengguna / NISN / NIP',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF191C1E),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE0E3E5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF191C1E)
                                          .withValues(alpha: 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _usernameController,
                                  textInputAction: TextInputAction.next,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: const Color(0xFF191C1E),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan NISN / Username',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      color: const Color(0xFF737686),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.badge_outlined,
                                      color: Color(0xFF565E74),
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'ID Pengguna wajib diisi';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Input 2: Kata Sandi
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Kata Sandi',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF191C1E),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE0E3E5)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF191C1E)
                                          .withValues(alpha: 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _onLogin(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: const Color(0xFF191C1E),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan Kata Sandi',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 13.5,
                                      color: const Color(0xFF737686),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: Color(0xFF565E74),
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF565E74),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Kata sandi wajib diisi';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Auxiliary Controls (Ingat Saya & Lupa Sandi)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _rememberMe = !_rememberMe;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              activeColor: const Color(0xFF004AC6),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              onChanged: (val) {
                                                setState(() {
                                                  _rememberMe = val ?? true;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Ingat Saya',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF434655),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: _showForgotPasswordDialog,
                                    child: Text(
                                      'Lupa Kata Sandi?',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF004AC6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 22),

                              // Primary CTA Button (Masuk ke Akun)
                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF004AC6),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        shadowColor: const Color(0xFF004AC6)
                                            .withValues(alpha: 0.3),
                                      ),
                                      onPressed: isLoading ? null : _onLogin,
                                      child: isLoading
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  'Memverifikasi...',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Masuk ke Akun',
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  size: 19,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Divider "atau"
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(color: Color(0xFFE0E3E5)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'atau',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: const Color(0xFF737686),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(color: Color(0xFFE0E3E5)),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Biometric Button (Stitch Specification)
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Color(0xFFE0E3E5)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: _simulateBiometric,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.fingerprint_rounded,
                                        size: 22,
                                        color: Color(0xFF004AC6),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Face ID / Sidik Jari',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF191C1E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // 1-Click Fast Demo Accounts Section
                              _buildDemoSection(),

                              const SizedBox(height: 28),

                              // Minimalist Footer (Stitch Specification)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Butuh bantuan akses? ',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      color: const Color(0xFF565E74),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: _showTuContactSheet,
                                    child: Text(
                                      'Hubungi Tata Usaha (TU)',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF004AC6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '© 2026 Vintech School • v2.4.0',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF737686),
                                ),
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

                // 3. Server Settings Action (Discreet Top Bar Button - Top Right)
                Positioned(
                  top: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 12),
                      child: IconButton(
                        icon: const Icon(
                          Icons.dns_outlined,
                          size: 21,
                          color: Color(0xFF737686),
                        ),
                        tooltip: 'Pengaturan Server API',
                        onPressed: () => ServerSettingsSheet.show(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8EA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Color(0xFFD97706),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AKUN DEMO CEPAT (1-KLIK)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFF191C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Siswa
          _buildRoleHeader('🎓 Akun Siswa (Pelajar):'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildDemoChip(
                label: 'Siswa SMAN 1 Jakarta',
                username: 'siswa.sman1jkt.20261001',
                password: 'siswa123',
                color: const Color(0xFF004AC6),
              ),
              _buildDemoChip(
                label: 'Siswa SMK Vintech Bandung',
                username: 'siswa.smkvintech.20262001',
                password: 'siswa123',
                color: const Color(0xFF0284C7),
              ),
              _buildDemoChip(
                label: 'Siswa SMP Al-Hikmah',
                username: 'siswa.smpalhikmah.20263001',
                password: 'siswa123',
                color: const Color(0xFF059669),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Guru
          _buildRoleHeader('👨‍🏫 Akun Guru (Tenaga Pendidik):'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildDemoChip(
                label: 'Guru SMAN 1 (Fisika)',
                username: 'guru.sman1jkt.198609182011012004',
                password: 'guru123',
                color: const Color(0xFF004AC6),
              ),
              _buildDemoChip(
                label: 'Guru SMK Vintech (RPL)',
                username: 'guru.smkvintech.199205112018011005',
                password: 'guru123',
                color: const Color(0xFF0284C7),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Admin
          _buildRoleHeader('🏢 Akun Admin Sekolah:'),
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

  Widget _buildRoleHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF565E74),
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

    return Material(
      color: isSelected ? color.withValues(alpha: 0.08) : const Color(0xFFF7F9FB),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _fillAccount(username, password),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : const Color(0xFFE0E3E5),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
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
                  color: isSelected ? color : const Color(0xFF191C1E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
