import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/background_sync_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/update/ota_update_service.dart';
import '../../academic/data/academic_repository.dart';
import '../../academic/logic/attendance_cubit.dart';
import '../../academic/presentation/attendance_screen.dart';
import '../../auth/data/models/user_model.dart';
import '../../billing/logic/billing_cubit.dart';
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
  bool _isFloating = false;
  Timer? _scrollIdleTimer;
  BackgroundSyncService? _bgSyncService;

  @override
  void initState() {
    super.initState();
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
    _scrollIdleTimer?.cancel();
    _bgSyncService?.dispose();
    super.dispose();
  }

  /// Menangani status scroll: saat pengguna menggulir layar, nav bar mengambang.
  /// Saat berhenti scroll (idle) atau saat berada di posisi teratas, nav bar mendarat kembali.
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollStartNotification) {
      if (!_isFloating) {
        setState(() => _isFloating = true);
      }
      _scrollIdleTimer?.cancel();
    } else if (notification is ScrollUpdateNotification) {
      if (notification.scrollDelta != null && notification.scrollDelta!.abs() > 0.6) {
        if (!_isFloating) {
          setState(() => _isFloating = true);
        }
        _scrollIdleTimer?.cancel();
        // Mendarat kembali setelah jeda idle 1.3 detik tanpa aktivitas scroll
        _scrollIdleTimer = Timer(const Duration(milliseconds: 1300), () {
          if (mounted && _isFloating) {
            setState(() => _isFloating = false);
          }
        });
      }
      // Jika scroll mencapai puncak teratas (posisi semula)
      if (notification.metrics.pixels <= 2) {
        _scrollIdleTimer?.cancel();
        if (_isFloating) {
          setState(() => _isFloating = false);
        }
      }
    } else if (notification is ScrollEndNotification) {
      _scrollIdleTimer?.cancel();
      _scrollIdleTimer = Timer(const Duration(milliseconds: 900), () {
        if (mounted && _isFloating) {
          setState(() => _isFloating = false);
        }
      });
      if (notification.metrics.pixels <= 2) {
        _scrollIdleTimer?.cancel();
        if (_isFloating) {
          setState(() => _isFloating = false);
        }
      }
    } else if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.idle) {
        _scrollIdleTimer?.cancel();
        _scrollIdleTimer = Timer(const Duration(milliseconds: 900), () {
          if (mounted && _isFloating) {
            setState(() => _isFloating = false);
          }
        });
      } else {
        if (!_isFloating) {
          setState(() => _isFloating = true);
        }
        _scrollIdleTimer?.cancel();
      }
    }

    return false;
  }

  Color get _schoolColor => AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);

  bool get _isStaffOrTeacher => widget.profile.activeSchool?.isStaffOrTeacher == true;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _isStaffOrTeacher
          ? TeacherDashboardView(
              profile: widget.profile,
              onNavigateTab: (index) {
                _scrollIdleTimer?.cancel();
                setState(() {
                  _currentIndex = index;
                  _isFloating = false;
                });
              },
            )
          : StudentDashboardView(
              profile: widget.profile,
              onNavigateTab: (index) {
                _scrollIdleTimer?.cancel();
                setState(() {
                  _currentIndex = index;
                  _isFloating = false;
                });
              },
            ),
      AttendanceScreen(profile: widget.profile),
      BillingScreen(profile: widget.profile),
      ProfileScreen(profile: widget.profile),
    ];

    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (idx) {
          _scrollIdleTimer?.cancel();
          setState(() {
            _currentIndex = idx;
            _isFloating = false;
          });
        },
        schoolColor: _schoolColor,
        isStaffOrTeacher: _isStaffOrTeacher,
        pendingOutboxCount: context.watch<LocalStorage>().hive.totalPendingOutbox,
        isFloating: _isFloating,
      ),
    );
  }
}
