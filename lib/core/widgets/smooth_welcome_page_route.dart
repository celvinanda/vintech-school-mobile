import 'package:flutter/material.dart';

/// Transisi Halaman Cerdas & Mewah ("Welcoming Bloom Page Route"):
/// 1. Durasi terpadu responsif (420 ms) yang menyatu tanpa lag.
/// 2. Menghormati pengaturan aksesibilitas sistem (Reduce Motion / disableAnimations).
/// 3. Micro-Scale Bloom: 0.94 -> 1.00.
/// 4. Soft Elevation Glide: Offset(0, 0.055) -> Offset.zero (~55-65px).
/// 5. Kurva dekselerasi sutra Cubic(0.12, 1.0, 0.24, 1.0).
class SmoothWelcomePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SmoothWelcomePageRoute({
    required this.child,
    Duration duration = const Duration(milliseconds: 420),
    super.settings,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final reduceMotion = MediaQuery.of(context).disableAnimations;
            if (reduceMotion) {
              return child;
            }

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: const Cubic(0.12, 1.0, 0.24, 1.0),
              reverseCurve: Curves.easeInCubic,
            );

            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.055),
              end: Offset.zero,
            ).animate(curvedAnimation);

            final scaleAnimation = Tween<double>(
              begin: 0.94,
              end: 1.0,
            ).animate(curvedAnimation);

            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
            );

            return SlideTransition(
              position: slideAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                ),
              ),
            );
          },
        );
}
