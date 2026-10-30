import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/data/models/user_model.dart';
import '../data/models/school_dashboard_model.dart';

enum NotificationCategory {
  all,
  akademik,
  presensi,
  spp,
  pengumuman,
}

class NotificationItemData {
  final String id;
  final String title;
  final String description;
  final String time;
  final String badgeText;
  final Color badgeBg;
  final Color badgeTextColor;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final NotificationCategory category;
  final String groupSection; // 'Hari Ini', 'Kemarin', 'Minggu Ini'
  final String? actionButtonText;
  final VoidCallback? onAction;
  bool isUnread;

  NotificationItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.category,
    required this.groupSection,
    this.actionButtonText,
    this.onAction,
    this.isUnread = false,
  });
}

/// Halaman Khusus Notifikasi Siswa selaras 1:1 dengan Google Stitch ("Notifikasi Siswa").
/// Fitur:
/// - Header dengan tombol Kembali, Judul, dan tombol "Tandai Sudah Dibaca"
/// - Pusat Aktivitas Strip dengan badge jumlah unread dan info institusi sekolah
/// - Filter Chips Interaktif: Semua, Akademik, Presensi, Tagihan SPP, Pengumuman
/// - Group Feed berdasarkan timeline (Hari Ini, Kemarin, Minggu Ini)
/// - Card Notifikasi lengkap dengan badge kategori, unread indicator dot, dan quick action
class StudentNotificationsScreen extends StatefulWidget {
  final UserProfileResponse profile;
  final Color schoolColor;
  final List<AnnouncementModel>? announcements;

  const StudentNotificationsScreen({
    super.key,
    required this.profile,
    required this.schoolColor,
    this.announcements,
  });

  @override
  State<StudentNotificationsScreen> createState() => _StudentNotificationsScreenState();
}

class _StudentNotificationsScreenState extends State<StudentNotificationsScreen> {
  NotificationCategory _selectedCategory = NotificationCategory.all;
  late List<NotificationItemData> _items;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    _items = [
      // --- HARI INI ---
      NotificationItemData(
        id: '1',
        title: 'Tugas Fisika: Gerak Lurus',
        description:
            'Batas pengumpulan tugas sampai hari ini pukul 23:59 WIB. Jangan lupa unggah berkas dalam format PDF.',
        time: '10 menit lalu',
        badgeText: 'Penting',
        badgeBg: const Color(0xFFFFDAD6),
        badgeTextColor: const Color(0xFF93000A),
        icon: Icons.assignment_rounded,
        iconColor: const Color(0xFF004AC6),
        iconBg: const Color(0xFFDBE1FF),
        category: NotificationCategory.akademik,
        groupSection: 'Hari Ini',
        actionButtonText: 'Kirim',
        onAction: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Membuka detail pengumpulan tugas Fisika...'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        isUnread: true,
      ),
      NotificationItemData(
        id: '2',
        title: 'Presensi Masuk Berhasil',
        description:
            'Tercatat hadir tepat waktu pukul 07:15 WIB di Gerbang Utama ${widget.profile.activeSchool?.name ?? "Sekolah"}.',
        time: '07:15 WIB',
        badgeText: 'Kehadiran Tepat Waktu',
        badgeBg: const Color(0xFFE6E8EA),
        badgeTextColor: const Color(0xFF434655),
        icon: Icons.verified_rounded,
        iconColor: const Color(0xFF007D55),
        iconBg: const Color(0xFF6FFBBE).withValues(alpha: 0.35),
        category: NotificationCategory.presensi,
        groupSection: 'Hari Ini',
        isUnread: false,
      ),

      // --- KEMARIN ---
      NotificationItemData(
        id: '3',
        title: 'Tagihan SPP Bulan Maret 2026',
        description:
            'Batas pembayaran SPP jatuh tempo pada 10 Maret 2026. Lakukan pembayaran via Virtual Account atau loket TU.',
        time: 'Kemarin, 14:00 WIB',
        badgeText: 'Tagihan',
        badgeBg: const Color(0xFFDAE2FD),
        badgeTextColor: const Color(0xFF003EA8),
        icon: Icons.payments_rounded,
        iconColor: const Color(0xFF004AC6),
        iconBg: const Color(0xFFDAE2FD),
        category: NotificationCategory.spp,
        groupSection: 'Kemarin',
        actionButtonText: 'Bayar Sekarang',
        onAction: () {
          Navigator.pop(context); // Kembali ke dashboard untuk navigasi tab SPP
        },
        isUnread: true,
      ),
      NotificationItemData(
        id: '4',
        title: 'Pendaftaran Coding & Robotik',
        description:
            'Pendaftaran kuota tersisa 8 siswa. Segera daftarkan diri melalui portal Vintech School sebelum kuota terpenuhi.',
        time: 'Kemarin, 09:30 WIB',
        badgeText: 'Ekstrakurikuler',
        badgeBg: const Color(0xFFF2F4F6),
        badgeTextColor: const Color(0xFF434655),
        icon: Icons.campaign_rounded,
        iconColor: const Color(0xFF004AC6),
        iconBg: const Color(0xFFDAE2FD),
        category: NotificationCategory.pengumuman,
        groupSection: 'Kemarin',
        isUnread: false,
      ),

      // --- MINGGU INI ---
      NotificationItemData(
        id: '5',
        title: 'Jadwal PTS Genap 2026 Diterbitkan',
        description:
            'Jadwal lengkap ujian Penilaian Tengah Semester sudah dapat diunduh di tab Akademik portal siswa.',
        time: '3 hari lalu',
        badgeText: 'Ujian Sekolah',
        badgeBg: const Color(0xFFDAE2FD),
        badgeTextColor: const Color(0xFF3F465C),
        icon: Icons.calendar_month_rounded,
        iconColor: const Color(0xFF004AC6),
        iconBg: const Color(0xFFB4C5FF).withValues(alpha: 0.4),
        category: NotificationCategory.akademik,
        groupSection: 'Minggu Ini',
        isUnread: false,
      ),
    ];

    // Jika ada announcements dinamis dari backend API, masukkan ke dalam feed
    if (widget.announcements != null && widget.announcements!.isNotEmpty) {
      for (final ann in widget.announcements!) {
        _items.insert(
          0,
          NotificationItemData(
            id: 'ann_${ann.id}',
            title: ann.title,
            description: ann.content,
            time: ann.createdAt.length >= 10 ? ann.createdAt.substring(0, 10) : ann.createdAt,
            badgeText: ann.isPinned ? 'Penting' : ann.audienceDisplay,
            badgeBg: ann.isPinned ? const Color(0xFFFFDAD6) : const Color(0xFFDBE1FF),
            badgeTextColor: ann.isPinned ? const Color(0xFF93000A) : const Color(0xFF00174B),
            icon: Icons.campaign_rounded,
            iconColor: widget.schoolColor,
            iconBg: widget.schoolColor.withValues(alpha: 0.12),
            category: NotificationCategory.pengumuman,
            groupSection: 'Hari Ini',
            isUnread: ann.isPinned,
          ),
        );
      }
    }
  }

  int get _unreadCount => _items.where((e) => e.isUnread).length;

  List<NotificationItemData> get _filteredItems {
    if (_selectedCategory == NotificationCategory.all) {
      return _items;
    }
    return _items.where((e) => e.category == _selectedCategory).toList();
  }

  void _markAllAsRead() {
    HapticFeedback.mediumImpact();
    setState(() {
      for (var item in _items) {
        item.isUnread = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah ditandai sudah dibaca.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _dismissItem(NotificationItemData item) {
    HapticFeedback.selectionClick();
    setState(() {
      _items.removeWhere((e) => e.id == item.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final schoolName = widget.profile.activeSchool?.name ?? 'Vintech School';
    final filtered = _filteredItems;
    final sections = ['Hari Ini', 'Kemarin', 'Minggu Ini'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB), // Stitch Surface
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top App Bar (Stitch Header)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFECEEF0), width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF191C1E)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Notifikasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF191C1E),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: _unreadCount > 0 ? _markAllAsRead : null,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF004AC6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.done_all_rounded, size: 18),
                        label: Text(
                          'Tandai Dibaca',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Meta / Status Overview Strip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Pusat Aktivitas',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF191C1E),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: _unreadCount > 0
                                    ? const Color(0xFF004AC6)
                                    : const Color(0xFFECEEF0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$_unreadCount Baru',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _unreadCount > 0
                                      ? Colors.white
                                      : const Color(0xFF565E74),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 15,
                              color: Color(0xFF007D55),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              schoolName,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: const Color(0xFF565E74),
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Interactive Category Filter Chips (Horizontal Scroll)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'Semua',
                            category: NotificationCategory.all,
                            count: _items.length,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Akademik',
                            category: NotificationCategory.akademik,
                            icon: Icons.menu_book_rounded,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Presensi',
                            category: NotificationCategory.presensi,
                            icon: Icons.how_to_reg_rounded,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Tagihan SPP',
                            category: NotificationCategory.spp,
                            icon: Icons.account_balance_wallet_rounded,
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            label: 'Pengumuman',
                            category: NotificationCategory.pengumuman,
                            icon: Icons.campaign_rounded,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Empty State or Grouped Feed
                    if (filtered.isEmpty)
                      _buildEmptyState()
                    else
                      ...sections.map((sec) {
                        final sectionItems = filtered.where((e) => e.groupSection == sec).toList();
                        if (sectionItems.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section Header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      if (sec == 'Hari Ini')
                                        Container(
                                          width: 7,
                                          height: 7,
                                          margin: const EdgeInsets.only(right: 6),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF004AC6),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      Text(
                                        sec.toUpperCase(),
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF434655),
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${sectionItems.length} Pemberitahuan',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: const Color(0xFF565E74),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Items
                            ...sectionItems.map((item) => _buildNotificationCard(item)),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),

                    const SizedBox(height: 24),

                    // Friendly Institutional Footer Notice (Stitch Footer)
                    Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF004AC6)),
                              const SizedBox(width: 5),
                              Text(
                                'Menampilkan notifikasi 30 hari terakhir',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: const Color(0xFF565E74),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sistem Informasi Akademik Terpadu • Vintech School',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF737686),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required NotificationCategory category,
    int? count,
    IconData? icon,
  }) {
    final isSelected = _selectedCategory == category;

    return Material(
      color: isSelected ? const Color(0xFF004AC6) : const Color(0xFFECEEF0),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? Colors.white : const Color(0xFF434655),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF434655),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFCBD5E1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : const Color(0xFF191C1E),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItemData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(item.icon, color: item.iconColor, size: 22),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row + Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF191C1E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6.5,
                              height: 6.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF004AC6),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'dismiss') _dismissItem(item);
                        if (val == 'read') {
                          setState(() {
                            item.isUnread = false;
                          });
                        }
                      },
                      icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF565E74)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      itemBuilder: (context) => [
                        if (item.isUnread)
                          const PopupMenuItem(
                            value: 'read',
                            child: Text('Tandai sudah dibaca'),
                          ),
                        const PopupMenuItem(
                          value: 'dismiss',
                          child: Text('Hapus dari daftar'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Description
                Text(
                  item.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF434655),
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Footer Row: Badge & Timestamp & Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.badgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.badgeText,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: item.badgeTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF565E74)),
                            const SizedBox(width: 3),
                            Text(
                              item.time,
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                color: const Color(0xFF565E74),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (item.actionButtonText != null)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          if (item.onAction != null) item.onAction!();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF004AC6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                item.actionButtonText!,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFECEEF0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_rounded,
              size: 36,
              color: Color(0xFF737686),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak Ada Notifikasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF191C1E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Belum ada pemberitahuan baru pada kategori ini. Tetap periksa secara berkala untuk update sekolah.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF565E74),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
