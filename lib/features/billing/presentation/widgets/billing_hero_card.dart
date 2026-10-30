import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 2: Billing Hero Bento Card (Stitch Design)
/// Menampilkan Total Tagihan Berjalan, Status Jatuh Tempo, dan Aksi Cepat Pembayaran
class BillingHeroCard extends StatelessWidget {
  final int totalUnpaidAmount;
  final String formattedAmount;
  final int unpaidCount;
  final String dueDateText;
  final String countdownText;
  final VoidCallback onQuickPay;

  const BillingHeroCard({
    super.key,
    required this.totalUnpaidAmount,
    required this.formattedAmount,
    required this.unpaidCount,
    this.dueDateText = '15 Maret 2026',
    this.countdownText = 'Tersisa 2 Hari Lagi',
    required this.onQuickPay,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnpaid = totalUnpaidAmount > 0;

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Dark Inverse Surface
              Color(0xFF004AC6), // Stitch Royal Blue
              Color(0xFF2563EB), // Primary Container
            ],
            stops: [0.0, 0.55, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF004AC6).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Ambient Decorative Blur Circle
              Positioned(
                right: -25,
                top: -25,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),

              // Large Watermark Wallet Icon
              Positioned(
                right: 8,
                bottom: 8,
                child: IgnorePointer(
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 96,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),

              // Content Body
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Label & Status Alert Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              hasUnpaid ? 'TOTAL TAGIHAN BERJALAN' : 'STATUS PEMBAYARAN SPP',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFDBE1FF),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              hasUnpaid ? formattedAmount : 'Lunas Penuh ✓',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasUnpaid ? const Color(0xFFFBBF24) : const Color(0xFF34D399),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasUnpaid ? Icons.bolt_rounded : Icons.check_circle_rounded,
                                size: 13,
                                color: hasUnpaid ? const Color(0xFF451A03) : const Color(0xFF064E3B),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hasUnpaid ? 'Segera Bayar' : 'Bebas Tunggakan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: hasUnpaid ? const Color(0xFF451A03) : const Color(0xFF064E3B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Detail Chips
                    if (hasUnpaid) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.event_outlined,
                                  size: 13,
                                  color: Color(0xFF6FFBBE),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Jatuh Tempo: $dueDateText',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.hourglass_top_rounded,
                                  size: 13,
                                  color: Color(0xFFFDE68A),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  countdownText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            onQuickPay();
                          },
                          icon: const Icon(
                            Icons.payments_rounded,
                            size: 18,
                            color: Color(0xFF004AC6),
                          ),
                          label: Text(
                            'Bayar Sekarang',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF004AC6),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Terima kasih! Semua kewajiban SPP semester ini telah terselesaikan dengan tepat waktu.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
