import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/presentation/main_navigation_screen.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _hasNavigated = false;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Animasi kemunculan (Entrance Animation)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _entranceController.forward();

    // 2. Animasi pulsing dot mikro (Looping pulse sesuai Stitch)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Pengecekan sesi offline-first & backend
    _initAppFlow();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initAppFlow() async {
    final cubit = context.read<AuthCubit>();
    // Memeriksa sesi lokal Hive (zero latency) & sinkronisasi profil
    cubit.checkSession();

    // Durasi minimum 1400ms agar animasi Stitch dapat dinikmati pengguna secara elegan
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    _handleNavigation(cubit.state);
  }

  void _handleNavigation(AuthState state) {
    if (_hasNavigated || !mounted) return;

    if (state is Authenticated) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: MainNavigationScreen(profile: state.profile),
          ),
        ),
      );
    } else if (state is Unauthenticated) {
      _hasNavigated = true;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
            opacity: animation,
            child: const LoginScreen(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        _handleNavigation(state);
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
          body: Stack(
            children: [
              // 1. Ambient Glow Orbs (Stitch Design Specification)
              // Ambient Glow Atas: #DBE1FF opacity 30%
              Positioned(
                top: -100,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFDBE1FF).withValues(alpha: 0.50),
                          const Color(0xFFDBE1FF).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Ambient Glow Bawah-Kanan: #DAE2FD opacity 25%
              Positioned(
                bottom: -80,
                right: -60,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFDAE2FD).withValues(alpha: 0.40),
                        const Color(0xFFDAE2FD).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Modul Konten Utama (Center Branding)
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // Center Emblem & Typography
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Stitch Center Emblem (96x96 rounded-3xl with subtle border & shadow)
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFE6E8EA),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF191C1E).withValues(alpha: 0.05),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF004AC6).withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomPaint(
                                  size: const Size(48, 48),
                                  painter: _StitchGraduationCapPainter(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Typography: Vintech School
                            Text(
                              'Vintech School',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF191C1E), // text-on-surface
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Typography: Subtitle
                            Text(
                              'Sistem Akademik & Portal Siswa',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF565E74), // text-secondary
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Stitch Minimalist Loading Indicator (3 Pulsing Dots)
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Dot 1: Pulsing Active Micro-dot
                                    Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF004AC6).withValues(
                                            alpha: 0.6 + (_pulseAnimation.value - 0.7) * 0.7,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Dot 2: Solid Primary Dot
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF004AC6),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Dot 3: Muted Ambient Dot
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF004AC6).withValues(alpha: 0.35),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            // Dynamic Live Status Indicator
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                String statusText = 'Memeriksa sesi akun...';
                                if (state is AuthLoading && state.message != null) {
                                  statusText = state.message!;
                                } else if (state is Authenticated) {
                                  statusText = 'Selamat datang kembali...';
                                }

                                return Text(
                                  statusText,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF737686),
                                    letterSpacing: 0.1,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // 3. Discreet Minimalist Footer (Stitch Specification)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Vintech Nusantara Edukasi',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF565E74),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'v2.4.0',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF737686).withValues(alpha: 0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Vector Painter mereproduksi Toga / Graduation Cap SVG dari Google Stitch
class _StitchGraduationCapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 48.0;
    final scaleY = size.height / 48.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // 1. Gradien Resmi Vintech Stitch (#004AC6 -> #2563EB)
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF004AC6), Color(0xFF2563EB)],
    ).createShader(const Rect.fromLTWH(6, 6, 36, 32));

    final paintMain = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;

    final paintBody = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF004AC6).withValues(alpha: 0.85);

    // 2. Top Rhombus Cap (M24 6L6 16L24 26L42 16L24 6Z)
    final topCapPath = Path()
      ..moveTo(24, 6)
      ..lineTo(6, 16)
      ..lineTo(24, 26)
      ..lineTo(42, 16)
      ..close();
    canvas.drawPath(topCapPath, paintMain);

    // 3. Lower Cap Body (M12 21.5V30.5C12 34.2 17.4 37.5 24 37.5C30.6 37.5 36 34.2 36 30.5V21.5L24 28.5L12 21.5Z)
    final bodyPath = Path()
      ..moveTo(12, 21.5)
      ..lineTo(12, 30.5)
      ..cubicTo(12, 34.2, 17.4, 37.5, 24, 37.5)
      ..cubicTo(30.6, 37.5, 36, 34.2, 36, 30.5)
      ..lineTo(36, 21.5)
      ..lineTo(24, 28.5)
      ..close();
    canvas.drawPath(bodyPath, paintBody);

    // 4. Tassel String (M40 18V30)
    final tasselPaint = Paint()
      ..color = const Color(0xFF004AC6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(40, 18), const Offset(40, 30), tasselPaint);

    // 5. Tassel End Ball (circle cx="40" cy="31" r="2")
    final circlePaint = Paint()
      ..color = const Color(0xFF004AC6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(40, 31), 2.0, circlePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
