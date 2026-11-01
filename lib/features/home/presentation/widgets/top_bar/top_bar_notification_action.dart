import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sub-komponen: Smart Notification Bell Action Button
/// Menampilkan ikon lonceng notifikasi minimalis dan bersih (langsung icon tanpa card/border circle)
/// dilengkapi badge unread dinamis dan feedback haptic.
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
        color: Colors.transparent,
        child: InkResponse(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          radius: 22,
          highlightShape: BoxShape.circle,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF334155),
                  size: 24,
                ),
                if (showBadge)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: unreadCount > 1
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
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
                            width: 8.5,
                            height: 8.5,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
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
