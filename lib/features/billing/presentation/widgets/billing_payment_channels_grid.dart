import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 6: Official Payment Channels 4x2 Grid (Stitch Design)
/// Menampilkan kanal pembayaran resmi: QRIS, BCA, Mandiri, BNI, GoPay, OVO, ShopeePay, Indomaret
class BillingPaymentChannelsGrid extends StatelessWidget {
  const BillingPaymentChannelsGrid({super.key});

  static const List<_ChannelItem> _channels = [
    _ChannelItem(name: 'QRIS', subtitle: 'Semua E-Wallet', color: Color(0xFF0F172A)),
    _ChannelItem(name: 'BCA', subtitle: 'Virtual Account', color: Color(0xFF004AC6)),
    _ChannelItem(name: 'Mandiri', subtitle: 'Livin\' / VA', color: Color(0xFFB45309)),
    _ChannelItem(name: 'BNI', subtitle: 'Mobile / VA', color: Color(0xFFEA580C)),
    _ChannelItem(name: 'GoPay', subtitle: 'Instant Pay', color: Color(0xFF0284C7)),
    _ChannelItem(name: 'OVO', subtitle: 'E-Wallet', color: Color(0xFF7C3AED)),
    _ChannelItem(name: 'ShopeePay', subtitle: 'App Pay', color: Color(0xFFF97316)),
    _ChannelItem(name: 'Indomaret', subtitle: 'Gerai Ritel', color: Color(0xFF0F172A)),
  ];

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFECEEF0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kanal Pembayaran Resmi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tersedia 24/7 • Bebas Antre',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_rounded,
                        size: 11,
                        color: Color(0xFF007D55),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '256-bit Enkripsi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF007D55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 4-Column Grid via 2 Rows (zero layout jumping)
            Row(
              children: [
                Expanded(child: _buildChannelTile(_channels[0])),
                const SizedBox(width: 8),
                Expanded(child: _buildChannelTile(_channels[1])),
                const SizedBox(width: 8),
                Expanded(child: _buildChannelTile(_channels[2])),
                const SizedBox(width: 8),
                Expanded(child: _buildChannelTile(_channels[3])),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildChannelTile(_channels[4])),
                const SizedBox(width: 8),
                Expanded(child: _buildChannelTile(_channels[5])),
                const SizedBox(width: 8),
                Expanded(child: _buildChannelTile(_channels[6])),
                const SizedBox(width: 8),
                Expanded(child: _buildChannelTile(_channels[7])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelTile(_ChannelItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            item.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: item.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item.subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChannelItem {
  final String name;
  final String subtitle;
  final Color color;

  const _ChannelItem({
    required this.name,
    required this.subtitle,
    required this.color,
  });
}
