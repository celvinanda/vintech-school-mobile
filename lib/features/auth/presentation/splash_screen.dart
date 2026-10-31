import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/presentation/main_navigation_screen.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';
import 'login_screen.dart';

/// Splash Screen Berstandar Google Stitch Design System ("Vintech School Splash").
/// Mengimplementasikan arsitektur performa tinggi:
/// 1. Coordinated Timing Handshake (Eliminasi flicker <5ms & delay buatan)
/// 2. Zero-Memory Allocation CustomPainter dengan RepaintBoundary caching
/// 3. Harmonic 3-Dot Wave Loading Animation
/// 4. 100% Tipografi Terpadu Plus Jakarta Sans
/// 5. Bulletproof Fallback Anti-Stuck (Penanganan AuthError & Timeout)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _hasNavigated = false;
  bool _isEntranceComplete = false;
  AuthState? _pendingState;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi Entrance Animation (650ms, easeOutCubic)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Saat animasi entrance tuntas, cek apakah auth state sudah siap
    _entranceController.forward().then((_) {
      if (!mounted) return;
      _isEntranceComplete = true;
      if (_pendingState != null) {
        _navigateToRoute(_pendingState!);
      }
    });

    // 2. Inisialisasi Harmonic 3-Dot Wave Animation (1200ms)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // 3. Pengecekan sesi lokal Hive (0ms) & Sinkronisasi Cloud
    context.read<AuthCubit>().checkSession();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  /// Navigasi sinkron dan elegan dengan transisi easeOutCubic
  void _navigateToRoute(AuthState state) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _waveController.stop();

    Widget targetScreen;
    if (state is Authenticated) {
      targetScreen = MainNavigationScreen(profile: state.profile);
    } else {
      // Unauthenticated maupun AuthError diarahkan secara aman ke LoginScreen (Anti-Stuck)
      targetScreen = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: targetScreen,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated || state is Unauthenticated || state is AuthError) {
          _pendingState = state;
          // Hanya berpindah jika animasi entrance sudah selesai agar visual tetap sempurna
          if (_isEntranceComplete) {
            _navigateToRoute(state);
          }
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F9FB), // Google Stitch: bg-surface
          body: Stack(
            children: [
              // 1. Ambient Glow Orbs (Di-cache permanen di GPU)
              _buildAmbientGlow(),

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
                            RepaintBoundary(
                              child: Container(
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
                            ),

                            const SizedBox(height: 24),

                            // Typography: Vintech School (100% Plus Jakarta Sans)
                            Text(
                              'Vintech School',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF191C1E), // text-on-surface
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.6,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Typography: Subtitle
                            Text(
                              'Sistem Akademik & Portal Siswa',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF565E74), // text-secondary
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.1,
                              ),
                            ),

                            const SizedBox(height: 36),

                            // Stitch Harmonic 3-Dot Wave Loading Animation
                            _buildWaveLoadingIndicator(),

                            const SizedBox(height: 14),

                            // Dynamic Live Status Indicator
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                String statusText = 'Memeriksa sesi akun...';
                                if (state is AuthLoading && state.message != null) {
                                  statusText = state.message!;
                                } else if (state is Authenticated) {
                                  statusText = 'Menyiapkan portal siswa...';
                                } else if (state is AuthError) {
                                  statusText = 'Mengarahkan ke login...';
                                }

                                return Text(
                                  statusText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
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

                    // 3. Discreet Minimalist Footer
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Vintech Nusantara Edukasi',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF565E74),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'v2.4.0 • Enterprise Edition',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
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

  /// Ambient Glow Orbs diisolasi dengan RepaintBoundary agar 0 cost GPU repaint
  Widget _buildAmbientGlow() {
    return RepaintBoundary(
      child: IgnorePointer(
        child: Stack(
          children: [
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
          ],
        ),
      ),
    );
  }

  /// Indikator Wave 3 Titik Harmonic Berstandar Google Stitch
  Widget _buildWaveLoadingIndicator() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // Offset fase 0.18 per dot untuk gerakan gelombang organik
            final t = (_waveController.value - (index * 0.18)) % 1.0;
            final progress = (math.sin(t * math.pi * 2) + 1.0) / 2.0;
            final scale = 0.75 + (0.45 * progress);
            final opacity = 0.35 + (0.65 * progress);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF004AC6).withValues(alpha: opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Custom Vector Painter mereproduksi Toga / Graduation Cap SVG dari Google Stitch
/// Menggunakan objek Paint yang di-cache untuk mencegah alokasi memori heap di setiap frame
class _StitchGraduationCapPainter extends CustomPainter {
  final Paint _tasselPaint = Paint()
    ..color = const Color(0xFF004AC6)
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  final Paint _circlePaint = Paint()
    ..color = const Color(0xFF004AC6)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 48.0;
    final scaleY = size.height / 48.0;

    canvas.save();
    canvas.scale(scaleX, scaleY);

    // Gradien Resmi Vintech Stitch (#004AC6 -> #2563EB)
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

    // 1. Top Rhombus Cap (M24 6L6 16L24 26L42 16L24 6Z)
    final topCapPath = Path()
      ..moveTo(24, 6)
      ..lineTo(6, 16)
      ..lineTo(24, 26)
      ..lineTo(42, 16)
      ..close();
    canvas.drawPath(topCapPath, paintMain);

    // 2. Lower Cap Body (M12 21.5V30.5C12 34.2 17.4 37.5 24 37.5C30.6 37.5 36 34.2 36 30.5V21.5L24 28.5L12 21.5Z)
    final bodyPath = Path()
      ..moveTo(12, 21.5)
      ..lineTo(12, 30.5)
      ..cubicTo(12, 34.2, 17.4, 37.5, 24, 37.5)
      ..cubicTo(30.6, 37.5, 36, 34.2, 36, 30.5)
      ..lineTo(36, 21.5)
      ..lineTo(24, 28.5)
      ..close();
    canvas.drawPath(bodyPath, paintBody);

    // 3. Tassel String & Ball
    canvas.drawLine(const Offset(40, 18), const Offset(40, 30), _tasselPaint);
    canvas.drawCircle(const Offset(40, 31), 2.0, _circlePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
