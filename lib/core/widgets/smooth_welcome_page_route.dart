import 'package:flutter/material.dart';

/// Transisi Halaman Cerdas & Mewah ("Welcoming Bloom Page Route"):
/// Dirancang untuk menghadirkan pengalaman visual yang hangat, lembut, dan profesional:
/// 1. Micro-Scale Bloom: Skala halus dari 0.965 -> 1.000 (efek mekar lembut).
/// 2. Soft Elevation Glide: Geser vertikal mikro dari 0.04 -> 0.00 (mengapung ke atas).
/// 3. Crossfade Halus: Opacity 0.0 -> 1.0 dengan kurva perlambatan alami Cubic(0.16, 1.0, 0.3, 1.0).
/// 4. Zero Background Flicker: Menjaga warna latar belakang tetap solid dan harmonis.
class SmoothWelcomePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SmoothWelcomePageRoute({
    required this.child,
    Duration duration = const Duration(milliseconds: 550),
    super.settings,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 380),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Kurva pelambatan natural (Silky Expressive Deceleration)
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: const Cubic(0.16, 1.0, 0.3, 1.0),
              reverseCurve: Curves.easeInCubic,
            );

            // 1. Soft Elevation Glide (Mengapung lembut 28-32px ke posisi semula)
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.0, 0.04),
              end: Offset.zero,
            ).animate(curvedAnimation);

            // 2. Micro-Scale Bloom (Sensasi kedalaman ruang yang elegan)
            final scaleAnimation = Tween<double>(
              begin: 0.968,
              end: 1.0,
            ).animate(curvedAnimation);

            // 3. Opacity Crossfade (Selesai pada 85% perjalanan agar visual tegas)
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
