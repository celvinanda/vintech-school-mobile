import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../academic/presentation/attendance_screen.dart';
import '../../auth/data/models/user_model.dart';
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

  @override
  void initState() {
    super.initState();
    // Load home dashboard
    context.read<HomeCubit>().loadDashboard();
  }

  Color get _schoolColor => AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);

  bool get _isTeacher => widget.profile.activeSchool?.isTeacher == true;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _isTeacher
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
