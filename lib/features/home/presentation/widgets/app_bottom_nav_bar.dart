import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Komponen navigasi bawah (Curved Notch & Floating Bottom Bar) yang terinspirasi
/// dari desain modern fluid curve dengan indikator pearl dot.
/// Mendukung dua mode:
/// 1. Floating (mengambang saat user scroll): berbentuk stadium capsule dengan bayangan halus.
/// 2. Docked (menempel di bawah saat idle / tidak scroll): menempel penuh di batas layar.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color schoolColor;
  final bool isStaffOrTeacher;
  final int pendingOutboxCount;
  final int unpaidInvoiceCount;
  final bool isFloating;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.schoolColor,
    this.isStaffOrTeacher = false,
    this.pendingOutboxCount = 0,
    this.unpaidInvoiceCount = 0,
    this.isFloating = false,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;

    final effectiveBottomMargin = isFloating
        ? (bottomPadding > 0 ? bottomPadding + 6 : 16.0)
        : 0.0;
    final effectiveHorizontalMargin = isFloating ? 18.0 : 0.0;
    final effectiveHeight = isFloating
        ? 68.0
        : 68.0 + (bottomPadding > 0 ? bottomPadding : 8.0);
    final topRadius = isFloating ? 34.0 : 22.0;
    final bottomRadius = isFloating ? 34.0 : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.fromLTRB(
        effectiveHorizontalMargin,
        0,
        effectiveHorizontalMargin,
        effectiveBottomMargin,
      ),
      height: effectiveHeight,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: currentIndex.toDouble(),
          end: currentIndex.toDouble(),
        ),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        builder: (context, animatedIndex, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final tabWidth = barWidth / 4;
              final activeX = (animatedIndex + 0.5) * tabWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Custom Painted Notch & Floating Pearl Dot
                  Positioned.fill(
                    child: CustomPaint(
                      painter: NotchBarPainter(
                        activeX: activeX,
                        notchWidth: 54.0,
                        notchDepth: 14.0,
                        topRadius: topRadius,
                        bottomRadius: bottomRadius,
                        isFloating: isFloating,
                        barColor: Colors.white,
                        dotColor: schoolColor,
                        dotRadius: 5.5,
                      ),
                    ),
                  ),

                  // 2. Tab Items Row
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 68.0,
                    child: Row(
                      children: [
                        _buildTabItem(
                          index: 0,
                          currentIndex: currentIndex,
                          icon: Icons.home_outlined,
                          selectedIcon: Icons.home_rounded,
                          label: 'Beranda',
                        ),
                        _buildTabItem(
                          index: 1,
                          currentIndex: currentIndex,
                          icon: Icons.checklist_outlined,
                          selectedIcon: Icons.checklist_rounded,
                          label: isStaffOrTeacher ? 'Presensi Kelas' : 'Presensi',
                          badgeCount: pendingOutboxCount,
                          badgeColor: const Color(0xFFD97706),
                        ),
                        _buildTabItem(
                          index: 2,
                          currentIndex: currentIndex,
                          icon: Icons.account_balance_wallet_outlined,
                          selectedIcon: Icons.account_balance_wallet_rounded,
                          label: isStaffOrTeacher ? 'Keuangan' : 'Tagihan SPP',
                          badgeCount: unpaidInvoiceCount,
                          badgeColor: const Color(0xFFDC2626),
                        ),
                        _buildTabItem(
                          index: 3,
                          currentIndex: currentIndex,
                          icon: Icons.person_outline_rounded,
                          selectedIcon: Icons.person_rounded,
                          label: 'Profil',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    int badgeCount = 0,
    Color badgeColor = const Color(0xFFD97706),
  }) {
    final isSelected = index == currentIndex;

    Widget iconWidget = Icon(
      isSelected ? selectedIcon : icon,
      color: isSelected ? schoolColor : const Color(0xFF64748B),
      size: 23,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        backgroundColor: badgeColor,
        textColor: Colors.white,
        smallSize: 8,
        label: badgeCount > 1
            ? Text(
                '$badgeCount',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              )
            : null,
        child: iconWidget,
      );
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isSelected) {
            HapticFeedback.selectionClick();
            onTap(index);
          }
        },
        child: SizedBox(
          height: 68.0,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // 1. Posisi Ikon Presisi:
              // Saat TIDAK dipilih / bukan fokus: offset Offset.zero -> Tepat di titik tengah matematis (center) vertikal 68px.
              // Saat DIPILIH / fokus: meluncur naik secara halus (Offset(0, -0.28)) untuk memberi ruang teks di bawah.
              AnimatedSlide(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                offset: isSelected ? const Offset(0, -0.28) : Offset.zero,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  scale: isSelected ? 1.05 : 1.0,
                  child: iconWidget,
                ),
              ),

              // 2. Teks Label Fokus:
              // HANYA tampil untuk tab yang dipilih/fokus.
              // Untuk tab yang tidak dipilih, teks disembunyikan total (opacity: 0).
              Positioned(
                top: 41.5,
                left: 2,
                right: 2,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: isSelected ? 240 : 140),
                  curve: isSelected ? Curves.easeOutCubic : Curves.easeInCubic,
                  opacity: isSelected ? 1.0 : 0.0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    offset: isSelected ? Offset.zero : const Offset(0, 0.35),
                    child: Center(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: schoolColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter untuk menggambar bar berlekuk halus (concave scoop notch)
/// dengan bulatan indikator (pearl dot) yang mengambang di atasnya.
class NotchBarPainter extends CustomPainter {
  final double activeX;
  final double notchWidth;
  final double notchDepth;
  final double topRadius;
  final double bottomRadius;
  final bool isFloating;
  final Color barColor;
  final Color dotColor;
  final double dotRadius;

  NotchBarPainter({
    required this.activeX,
    this.notchWidth = 54.0,
    this.notchDepth = 14.0,
    required this.topRadius,
    required this.bottomRadius,
    required this.isFloating,
    this.barColor = Colors.white,
    required this.dotColor,
    this.dotRadius = 5.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rTop = topRadius;
    final rBottom = bottomRadius;
    final nw = notchWidth;
    final nd = notchDepth;

    // 1. Path kontur bar dengan lengkungan notch
    final path = Path();

    // Sudut kiri atas
    path.moveTo(0, rTop);
    path.arcToPoint(
      Offset(rTop, 0),
      radius: Radius.circular(rTop),
      clockwise: true,
    );

    // Garis lurus ke titik awal notch
    final notchStart = (activeX - nw / 2)
        .clamp(rTop, math.max(rTop, w - rTop - nw))
        .toDouble();
    final notchCenter = notchStart + nw / 2;
    final notchEnd = notchStart + nw;

    path.lineTo(notchStart, 0);

    // Lengkungan scoop kubik bezier yang sangat mulus (C1-continuous)
    final p1 = Offset(notchStart + nw * 0.28, 0);
    final p2 = Offset(notchCenter - nw * 0.22, nd);
    final pMid = Offset(notchCenter, nd);
    final p3 = Offset(notchCenter + nw * 0.22, nd);
    final p4 = Offset(notchEnd - nw * 0.28, 0);
    final p5 = Offset(notchEnd, 0);

    path.cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, pMid.dx, pMid.dy);
    path.cubicTo(p3.dx, p3.dy, p4.dx, p4.dy, p5.dx, p5.dy);

    // Garis lurus ke sudut kanan atas
    path.lineTo(w - rTop, 0);
    path.arcToPoint(
      Offset(w, rTop),
      radius: Radius.circular(rTop),
      clockwise: true,
    );

    // Garis bawah & sudut bawah
    if (rBottom > 0) {
      path.lineTo(w, h - rBottom);
      path.arcToPoint(
        Offset(w - rBottom, h),
        radius: Radius.circular(rBottom),
        clockwise: true,
      );
      path.lineTo(rBottom, h);
      path.arcToPoint(
        Offset(0, h - rBottom),
        radius: Radius.circular(rBottom),
        clockwise: true,
      );
    } else {
      // Menempel rata di dasar layar
      path.lineTo(w, h);
      path.lineTo(0, h);
    }

    path.close();

    // 2. Gambar bayangan elevasi (Ambient & Directional Drop Shadow)
    if (isFloating) {
      canvas.drawShadow(
        path,
        const Color(0xFF0F172A).withValues(alpha: 0.22),
        18.0,
        true,
      );
    } else {
      canvas.drawShadow(
        path,
        const Color(0xFF0F172A).withValues(alpha: 0.10),
        6.0,
        false,
      );
    }

    // 3. Gambar tubuh bar putih (Fill Solid)
    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, barPaint);

    // 4. Gambar garis kontur perimeter (Border Stroke) DI ATAS bar putih!
    // Memastikan kontur lengkungan notch dan batas bar selalu kontras & terlihat tajam
    final borderPaint = Paint()
      ..color = const Color(0xFFCBD5E1) // Slate-300 garis tegas presisi
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, borderPaint);

    // 4. Gambar Indikator Bulatan (Pearl Dot) di cekungan notch
    final dotCenter = Offset(notchCenter, 1.0);

    // Bayangan lembut di bawah dot
    canvas.drawCircle(
      dotCenter.translate(0, 1.2),
      dotRadius,
      Paint()
        ..color = dotColor.withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    // Isi badan dot berwarna tema sekolah
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(dotCenter, dotRadius, dotPaint);

    // Cincin putih kontras
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(dotCenter, dotRadius, ringPaint);

    // Kilau refleksi cahaya putih (specular shine) di pojok kiri atas dot
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      dotCenter.translate(-1.2, -1.2),
      dotRadius * 0.35,
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant NotchBarPainter oldDelegate) {
    return oldDelegate.activeX != activeX ||
        oldDelegate.topRadius != topRadius ||
        oldDelegate.bottomRadius != bottomRadius ||
        oldDelegate.isFloating != isFloating ||
        oldDelegate.dotColor != dotColor;
  }
}
