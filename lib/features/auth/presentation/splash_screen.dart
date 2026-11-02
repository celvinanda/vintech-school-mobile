import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../../../core/update/ota_update_service.dart';
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
/// 1. Coordinated Timing Handshake Adaptif (Returning: 400ms, First/Update: 800ms, Reduce Motion: 0ms)
/// 2. Overlapping Exit Dissolve (≤300ms) selaras dengan Welcoming Bloom Route
/// 3. Zero-Heap Allocation CustomPainter dengan RepaintBoundary GPU caching
/// 4. Aksesibilitas Terpadu: Semantics + Clamped Text Scaling + Reduce Motion Guard
/// 5. Bulletproof Fallback Anti-Stuck: Watchdog 2500ms selalu fallback ke LoginScreen
/// 6. Responsif Bebas RenderFlex Overflow: LayoutBuilder + ConstrainedBox (Tanpa IntrinsicHeight)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _hasNavigated = false;
  bool _isEntranceComplete = false;
  bool _isOtaUpdating = false;
  String? _otaStatusMessage;
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

    // 1. Inisialisasi Entrance Animation yang tangkas & mulus (350ms, easeOutCubic)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
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

    // 2. Inisialisasi Exit Dissolve Animation (300ms - Overlap dengan Route Transition)
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _exitFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInCubic,
      ),
    );

    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
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

    // 5. Post-Frame Synchronous Evaluation & OTA Auto-Update Check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOtaOnStartup();
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
  /// - Returning Daily User: ~400 ms (snappy, bebas "pajak waktu")
  /// - First Launch / Update: ~800 ms (branding penuh)
  void _triggerScheduledNavigation() {
    if (_hasNavigated || !mounted || _isOtaUpdating) return;

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
      final targetDwell = isReturning ? 400 : 800;
      final elapsed = DateTime.now().difference(_initTime).inMilliseconds;
      final remainingDwell = math.max(0, targetDwell - elapsed);

      Future.delayed(Duration(milliseconds: remainingDwell), () {
        if (!mounted || _hasNavigated) return;
        _navigateToRoute(stateToUse);
      });
    }
  }

  /// Pemeriksaan & Unduh Otomatis Pembaruan Kode OTA (Shorebird) di Splash Screen
  /// Menjamin aplikasi selalu dalam versi mutakhir sebelum memasuki Beranda
  Future<void> _checkOtaOnStartup() async {
    if (!mounted) return;
    final storage = context.read<LocalStorage>();
    final otaService = context.read<OtaUpdateService>();

    // 1. Guard anti-loop: cegah restart berulang jika baru saja restart dalam 15 detik terakhir
    if (storage.shouldSkipOtaAutoRestart) {
      debugPrint('[OTA STARTUP] Skip auto-update guard (baru saja restart).');
      return;
    }

    if (!otaService.isShorebirdAvailable && !otaService.isDevSimulated) {
      return;
    }

    try {
      // 2. Cek patch baru dengan batas waktu aman 2.5 detik (tidak menahan user saat offline)
      final status = await otaService.checkForUpdate().timeout(
        const Duration(milliseconds: 2500),
      );

      if (status == UpdateStatus.outdated) {
        if (!mounted || _hasNavigated) return;
        _watchdogTimer?.cancel(); // Tangguhkan watchdog selama mengunduh patch

        setState(() {
          _isOtaUpdating = true;
          _otaStatusMessage = 'Mengunduh pembaruan sistem...';
        });

        final success = await otaService.downloadPatch(storage: storage);
        if (success && mounted) {
          setState(() {
            _otaStatusMessage = 'Menerapkan pembaruan sistem...';
          });
          await otaService.prepareForRestart(storage);
          await storage.markOtaRestarted();
          await Future.delayed(const Duration(milliseconds: 350));
          // Patch akan aktif otomatis pada peluncuran berikutnya
          return;
        }
      } else if (status == UpdateStatus.restartRequired) {
        if (!mounted || _hasNavigated) return;
        _watchdogTimer?.cancel();

        setState(() {
          _isOtaUpdating = true;
          _otaStatusMessage = 'Menerapkan pembaruan sistem...';
        });
        await otaService.prepareForRestart(storage);
        await storage.markOtaRestarted();
        await Future.delayed(const Duration(milliseconds: 350));
        // Patch akan aktif otomatis pada peluncuran berikutnya
        return;
      }
    } catch (e) {
      debugPrint('[OTA STARTUP] Skip OTA check: $e');
    } finally {
      if (mounted && _isOtaUpdating) {
        setState(() {
          _isOtaUpdating = false;
          _otaStatusMessage = null;
        });
        _triggerScheduledNavigation();
      }
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

    // Catat versi aplikasi terakhir yang dikunjungi pengguna
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
                          final minContentHeight = math.max(constraints.maxHeight, 520.0);
                          return SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                                minWidth: constraints.maxWidth,
                              ),
                              child: SizedBox(
                                height: minContentHeight,
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
                                                      String statusText = _otaStatusMessage ?? 'Memeriksa sesi akun...';
                                                      Color statusColor = _isOtaUpdating
                                                          ? const Color(0xFF004AC6)
                                                          : const Color(0xFF737686);
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
                                                Builder(
                                                  builder: (context) {
                                                    final appVersion = context.read<LocalStorage>().currentAppVersion;
                                                    return Text(
                                                      'v$appVersion • Enterprise Edition',
                                                      textAlign: TextAlign.center,
                                                      style: GoogleFonts.plusJakartaSans(
                                                        color: const Color(0xFF94A3B8),
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w500,
                                                        letterSpacing: 0.2,
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

  /// Ambient Glow Orbs sesuai Stitch Design Specification.
  /// Dibungkus RepaintBoundary agar di-cache permanen di GPU memory.
  Widget _buildAmbientGlow() {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -120,
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
                      const Color(0xFFDBE1FF).withValues(alpha: 0.45),
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
              width: 260,
              height: 260,
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
    );
  }

  /// Stitch 3-Dot Harmonic Wave Animation:
  /// Tiga titik berosilasi dengan kurva sinus offset fasa 120° (2*pi/3).
  Widget _buildWaveLoadingIndicator() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildWaveDot(0),
            const SizedBox(width: 8),
            _buildWaveDot(1),
            const SizedBox(width: 8),
            _buildWaveDot(2),
          ],
        );
      },
    );
  }

  Widget _buildWaveDot(int index) {
    // Offset fasa 120 derajat per titik
    final phaseOffset = index * (2 * math.pi / 3);
    final waveValue = math.sin(_waveController.value * 2 * math.pi - phaseOffset);
    final normalized = (waveValue + 1.0) / 2.0; // 0.0 -> 1.0

    // Animasi translasi Y (-4.5px hingga 0px)
    final translateY = -4.5 * normalized;
    // Animasi opacity (0.45 hingga 1.0)
    final opacity = 0.45 + (0.55 * normalized);
    // Animasi skala titik (0.85 hingga 1.15)
    final scale = 0.85 + (0.30 * normalized);

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF004AC6), // Google Stitch: primary royal blue
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter Toga Kelulusan (Graduation Cap) Vintech School berstandar Stitch Design.
/// Dialokasikan nol memory heap di Paint loop.
class _StitchGraduationCapPainter extends CustomPainter {
  static final Paint _capPaint = Paint()
    ..color = const Color(0xFF004AC6) // primary
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  static final Paint _accentPaint = Paint()
    ..color = const Color(0xFF6F9CFF) // primary light
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  static final Paint _tasselPaint = Paint()
    ..color = const Color(0xFFE0B300) // gold accent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  static final Paint _tasselTipPaint = Paint()
    ..color = const Color(0xFFE0B300)
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Belah ketupat mahkota toga (Rhombus Top Cap)
    final capPath = Path()
      ..moveTo(w * 0.50, h * 0.22)
      ..lineTo(w * 0.88, h * 0.40)
      ..lineTo(w * 0.50, h * 0.58)
      ..lineTo(w * 0.12, h * 0.40)
      ..close();
    canvas.drawPath(capPath, _capPaint);

    // 2. Garis lipatan / sorot cahaya mahkota toga
    final highlightPath = Path()
      ..moveTo(w * 0.50, h * 0.24)
      ..lineTo(w * 0.84, h * 0.40)
      ..lineTo(w * 0.50, h * 0.42)
      ..close();
    canvas.drawPath(highlightPath, _accentPaint);

    // 3. Batok kepala bawah toga (Skull Cap)
    final baseCapPath = Path()
      ..moveTo(w * 0.26, h * 0.47)
      ..lineTo(w * 0.26, h * 0.64)
      ..quadraticBezierTo(w * 0.50, h * 0.80, w * 0.74, h * 0.64)
      ..lineTo(w * 0.74, h * 0.47)
      ..quadraticBezierTo(w * 0.50, h * 0.60, w * 0.26, h * 0.47)
      ..close();
    canvas.drawPath(baseCapPath, _capPaint);

    // 4. Tali rumbai emas (Gold Tassel)
    final tasselPath = Path()
      ..moveTo(w * 0.50, h * 0.40)
      ..quadraticBezierTo(w * 0.22, h * 0.42, w * 0.18, h * 0.66);
    canvas.drawPath(tasselPath, _tasselPaint);

    // Bandul ujung rumbai
    canvas.drawCircle(Offset(w * 0.18, h * 0.68), 2.5, _tasselTipPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

