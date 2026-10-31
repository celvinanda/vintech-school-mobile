import 'package:flutter/material.dart';

/// Transisi Halaman Cerdas & Mewah ("Welcoming Bloom Page Route"):
/// Dirancang untuk menghadirkan pengalaman visual yang hangat, lembut, dan profesional:
/// 1. Micro-Scale Bloom: Skala anggun dari 0.925 -> 1.000 (efek mekar yang jelas dan elegan).
/// 2. Soft Elevation Glide: Mengapung naik dari Offset(0.0, 0.08) -> Offset.zero (~85-95px).
/// 3. Silky Deceleration: Kurva perlambatan alami Cubic(0.05, 0.7, 0.1, 1.0) dengan durasi 650ms.
/// 4. Opacity Crossfade: Fade-in lembut 0.0 -> 1.0 yang menyatu sempurna tanpa color flash.
class SmoothWelcomePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SmoothWelcomePageRoute({
    required this.child,
    Duration duration = const Duration(milliseconds: 650),
    super.settings,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Kurva pelambatan natural khas Apple iOS & Android 14 Expressive
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: const Cubic(0.05, 0.7, 0.1, 1.0),
              reverseCurve: Curves.easeInCubic,
            );

            // 1. Soft Elevation Glide (Mengapung naik ~85-95px secara jelas dan anggun)
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.08),
              end: Offset.zero,
            ).animate(curvedAnimation);

            // 2. Micro-Scale Bloom (Sensasi mekar 7.5% yang sangat terasa di layar fisik)
            final scaleAnimation = Tween<double>(
              begin: 0.925,
              end: 1.0,
            ).animate(curvedAnimation);

            // 3. Opacity Crossfade (Selesai pada 80% perjalanan agar visual tegas dan terang)
            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.80, curve: Curves.easeOut),
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
