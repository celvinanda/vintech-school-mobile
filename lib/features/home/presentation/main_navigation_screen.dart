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
  bool _isNavBarVisible = true;
  BackgroundSyncService? _bgSyncService;
  late final List<ScrollController> _scrollControllers;

  @override
  void initState() {
    super.initState();
    _scrollControllers = List.generate(5, (_) => ScrollController());

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

  @override
  void dispose() {
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
        _isNavBarVisible = true;
      });
    }
  }

  void _scrollToTop(int index) {
    if (!_isNavBarVisible) {
      setState(() => _isNavBarVisible = true);
    }
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

  /// Smart Scroll-Aware Behavior:
  /// - Auto-Hide saat scroll ke bawah (>60px & delta > 6px) untuk membaca immersive.
  /// - Snap-Up saat scroll ke atas (delta < -6px) atau kembali ke atas (<30px).
  /// - Memastikan bar selalu muncul saat mencapai tepi halaman (top/bottom).
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is ScrollUpdateNotification) {
        final pixels = notification.metrics.pixels;
        final delta = notification.scrollDelta ?? 0.0;

        if (pixels <= 30.0) {
          if (!_isNavBarVisible) {
            setState(() => _isNavBarVisible = true);
          }
        } else if (delta > 6.0 && _isNavBarVisible && pixels > 60.0) {
          setState(() => _isNavBarVisible = false);
        } else if (delta < -6.0 && !_isNavBarVisible) {
          setState(() => _isNavBarVisible = true);
        }
      } else if (notification is ScrollEndNotification) {
        if (notification.metrics.pixels <= 30.0 ||
            notification.metrics.pixels >= notification.metrics.maxScrollExtent - 24.0) {
          if (!_isNavBarVisible) {
            setState(() => _isNavBarVisible = true);
          }
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final billingState = context.watch<BillingCubit>().state;
    final unpaidInvoiceCount = billingState is BillingLoaded
        ? billingState.invoices.where((inv) => !inv.isPaid).length
        : 0;

    final List<Widget> pages = [
      _isStaffOrTeacher
          ? TeacherDashboardView(
              profile: widget.profile,
              scrollController: _scrollControllers[0],
              onNavigateTab: (index) {
                setState(() => _currentIndex = index);
              },
            )
          : StudentDashboardView(
              profile: widget.profile,
              scrollController: _scrollControllers[0],
              onNavigateTab: (index) {
                setState(() => _currentIndex = index);
              },
            ),
      AttendanceScreen(
        profile: widget.profile,
        scrollController: _scrollControllers[1],
      ),
      AcademicScreen(
        profile: widget.profile,
        scrollController: _scrollControllers[2],
      ),
      BillingScreen(
        profile: widget.profile,
        scrollController: _scrollControllers[3],
      ),
      ProfileScreen(
        profile: widget.profile,
        scrollController: _scrollControllers[4],
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        offset: _isNavBarVisible ? Offset.zero : const Offset(0, 1.3),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          opacity: _isNavBarVisible ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !_isNavBarVisible,
            child: AppBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _handleTabTap,
              schoolColor: _schoolColor,
              isStaffOrTeacher: _isStaffOrTeacher,
              pendingOutboxCount: context.watch<LocalStorage>().hive.totalPendingOutbox,
              unpaidInvoiceCount: unpaidInvoiceCount,
              isFloating: true,
            ),
          ),
        ),
      ),
    );
  }
}
