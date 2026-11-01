import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/background_sync_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/update/ota_update_service.dart';
import '../../../core/widgets/smooth_welcome_page_route.dart';
import '../../academic/data/academic_repository.dart';
import '../../academic/logic/attendance_cubit.dart';
import '../../academic/presentation/academic_screen.dart';
import '../../academic/presentation/attendance_screen.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/logic/auth_cubit.dart';
import '../../auth/logic/auth_state.dart';
import '../../auth/presentation/login_screen.dart';
import '../../billing/logic/billing_cubit.dart';
import '../../billing/logic/billing_state.dart';
import '../../billing/presentation/billing_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../logic/home_cubit.dart';
import 'student_dashboard_view.dart';
import 'teacher_dashboard_view.dart';
import 'widgets/app_base_top_bar.dart';
import 'widgets/app_bottom_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserProfileResponse profile;

  const MainNavigationScreen({super.key, required this.profile});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  // Deferred / Lazy Tab First-Mount: Hanya memuat Tab 0 pada startup.
  // Tab 1-4 hanya dimuat saat pertama kali dikunjungi dan di-cache permanen di GPU memory.
  final Set<int> _activatedTabs = {0};
  // Zero-rebuild ValueNotifier: Mengisolasi transisi hide/show Bottom Nav Bar
  // agar TIDAK memicu setState() ataupun me-rebuild widget tree utama saat user scrolling.
  final ValueNotifier<bool> _isNavBarVisible = ValueNotifier<bool>(true);
  BackgroundSyncService? _bgSyncService;
  late List<ScrollController> _scrollControllers;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _scrollControllers = List.generate(_tabCount, (_) => ScrollController());
    _buildPages();

    // Load home dashboard (0ms Hive + Background Cloud Sync)
    context.read<HomeCubit>().loadDashboard();

    // Start Background Sync & App Lifecycle Engine
    _bgSyncService = BackgroundSyncService(
      storage: context.read<LocalStorage>(),
      academicRepository: context.read<AcademicRepository>(),
      homeCubit: context.read<HomeCubit>(),
      attendanceCubit: context.read<AttendanceCubit>(),
      billingCubit: context.read<BillingCubit>(),
      profile: widget.profile,
      otaUpdateService: context.read<OtaUpdateService>(),
      onOutboxSynced: (count) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ $count presensi offline dari Hive berhasil disinkronkan ke server!',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      },
      onOtaStatusChanged: (status) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '✨ Pembaruan kode baru telah diunduh di latar belakang. Buka Pengaturan untuk menerapkan.',
            ),
            backgroundColor: const Color(0xFF7C3AED),
            duration: const Duration(seconds: 4),
          ),
        );
      },
    )..start();
  }

  /// Inisialisasi daftar halaman satu kali (Persistent Cached Pages):
  /// Menggunakan strategi Deferred First-Mount: Hanya memuat Tab 0 pada startup.
  /// Tab 1-4 hanya dimuat saat pertama kali dikunjungi dan di-cache permanen di GPU memory.
  void _buildPages() {
    if (_isParent) {
      // Sajian 4-Tab Khusus Orang Tua: [0: Beranda, 1: Presensi, 2: Tagihan SPP, 3: Profil]
      _pages = [
        RepaintBoundary(
          child: StudentDashboardView(
            profile: widget.profile,
            scrollController: _scrollControllers[0],
            onNavigateTab: _handleTabTap,
            onOpenBilling: () => _handleTabTap(2),
          ),
        ),
        _activatedTabs.contains(1)
            ? RepaintBoundary(
                child: AttendanceScreen(
                  profile: widget.profile,
                  scrollController: _scrollControllers[1],
                ),
              )
            : const SizedBox.shrink(),
        _activatedTabs.contains(2)
            ? RepaintBoundary(
                child: BillingScreen(
                  profile: widget.profile,
                  scrollController: _scrollControllers[2],
                ),
              )
            : const SizedBox.shrink(),
        _activatedTabs.contains(3)
            ? RepaintBoundary(
                child: ProfileScreen(
                  profile: widget.profile,
                  scrollController: _scrollControllers[3],
                ),
              )
            : const SizedBox.shrink(),
      ];
    } else if (_isStudent) {
      // Sajian 4-Tab Khusus Siswa: [0: Beranda, 1: Presensi, 2: Akademik, 3: Profil]
      // (Tagihan SPP disembunyikan dari bottom bar agar masuk lewat Dashboard)
      _pages = [
        RepaintBoundary(
          child: StudentDashboardView(
            profile: widget.profile,
            scrollController: _scrollControllers[0],
            onNavigateTab: _handleTabTap,
            onOpenBilling: _openBillingScreen,
          ),
        ),
        _activatedTabs.contains(1)
            ? RepaintBoundary(
                child: AttendanceScreen(
                  profile: widget.profile,
                  scrollController: _scrollControllers[1],
                ),
              )
            : const SizedBox.shrink(),
        _activatedTabs.contains(2)
            ? RepaintBoundary(
                child: AcademicScreen(
                  profile: widget.profile,
                  scrollController: _scrollControllers[2],
                ),
              )
            : const SizedBox.shrink(),
        _activatedTabs.contains(3)
            ? RepaintBoundary(
                child: ProfileScreen(
                  profile: widget.profile,
                  scrollController: _scrollControllers[3],
                ),
              )
            : const SizedBox.shrink(),
      ];
    } else {
      // Sajian 5-Tab Standar Guru / Staf: [0: Beranda, 1: Presensi Kelas, 2: Akademik, 3: Keuangan, 4: Profil]
      _pages = [
        RepaintBoundary(
          child: TeacherDashboardView(
            profile: widget.profile,
            scrollController: _scrollControllers[0],
            onNavigateTab: _handleTabTap,
          ),
        ),
        _activatedTabs.contains(1)
            ? RepaintBoundary(
                child: AttendanceScreen(
                  profile: widget.profile,
                  scrollController: _scrollControllers[1],
                ),
              )
            : const SizedBox.shrink(),
        _activatedTabs.contains(2)
            ? RepaintBoundary(
                child: AcademicScreen(
                  profile: widget.profile,
                  scrollController: _scrollControllers[2],
                ),
              )
            : const SizedBox.shrink(),
        _activatedTabs.contains(3)
            ? RepaintBoundary(
                child: BillingScreen(
                  profile: widget.profile,
                  scrollController: _scrollControllers[3],
                ),
              )
            : const SizedBox.shrink(),
        _activatedTabs.contains(4)
            ? RepaintBoundary(
                child: ProfileScreen(
                  profile: widget.profile,
                  scrollController: _scrollControllers[4],
                ),
              )
            : const SizedBox.shrink(),
      ];
    }
  }

  void _activateTab(int index) {
    if (!_activatedTabs.contains(index)) {
      _activatedTabs.add(index);
      if (_isParent) {
        switch (index) {
          case 1:
            _pages[1] = RepaintBoundary(
              child: AttendanceScreen(
                profile: widget.profile,
                scrollController: _scrollControllers[1],
              ),
            );
            break;
          case 2:
            _pages[2] = RepaintBoundary(
              child: BillingScreen(
                profile: widget.profile,
                scrollController: _scrollControllers[2],
              ),
            );
            break;
          case 3:
            _pages[3] = RepaintBoundary(
              child: ProfileScreen(
                profile: widget.profile,
                scrollController: _scrollControllers[3],
              ),
            );
            break;
        }
      } else if (_isStudent) {
        switch (index) {
          case 1:
            _pages[1] = RepaintBoundary(
              child: AttendanceScreen(
                profile: widget.profile,
                scrollController: _scrollControllers[1],
              ),
            );
            break;
          case 2:
            _pages[2] = RepaintBoundary(
              child: AcademicScreen(
                profile: widget.profile,
                scrollController: _scrollControllers[2],
              ),
            );
            break;
          case 3:
            _pages[3] = RepaintBoundary(
              child: ProfileScreen(
                profile: widget.profile,
                scrollController: _scrollControllers[3],
              ),
            );
            break;
        }
      } else {
        switch (index) {
          case 1:
            _pages[1] = RepaintBoundary(
              child: AttendanceScreen(
                profile: widget.profile,
                scrollController: _scrollControllers[1],
              ),
            );
            break;
          case 2:
            _pages[2] = RepaintBoundary(
              child: AcademicScreen(
                profile: widget.profile,
                scrollController: _scrollControllers[2],
              ),
            );
            break;
          case 3:
            _pages[3] = RepaintBoundary(
              child: BillingScreen(
                profile: widget.profile,
                scrollController: _scrollControllers[3],
              ),
            );
            break;
          case 4:
            _pages[4] = RepaintBoundary(
              child: ProfileScreen(
                profile: widget.profile,
                scrollController: _scrollControllers[4],
              ),
            );
            break;
        }
      }
    }
  }

  @override
  void didUpdateWidget(MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      if (_scrollControllers.length != _tabCount) {
        for (final controller in _scrollControllers) {
          controller.dispose();
        }
        _scrollControllers = List.generate(_tabCount, (_) => ScrollController());
      }
      if (_currentIndex >= _tabCount) {
        _currentIndex = 0;
      }
      _buildPages();
    }
  }

  @override
  void dispose() {
    _isNavBarVisible.dispose();
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    _bgSyncService?.dispose();
    super.dispose();
  }

  Color get _schoolColor => AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);

  bool get _isStaffOrTeacher => widget.profile.activeSchool?.isStaffOrTeacher == true;
  bool get _isParent => widget.profile.activeSchool?.isParent == true;
  bool get _isStudent => widget.profile.activeSchool?.isStudent == true || (!_isStaffOrTeacher && !_isParent);
  int get _tabCount => _isStaffOrTeacher ? 5 : 4;

  void _openBillingScreen() {
    Navigator.of(context).push(
      SmoothWelcomePageRoute(
        child: BillingScreen(
          profile: widget.profile,
        ),
      ),
    );
  }

  /// Smart Reselect & Tab Switching:
  /// - Jika tab lain ditekan: Aktifkan tab (jika belum pernah dibuka), pindah tab & tampilkan bar navigasi.
  /// - Jika tab yang sedang aktif ditekan kembali: Memicu animasi smooth Scroll-to-Top!
  void _handleTabTap(int index) {
    if (index < 0 || index >= _tabCount) return;

    if (index == _currentIndex) {
      _scrollToTop(index);
    } else {
      _activateTab(index);
      setState(() {
        _currentIndex = index;
      });
      _isNavBarVisible.value = true;
    }
  }

  void _scrollToTop(int index) {
    _isNavBarVisible.value = true;
    if (index >= 0 && index < _scrollControllers.length) {
      final controller = _scrollControllers[index];
      if (controller.hasClients) {
        controller.animateTo(
          0.0,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  /// High-Performance Scroll Notification Listener:
  /// Menggunakan ValueNotifier langsung (tanpa setState) sehingga 0 frame drop / lag saat scrolling.
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is ScrollUpdateNotification) {
        final pixels = notification.metrics.pixels;
        final delta = notification.scrollDelta ?? 0.0;

        // 1. Jika dekat posisi teratas (< 30px), selalu tampilkan bar
        if (pixels <= 30.0) {
          if (!_isNavBarVisible.value) {
            _isNavBarVisible.value = true;
          }
        }
        // 2. Scroll ke bawah terukur (> 8px) dan sudah melewati batas atas (> 80px) -> Sembunyikan bar
        else if (delta > 8.0 && _isNavBarVisible.value && pixels > 80.0) {
          _isNavBarVisible.value = false;
        }
        // 3. Scroll ke atas terukur (< -8px) -> Munculkan kembali bar seketika
        else if (delta < -8.0 && !_isNavBarVisible.value) {
          _isNavBarVisible.value = true;
        }
      } else if (notification is ScrollEndNotification) {
        // Jika berhenti di ujung atas atau ujung bawah layar, pastikan bar muncul
        if (notification.metrics.pixels <= 30.0 ||
            notification.metrics.pixels >= notification.metrics.maxScrollExtent - 24.0) {
          if (!_isNavBarVisible.value) {
            _isNavBarVisible.value = true;
          }
        }
      }
    }
    return false;
  }

  DateTime? _lastBackPressTime;

  /// Algoritma Navigasi Tombol Kembali Cerdas:
  /// 1. Jika pengguna TIDAK berada di Beranda (misal di Presensi, Akademik, Tagihan SPP, atau Profil):
  ///    Tombol kembali mengarahkan pengguna kembali ke tab Beranda (index 0) secara mulus.
  /// 2. Jika pengguna SUDAH berada di Beranda (index 0):
  ///    Menerapkan algoritma "Double-Tap to Exit" (klik 2x dalam jeda <= 2 detik).
  ///    Klik pertama memunculkan notifikasi peringatan mengambang.
  ///    Klik kedua mengizinkan aplikasi keluar secara bersih.
  void _handleBackPress() {
    if (_currentIndex != 0) {
      HapticFeedback.lightImpact();
      _handleTabTap(0);
      return;
    }

    final now = DateTime.now();
    if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      HapticFeedback.selectionClick();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Tekan sekali lagi untuk keluar dari aplikasi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            // Sesi dibatalkan atau berakhir (misal 401 saat background sync)
            Navigator.of(context).pushAndRemoveUntil(
              SmoothWelcomePageRoute(child: const LoginScreen()),
              (route) => false,
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          extendBody: true,
          body: Column(
          children: [
            // 1. BASE TOP BAR TERPADU (Wadah Statis Permanen - Bebas Kedip/Flicker)
            AppBaseTopBar(
              currentIndex: _currentIndex,
              profile: widget.profile,
              schoolColor: _schoolColor,
              isStaffOrTeacher: _isStaffOrTeacher,
            ),

            // 2. Transisi Konten Halus Bebas Rebuild
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScrollNotification,
                child: FadeIndexedStack(
                  index: _currentIndex,
                  duration: const Duration(milliseconds: 200),
                  children: _pages,
                ),
              ),
            ),
          ],
        ),
        // Isolasi Bottom Navigation Bar dengan ValueListenableBuilder & Builder:
        // Perubahan status hide/show atau update badge tagihan/outbox HANYA
        // merender ulang bilah navigasi tanpa menyentuh IndexedStack atau halaman aktif.
        bottomNavigationBar: ValueListenableBuilder<bool>(
          valueListenable: _isNavBarVisible,
          builder: (context, isVisible, child) {
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
            final isKeyboardVisible = bottomInset > 0;
            final isEffectiveVisible = isVisible && !isKeyboardVisible;

            return AnimatedSlide(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              offset: isEffectiveVisible ? Offset.zero : const Offset(0, 1.35),
              child: IgnorePointer(
                ignoring: !isEffectiveVisible,
                child: child,
              ),
            );
          },
          child: Builder(
            builder: (context) {
              final billingState = context.watch<BillingCubit>().state;
              final unpaidInvoiceCount = billingState is BillingLoaded
                  ? billingState.invoices.where((inv) => !inv.isPaid).length
                  : 0;
              final pendingOutbox = context.watch<LocalStorage>().hive.totalPendingOutbox;

              return AppBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _handleTabTap,
                schoolColor: _schoolColor,
                isStaffOrTeacher: _isStaffOrTeacher,
                isParent: _isParent,
                isStudent: _isStudent,
                pendingOutboxCount: pendingOutbox,
                unpaidInvoiceCount: unpaidInvoiceCount,
                isFloating: true,
              );
            },
          ),
        ),
      ),
    ),
  );
}
}

/// Transisi Halus (Smooth Crossfade & Micro-Scale) untuk perpindahan tab:
/// - Mencegah hentakan / frame drop yang terjadi pada IndexedStack standar
/// - Menginterpolasikan fade 200ms dengan kurva easeOutCubic
class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _animController = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: 1.0, // Langsung tampil penuh di frame pertama tanpa delay
    );

    _fadeAnimation = Tween<double>(begin: 0.20, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.992, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != _currentIndex) {
      _currentIndex = widget.index;
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: widget.children,
        ),
      ),
    );
  }
}
