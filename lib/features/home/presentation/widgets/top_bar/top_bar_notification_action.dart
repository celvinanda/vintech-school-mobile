import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sub-komponen 3: Smart Notification Bell Action Button
/// Menampilkan tombol lonceng notifikasi dengan badge unread dinamis dan feedback haptic
class TopBarNotificationAction extends StatelessWidget {
  final VoidCallback onTap;
  final int unreadCount;
  final bool hasUnread;
  final Color badgeColor;

  const TopBarNotificationAction({
    super.key,
    required this.onTap,
    this.unreadCount = 0,
    this.hasUnread = true,
    this.badgeColor = const Color(0xFFDC2626),
  });

  @override
  Widget build(BuildContext context) {
    final showBadge = unreadCount > 0 || hasUnread;

    return RepaintBoundary(
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          customBorder: const CircleBorder(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFECEEF0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF475569),
                  size: 21,
                ),
                if (showBadge)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: unreadCount > 1
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              '$unreadCount',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
