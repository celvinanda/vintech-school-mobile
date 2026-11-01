import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 2: Filter / Category Chips for Academic Screen
/// Menampilkan navigasi filter: Jadwal Pelajaran, Tugas & PR (badge 3), Nilai & Ujian, Materi / Modul
class AcademicTabChips extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color primaryColor;

  const AcademicTabChips({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.primaryColor = const Color(0xFF003366),
  });

  static const List<_TabItem> _tabs = [
    _TabItem(title: 'Jadwal Pelajaran', icon: Icons.schedule_rounded),
    _TabItem(
      title: 'Tugas & PR',
      icon: Icons.assignment_outlined,
      badgeCount: 3,
    ),
    _TabItem(title: 'Nilai & Ujian', icon: Icons.insights_rounded),
    _TabItem(title: 'Materi / Modul', icon: Icons.auto_stories_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _tabs.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final tab = _tabs[index];
            final isSelected = index == selectedIndex;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTabSelected(index);
                },
                borderRadius: BorderRadius.circular(22),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.icon,
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                      if (tab.badgeCount != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tab.badgeCount}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? primaryColor : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TabItem {
  final String title;
  final IconData icon;
  final int? badgeCount;

  const _TabItem({required this.title, required this.icon, this.badgeCount});
}
