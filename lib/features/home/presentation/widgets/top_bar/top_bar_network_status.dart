import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sub-komponen 4: Smart Offline & Sync Status Pill
/// Menampilkan indikator sinkronisasi data offline Hive ke Cloud secara real-time
class TopBarNetworkStatus extends StatelessWidget {
  final int pendingSyncCount;
  final VoidCallback? onTap;

  const TopBarNetworkStatus({
    super.key,
    required this.pendingSyncCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingSyncCount <= 0) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          if (onTap != null) {
            onTap!();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Terdapat $pendingSyncCount data presensi tersimpan di memori lokal (Hive). Akan otomatis tersinkron saat internet stabil.',
                ),
                backgroundColor: const Color(0xFFD97706),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_sync_rounded,
                size: 13,
                color: Color(0xFFB45309),
              ),
              const SizedBox(width: 4),
              Text(
                '$pendingSyncCount',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB45309),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
