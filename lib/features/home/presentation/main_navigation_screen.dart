import 'package:flutter/material.dart';
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

class MainNavigationScreen extends StatefulWidget {
  final UserProfileResponse profile;

  const MainNavigationScreen({super.key, required this.profile});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
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
    _bgSyncService?.dispose();
    super.dispose();
  }

  Color get _schoolColor => AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);

  bool get _isStaffOrTeacher => widget.profile.activeSchool?.isStaffOrTeacher == true;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _isStaffOrTeacher
          ? TeacherDashboardView(
              profile: widget.profile,
              onNavigateTab: (index) => setState(() => _currentIndex = index),
            )
          : StudentDashboardView(
              profile: widget.profile,
              onNavigateTab: (index) => setState(() => _currentIndex = index),
            ),
      AttendanceScreen(profile: widget.profile),
      BillingScreen(profile: widget.profile),
      ProfileScreen(profile: widget.profile),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: NavigationBar(
          height: 65,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedIndex: _currentIndex,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          indicatorColor: _schoolColor.withAlpha(25),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, size: 22),
              selectedIcon: Icon(Icons.home_rounded, color: _schoolColor, size: 22),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: const Icon(Icons.checklist_outlined, size: 22),
              selectedIcon: Icon(Icons.checklist_rounded, color: _schoolColor, size: 22),
              label: 'Presensi',
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 22),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: _schoolColor, size: 22),
              label: 'Tagihan SPP',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded, size: 22),
              selectedIcon: Icon(Icons.person_rounded, color: _schoolColor, size: 22),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
