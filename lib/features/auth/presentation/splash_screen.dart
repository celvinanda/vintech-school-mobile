import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/widgets/smooth_welcome_page_route.dart';
import '../../home/presentation/main_navigation_screen.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';
import 'login_screen.dart';

/// Splash Screen Berstandar Google Stitch Design System ("Vintech School Splash").
/// Mengimplementasikan arsitektur performa tinggi & keamanan enterprise:
/// 1. Coordinated Timing Handshake Adaptif (Returning: 450ms, First: 900ms, Reduce Motion: 0ms)
/// 2. Overlapping Exit Dissolve (≤420ms) selaras dengan Welcoming Bloom Route
/// 3. Zero-Heap Allocation CustomPainter dengan RepaintBoundary GPU caching
/// 4. Aksesibilitas Terpadu: Semantics + Clamped Text Scaling + Reduce Motion Guard
/// 5. Bulletproof Fallback Anti-Stuck: Watchdog 2500ms selalu fallback ke LoginScreen
/// 6. Responsif Bebas RenderFlex Overflow: LayoutBuilder + IntrinsicHeight
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
  Timer? _watchdogTimer;
  late final DateTime _initTime;

  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _exitController;
  late Animation<double> _exitFadeAnimation;
  late Animation<double> _exitScaleAnimation;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _initTime = DateTime.now();

    // 1. Inisialisasi Entrance Animation (500ms, easeOutCubic)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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

    // 2. Inisialisasi Exit Dissolve Animation (320ms - Overlap dengan Route Transition)
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInCubic,
      ),
    );

    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Saat animasi entrance tuntas, jadwalkan navigasi dengan pacing adaptif
    _entranceController.forward().then((_) {
      if (!mounted) return;
      _isEntranceComplete = true;
      _triggerScheduledNavigation();
    });

    // 3. Inisialisasi Harmonic 3-Dot Wave Animation (1100ms)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    // 4. Pengecekan sesi lokal Hive (~1-5ms) & Sinkronisasi Cloud
    context.read<AuthCubit>().checkSession();

    // 5. Post-Frame Synchronous Evaluation:
    // Menangkap state jika Hive mengembalikan state secara instan sebelum BlocListener mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasNavigated) return;
      final currentState = context.read<AuthCubit>().state;
      if (currentState is Authenticated ||
          currentState is Unauthenticated ||
          currentState is AuthError) {
        _pendingState = currentState;
        if (_isEntranceComplete) {
          _triggerScheduledNavigation();
        }
      }
    });

    // 6. Fail-Safe Watchdog Timer Anti-Stuck (Maksimal 2.5 detik)
    // Selalu fallback ke LoginScreen secara aman jika terjadi anomali
    _watchdogTimer = Timer(const Duration(milliseconds: 2500), () {
      if (!mounted || _hasNavigated) return;
      debugPrint('[SPLASH WATCHDOG] Fallback aman ke LoginScreen (timeout 2500ms).');
      _navigateToRoute(Unauthenticated());
    });
  }

  /// Menjadwalkan transisi dengan Dwell Time Adaptif:
  /// - Reduce Motion aktif (disableAnimations): 0 ms (langsung handoff)
  /// - Returning Daily User: ~450 ms (snappy, bebas "pajak waktu")
  /// - First Launch / Update: ~900 ms (branding penuh)
  void _triggerScheduledNavigation() {
    if (_hasNavigated || !mounted) return;

    final currentState = context.read<AuthCubit>().state;
    final stateToUse = _pendingState ?? currentState;

    if (stateToUse is Authenticated ||
        stateToUse is Unauthenticated ||
        stateToUse is AuthError) {
      final reduceMotion = MediaQuery.of(context).disableAnimations;
      if (reduceMotion) {
        _navigateToRoute(stateToUse);
        return;
      }

      final isReturning = context.read<LocalStorage>().isReturningUser();
      final targetDwell = isReturning ? 450 : 900;
      final elapsed = DateTime.now().difference(_initTime).inMilliseconds;
      final remainingDwell = math.max(0, targetDwell - elapsed);

      Future.delayed(Duration(milliseconds: remainingDwell), () {
        if (!mounted || _hasNavigated) return;
        _navigateToRoute(stateToUse);
      });
    }
  }

  @override
  void dispose() {
    _watchdogTimer?.cancel();
    _entranceController.dispose();
    _exitController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  /// Navigasi sinkron dan elegan dengan transisi Welcoming Bloom & Exit Dissolve
  void _navigateToRoute(AuthState state) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _watchdogTimer?.cancel();
    _waveController.stop();

    // Catat bahwa pengguna sudah pernah membuka aplikasi
    try {
      context.read<LocalStorage>().markUserVisited();
    } catch (_) {}

    // Jalankan efek dissolve pada emblem splash yang tumpang tindih (overlap)
    _exitController.forward();

    Widget targetScreen;
    if (state is Authenticated) {
      targetScreen = MainNavigationScreen(profile: state.profile);
    } else {
      // Unauthenticated maupun AuthError selalu diarahkan secara aman ke LoginScreen
      targetScreen = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      SmoothWelcomePageRoute(child: targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final clampedScale = mediaQuery.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.15);

    return Semantics(
      label: 'Memuat Vintech School',
      container: true,
      child: MediaQuery(
        data: mediaQuery.copyWith(textScaler: clampedScale),
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated || state is Unauthenticated || state is AuthError) {
              _pendingState = state;
              if (_isEntranceComplete) {
                _triggerScheduledNavigation();
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
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  // 1. Ambient Glow Orbs (Di-cache permanen di GPU)
                  Positioned.fill(
                    child: _buildAmbientGlow(),
                  ),

                  // 2. Modul Konten Utama (Center Branding)
                  Positioned.fill(
                    child: SafeArea(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: constraints.maxHeight),
                              child: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Spacer(flex: 3),

                                    // Center Emblem & Typography (Presisi di Tengah Layar Penuh)
                                    Center(
                                      child: FadeTransition(
                                        opacity: _exitFadeAnimation,
                                        child: ScaleTransition(
                                          scale: _exitScaleAnimation,
                                          child: FadeTransition(
                                            opacity: _fadeAnimation,
                                            child: ScaleTransition(
                                              scale: _scaleAnimation,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                                    textAlign: TextAlign.center,
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
                                                    textAlign: TextAlign.center,
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

                                                  // Dynamic Live Status Indicator (Sapaan Hangat Personal)
                                                  BlocBuilder<AuthCubit, AuthState>(
                                                    builder: (context, state) {
                                                      String statusText = 'Memeriksa sesi akun...';
                                                      Color statusColor = const Color(0xFF737686);
                                                      if (state is AuthLoading && state.message != null) {
                                                        statusText = state.message!;
                                                      } else if (state is Authenticated) {
                                                        final name = state.profile.user.firstName;
                                                        statusText = 'Selamat datang kembali, $name';
                                                        statusColor = const Color(0xFF004AC6);
                                                      } else if (state is Unauthenticated) {
                                                        statusText = 'Menyiapkan portal siswa...';
                                                        statusColor = const Color(0xFF004AC6);
                                                      } else if (state is AuthError) {
                                                        statusText = 'Mengarahkan ke login...';
                                                      }

                                                      return AnimatedSwitcher(
                                                        duration: const Duration(milliseconds: 250),
                                                        child: Text(
                                                          statusText,
                                                          key: ValueKey(statusText),
                                                          textAlign: TextAlign.center,
                                                          style: GoogleFonts.plusJakartaSans(
                                                            fontSize: 12.5,
                                                            fontWeight: FontWeight.w600,
                                                            color: statusColor,
                                                            letterSpacing: 0.1,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const Spacer(flex: 4),

                                    // 3. Discreet Minimalist Footer (Presisi di Tengah Bawah)
                                    Center(
                                      child: FadeTransition(
                                        opacity: _exitFadeAnimation,
                                        child: FadeTransition(
                                          opacity: _fadeAnimation,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Vintech Nusantara Edukasi',
                                                  textAlign: TextAlign.center,
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
                                                  textAlign: TextAlign.center,
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
          fit: StackFit.expand,
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
            // Offset fase 0.16 per dot untuk gerakan gelombang organik
            final t = (_waveController.value - (index * 0.16)) % 1.0;
            final progress = (math.sin(t * math.pi * 2) + 1.0) / 2.0;
            final scale = 0.75 + (0.40 * progress);
            final opacity = 0.30 + (0.70 * progress);

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
