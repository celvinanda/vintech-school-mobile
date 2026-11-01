import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vintech_school_mobile/features/academic/data/models/attendance_model.dart';
import 'package:vintech_school_mobile/features/academic/presentation/attendance_entry_sheet.dart';
import 'package:vintech_school_mobile/features/auth/data/models/user_model.dart';

import '../components/teacher_class_card.dart';
import '../components/teacher_class_student_detail_sheet.dart';
import '../models/class_attendance_info.dart';

/// Tab 2 View: Status Presensi Kelas (Dedicated Full View)
class TeacherClassStatusView extends StatefulWidget {
  final UserProfileResponse profile;
  final List<AttendanceModel> allRecords;
  final Color schoolColor;
  final ScrollController? scrollController;
  final Future<void> Function() onRefresh;

  const TeacherClassStatusView({
    super.key,
    required this.profile,
    required this.allRecords,
    required this.schoolColor,
    this.scrollController,
    required this.onRefresh,
  });

  @override
  State<TeacherClassStatusView> createState() => _TeacherClassStatusViewState();
}

class _TeacherClassStatusViewState extends State<TeacherClassStatusView> {
  final TextEditingController _classSearchController = TextEditingController();
  String _classFilter = 'all'; // all, locked, pending, advisory

  @override
  void dispose() {
    _classSearchController.dispose();
    super.dispose();
  }

  String get _currentDateFormatted {
    try {
      final now = DateTime.now();
      const dayNames = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      const monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final dayName = dayNames[now.weekday - 1];
      final monthName = monthNames[now.month - 1];
      return '$dayName, ${now.day} $monthName ${now.year}';
    } catch (_) {
      return 'Senin, 17 November 2026';
    }
  }

  @override
  Widget build(BuildContext context) {
    final classList = ClassAttendanceInfo.generateDefaultList(widget.profile);
    final lockedCount = classList.where((c) => c.statusKey == 'locked').length;
    final pendingCount = classList.where((c) => c.statusKey != 'locked').length;
    final totalCount = classList.length;
    final lockPercent = totalCount > 0
        ? ((lockedCount / totalCount) * 100).round()
        : 0;

    final query = _classSearchController.text.trim().toLowerCase();
    final filtered = classList.where((c) {
      if (_classFilter == 'locked' && c.statusKey != 'locked') return false;
      if (_classFilter == 'pending' && c.statusKey == 'locked') return false;
      if (_classFilter == 'advisory' && !c.isAdvisory) return false;
      if (query.isNotEmpty) {
        final matchName = c.className.toLowerCase().contains(query);
        final matchSub = c.roomSubtitle.toLowerCase().contains(query);
        final matchBadge = c.badgeTitle.toLowerCase().contains(query);
        return matchName || matchSub || matchBadge;
      }
      return true;
    }).toList();

    return RefreshIndicator(
      color: widget.schoolColor,
      onRefresh: widget.onRefresh,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        key: const PageStorageKey('attendance_teacher_class_status_scroll'),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Row
            _buildClassSummaryKpiRow(
              totalCount: totalCount,
              lockedCount: lockedCount,
              pendingCount: pendingCount,
              lockPercent: lockPercent,
            ),
            const SizedBox(height: 14),

            // Search Bar & Filter Chips Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFECEEF0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _classSearchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Cari rombel atau guru pengajar...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFF94A3B8),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                      suffixIcon: _classSearchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _classSearchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildClassFilterChip('all', 'Semua ($totalCount)'),
                        const SizedBox(width: 8),
                        _buildClassFilterChip(
                          'locked',
                          'Sudah Terkunci ($lockedCount)',
                        ),
                        const SizedBox(width: 8),
                        _buildClassFilterChip(
                          'pending',
                          'Belum Selesai ($pendingCount)',
                        ),
                        const SizedBox(width: 8),
                        _buildClassFilterChip('advisory', 'Kelas Binaan Anda'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Section Title & Counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Status Pengisian Rombel (${filtered.length})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  _currentDateFormatted,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Class Cards List
            if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFECEEF0)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tidak ada rombel yang cocok',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Silakan sesuaikan kata kunci pencarian atau ubah filter status.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filtered.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TeacherClassCard(
                    classInfo: item,
                    schoolColor: widget.schoolColor,
                    onAction: () {
                      HapticFeedback.selectionClick();
                      if (item.statusKey == 'locked') {
                        TeacherClassStudentDetailSheet.show(
                          context,
                          classInfo: item,
                          allRecords: widget.allRecords,
                        );
                      } else if (item.statusKey == 'pending') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✓ Pesan pengingat presensi otomatis terkirim untuk ${item.className}!',
                            ),
                            backgroundColor: const Color(0xFF007D55),
                          ),
                        );
                      } else {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (_) => const AttendanceEntrySheet(),
                        );
                      }
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildClassFilterChip(String filterKey, String label) {
    final isSelected = _classFilter == filterKey;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _classFilter = filterKey);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? widget.schoolColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildClassSummaryKpiRow({
    required int totalCount,
    required int lockedCount,
    required int pendingCount,
    required int lockPercent,
  }) {
    return Row(
      children: [
        // Total Rombel
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEEF0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.meeting_room_rounded,
                        size: 14,
                        color: Color(0xFF004AC6),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Total Rombel',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$totalCount Kelas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Terjadwal hari ini',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    color: const Color(0xFF94A3B8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Sudah Terkunci
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEEF0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 14,
                        color: Color(0xFF007D55),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Terkunci',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$lockedCount ($lockPercent%)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF007D55),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '100% tervalidasi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    color: const Color(0xFF007D55),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Belum Selesai
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECEEF0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.timelapse_rounded,
                        size: 14,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Pending',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$pendingCount Kelas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Batas jam 10:00',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    color: const Color(0xFFDC2626),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
