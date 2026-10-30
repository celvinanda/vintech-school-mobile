import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card 3: Dedicated Student Virtual Account Card (Stitch Design)
/// Menampilkan nomor Virtual Account tetap siswa untuk transfer cepat BCA & Mandiri dengan verifikasi otomatis
class BillingVirtualAccountCard extends StatefulWidget {
  final String studentNis;

  const BillingVirtualAccountCard({
    super.key,
    required this.studentNis,
  });

  @override
  State<BillingVirtualAccountCard> createState() => _BillingVirtualAccountCardState();
}

class _BillingVirtualAccountCardState extends State<BillingVirtualAccountCard> {
  bool _isCopied = false;

  String get _vaNumber {
    final cleanNis = widget.studentNis.replaceAll(RegExp(r'\D'), '');
    final paddedNis = cleanNis.isEmpty ? '20261001' : cleanNis;
    return '8271 $paddedNis 88';
  }

  String get _rawVaNumber {
    return _vaNumber.replaceAll(' ', '');
  }

  Future<void> _handleCopy() async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _rawVaNumber));
    setState(() => _isCopied = true);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Nomor Virtual Account $_rawVaNumber berhasil disalin!'),
          backgroundColor: const Color(0xFF007D55),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCopied = false);
      }
    });
  }

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
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title & Auto-Settled Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.credit_card_rounded,
                      color: Color(0xFF004AC6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Virtual Account Siswa',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
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
                        Icons.verified_rounded,
                        size: 12,
                        color: Color(0xFF007D55),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Otomatis Lunas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF007D55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // VA Number Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor Rekening VA (BCA & Mandiri)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _vaNumber,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Material(
                    color: _isCopied ? const Color(0xFF007D55) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: _handleCopy,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isCopied ? Icons.check_rounded : Icons.content_copy_rounded,
                              size: 14,
                              color: _isCopied ? Colors.white : const Color(0xFF004AC6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isCopied ? 'Tersalin' : 'Salin',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _isCopied ? Colors.white : const Color(0xFF004AC6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Helpful note
            Text(
              'Pembayaran via transfer VA langsung diverifikasi sistem sekolah dalam waktu < 60 detik tanpa perlu unggah struk manual.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
