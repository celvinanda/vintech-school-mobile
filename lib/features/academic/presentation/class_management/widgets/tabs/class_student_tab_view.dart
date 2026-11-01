import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vintech_school_mobile/features/academic/presentation/class_management/models/class_student_item.dart';

/// Tab 1: Daftar Siswa Rombel dengan Search, Quick Filter, Atensi, dan Quick Actions
class ClassStudentTabView extends StatefulWidget {
  final List<ClassStudentItem> students;
  final ValueChanged<ClassStudentItem>? onStudentTap;
  final ValueChanged<ClassStudentItem>? onChatTap;
  final ValueChanged<ClassStudentItem>? onCallTap;

  const ClassStudentTabView({
    super.key,
    required this.students,
    this.onStudentTap,
    this.onChatTap,
    this.onCallTap,
  });

  @override
  State<ClassStudentTabView> createState() => _ClassStudentTabViewState();
}

class _ClassStudentTabViewState extends State<ClassStudentTabView> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'all'; // all, hadir, izin_sakit, atensi
  bool _sortAscending = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    final allCount = widget.students.length;
    final hadirCount = widget.students.where((s) => s.status == 'HADIR').length;
    final izinSakitCount = widget.students
        .where(
          (s) =>
              s.status == 'SAKIT' ||
              s.status == 'IZIN' ||
              s.status == 'DISPENSASI',
        )
        .length;
    final atensiCount = widget.students
        .where((s) => s.isAttention || s.status == 'ALPA')
        .length;

    var filteredList = widget.students.where((s) {
      if (_activeFilter == 'hadir' && s.status != 'HADIR') return false;
      if (_activeFilter == 'izin_sakit' &&
          s.status != 'SAKIT' &&
          s.status != 'IZIN' &&
          s.status != 'DISPENSASI') {
        return false;
      }
      if (_activeFilter == 'atensi' && !s.isAttention && s.status != 'ALPA') {
        return false;
      }
      if (query.isNotEmpty) {
        final matchName = s.name.toLowerCase().contains(query);
        final matchNisn = s.nisn.toLowerCase().contains(query);
        final matchRole = (s.roleBadge ?? '').toLowerCase().contains(query);
        return matchName || matchNisn || matchRole;
      }
      return true;
    }).toList();

    filteredList.sort((a, b) {
      final numA = int.tryParse(a.number) ?? 0;
      final numB = int.tryParse(b.number) ?? 0;
      return _sortAscending ? numA.compareTo(numB) : numB.compareTo(numA);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search & Voice/Clear Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.02),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Cari nama siswa atau NISN...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: const Color(0xFF94A3B8),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : const Icon(
                      Icons.mic_none_rounded,
                      color: Color(0xFF94A3B8),
                      size: 19,
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Quick Status Filter Pills (Horizontal Scroll)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterPill('all', 'Semua ($allCount)'),
              const SizedBox(width: 8),
              _buildFilterPill('hadir', 'Hadir ($hadirCount)'),
              const SizedBox(width: 8),
              _buildFilterPill('izin_sakit', 'Izin / Sakit ($izinSakitCount)'),
              const SizedBox(width: 8),
              _buildFilterPill(
                'atensi',
                'Atensi ($atensiCount)',
                isAlert: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Roster Header & Sort Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daftar Siswa (${filteredList.length})',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.swap_vert_rounded,
                    size: 16,
                    color: Color(0xFF004AC6),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _sortAscending ? 'Urut Absen (1-N)' : 'Urut Absen (N-1)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF004AC6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Student List
        if (filteredList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.person_search_rounded,
                  size: 44,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tidak ditemukan siswa yang cocok',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final student = filteredList[index];
              return _buildStudentCard(student);
            },
          ),
      ],
    );
  }

  Widget _buildFilterPill(
    String filterKey,
    String label, {
    bool isAlert = false,
  }) {
    final isSelected = _activeFilter == filterKey;
    Color bg;
    Color fg;
    Border? border;

    if (isSelected) {
      bg = isAlert ? const Color(0xFFDC2626) : const Color(0xFF004AC6);
      fg = Colors.white;
    } else {
      bg = Colors.white;
      fg = isAlert ? const Color(0xFFDC2626) : const Color(0xFF64748B);
      border = Border.all(
        color: isAlert ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
      );
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _activeFilter = filterKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: border,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        (isAlert
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF004AC6))
                            .withValues(alpha: 0.20),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(ClassStudentItem student) {
    final isAttention = student.isAttention || student.status == 'ALPA';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => widget.onStudentTap?.call(student),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAttention
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFE2E8F0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(15, 23, 42, 0.02),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Red left highlight indicator for Attention students
              if (isAttention) ...[
                Container(
                  width: 4,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Number Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isAttention
                      ? const Color(0xFFFEF2F2)
                      : (student.number == '01'
                            ? const Color(0xFFEFF6FF)
                            : const Color(0xFFF1F5F9)),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  student.number,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isAttention
                        ? const Color(0xFFDC2626)
                        : (student.number == '01'
                              ? const Color(0xFF004AC6)
                              : const Color(0xFF475569)),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Student Info (Name, Role Chip, NISN / Warning Subtitle)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            student.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (student.roleBadge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: student.roleBadge == 'Ketua'
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              student.roleBadge!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: student.roleBadge == 'Ketua'
                                    ? const Color(0xFF004AC6)
                                    : const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                        if (isAttention) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.priority_high_rounded,
                            size: 14,
                            color: Color(0xFFDC2626),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAttention && student.attentionNote != null
                          ? student.attentionNote!
                          : 'NISN: ${student.nisn} • ${student.gender}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isAttention
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isAttention
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Attendance % / Status Badge
              _buildAttendanceBadge(student),
              const SizedBox(width: 6),

              // Quick Action Button (Chat or Call for Attention)
              if (isAttention)
                IconButton(
                  tooltip: 'Hubungi Wali Siswa',
                  icon: const Icon(Icons.call_rounded, size: 18),
                  color: const Color(0xFFDC2626),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(7),
                    minimumSize: const Size(32, 32),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onCallTap?.call(student);
                  },
                )
              else
                IconButton(
                  tooltip: 'Kirim Pesan',
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 17),
                  color: const Color(0xFF64748B),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF8FAFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(7),
                    minimumSize: const Size(32, 32),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onChatTap?.call(student);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceBadge(ClassStudentItem student) {
    if (student.status == 'SAKIT') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Sakit',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFB45309),
          ),
        ),
      );
    }

    if (student.status == 'DISPENSASI') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Dispensasi',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
      );
    }

    final isLow = student.attendancePercent < 85;
    final bg = isLow ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);
    final fg = isLow ? const Color(0xFFDC2626) : const Color(0xFF059669);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${student.attendancePercent.toInt()}%',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
