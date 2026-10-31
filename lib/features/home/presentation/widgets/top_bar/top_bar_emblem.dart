import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sub-komponen 1: School Emblem & Avatar Badge
/// Menampilkan logo/emblem institusi sekolah dengan efek elevasi halus dan interaksi haptic
class TopBarEmblem extends StatelessWidget {
  final Color schoolColor;
  final VoidCallback onTap;
  final IconData icon;
  final double size;

  const TopBarEmblem({
    super.key,
    required this.schoolColor,
    required this.onTap,
    this.icon = Icons.school_rounded,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  schoolColor,
                  Color.lerp(schoolColor, Colors.black, 0.15)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: schoolColor.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                color: Colors.white,
                size: size * 0.52,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
