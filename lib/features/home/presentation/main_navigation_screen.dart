import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/background_sync_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/update/ota_update_service.dart';
import '../../academic/data/academic_repository.dart';
import '../../academic/logic/attendance_cubit.dart';
import '../../academic/presentation/academic_screen.dart';
import '../../academic/presentation/attendance_screen.dart';
import '../../auth/data/models/user_model.dart';
import '../../billing/logic/billing_cubit.dart';
import '../../billing/logic/billing_state.dart';
import '../../billing/presentation/billing_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../logic/home_cubit.dart';
import 'student_dashboard_view.dart';
import 'teacher_dashboard_view.dart';
import 'widgets/app_bottom_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserProfileResponse profile;

  const MainNavigationScreen({super.key, required this.profile});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  // Zero-rebuild ValueNotifier: Mengisolasi transisi hide/show Bottom Nav Bar
  // agar TIDAK memicu setState() ataupun me-rebuild widget tree utama saat user scrolling.
  final ValueNotifier<bool> _isNavBarVisible = ValueNotifier<bool>(true);
  BackgroundSyncService? _bgSyncService;
  late final List<ScrollController> _scrollControllers;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _scrollControllers = List.generate(5, (_) => ScrollController());
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
  /// Mencegah re-instantiation 5 halaman berat setiap kali user berpindah tab.
  /// Setiap halaman diisolasi dengan RepaintBoundary agar GPU layer tetap tersimpan di memory.
  void _buildPages() {
    _pages = [
      RepaintBoundary(
        child: _isStaffOrTeacher
            ? TeacherDashboardView(
                profile: widget.profile,
                scrollController: _scrollControllers[0],
                onNavigateTab: _handleTabTap,
              )
            : StudentDashboardView(
                profile: widget.profile,
                scrollController: _scrollControllers[0],
                onNavigateTab: _handleTabTap,
              ),
      ),
      RepaintBoundary(
        child: AttendanceScreen(
          profile: widget.profile,
          scrollController: _scrollControllers[1],
        ),
      ),
      RepaintBoundary(
        child: AcademicScreen(
          profile: widget.profile,
          scrollController: _scrollControllers[2],
        ),
      ),
      RepaintBoundary(
        child: BillingScreen(
          profile: widget.profile,
          scrollController: _scrollControllers[3],
        ),
      ),
      RepaintBoundary(
        child: ProfileScreen(
          profile: widget.profile,
          scrollController: _scrollControllers[4],
        ),
      ),
    ];
  }

  @override
  void didUpdateWidget(MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
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

  /// Smart Reselect & Tab Switching:
  /// - Jika tab lain ditekan: Pindah tab & pastikan bar navigasi tampak.
  /// - Jika tab yang sedang aktif ditekan kembali: Memicu animasi smooth Scroll-to-Top!
  void _handleTabTap(int index) {
    if (index == _currentIndex) {
      _scrollToTop(index);
    } else {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: FadeIndexedStack(
          index: _currentIndex,
          duration: const Duration(milliseconds: 200),
          children: _pages,
        ),
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
              pendingOutboxCount: pendingOutbox,
              unpaidInvoiceCount: unpaidInvoiceCount,
              isFloating: true,
            );
          },
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

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.988, end: 1.0).animate(
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
