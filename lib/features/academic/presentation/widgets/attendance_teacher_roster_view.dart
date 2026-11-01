import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/empty_or_error_view.dart';
import '../../data/models/attendance_model.dart';

/// Tampilan Rekap Presensi Siswa Khusus Guru / Staf (Roster View)
/// Dilengkapi bilah pencarian, filter status kapsul, dan daftar rekaman siswa
class AttendanceTeacherRosterView extends StatelessWidget {
  final List<AttendanceModel> allRecords;
  final List<AttendanceModel> filteredRecords;
  final TextEditingController searchController;
  final String statusFilter;
  final Color schoolColor;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onSearchChanged;
  final ScrollController? scrollController;

  const AttendanceTeacherRosterView({
    super.key,
    required this.allRecords,
    required this.filteredRecords,
    required this.searchController,
    required this.statusFilter,
    required this.schoolColor,
    required this.onFilterChanged,
    required this.onSearchChanged,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final hadirCount = allRecords.where((r) => r.status == 'HADIR').length;
    final izinCount = allRecords.where((r) => r.status == 'IZIN').length;
    final sakitCount = allRecords.where((r) => r.status == 'SAKIT').length;
    final alpaCount = allRecords.where((r) => r.status == 'ALPA').length;

    return Column(
      children: [
        // Search & Filter Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                onChanged: (_) => onSearchChanged(),
                decoration: InputDecoration(
                  hintText: 'Cari nama siswa, NIS, atau kelas...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterCapsule(
                      'ALL',
                      'Semua (${allRecords.length})',
                      schoolColor,
                    ),
                    const SizedBox(width: 6),
                    _buildFilterCapsule(
                      'HADIR',
                      'Hadir ($hadirCount)',
                      const Color(0xFF007D55),
                    ),
                    const SizedBox(width: 6),
                    _buildFilterCapsule(
                      'IZIN',
                      'Izin ($izinCount)',
                      const Color(0xFF004AC6),
                    ),
                    const SizedBox(width: 6),
                    _buildFilterCapsule(
                      'SAKIT',
                      'Sakit ($sakitCount)',
                      const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 6),
                    _buildFilterCapsule(
                      'ALPA',
                      'Alpa ($alpaCount)',
                      const Color(0xFFBA1A1A),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List Records
        Expanded(
          child: filteredRecords.isEmpty
              ? const EmptyOrErrorView(
                  icon: Icons.search_off_rounded,
                  iconColor: Color(0xFF737686),
                  title: 'Tidak Ada Data Presensi',
                  subtitle: 'Tidak ditemukan rekaman presensi dengan kriteria pencarian ini.',
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredRecords.length,
                  itemBuilder: (context, index) {
                    final item = filteredRecords[index];
                    return _TeacherAttendanceCard(item: item);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterCapsule(String status, String label, Color color) {
    final isSelected = statusFilter == status;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onFilterChanged(status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class _TeacherAttendanceCard extends StatelessWidget {
  final AttendanceModel item;

  const _TeacherAttendanceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (item.status.toUpperCase()) {
      case 'HADIR':
        statusColor = const Color(0xFF007D55);
        break;
      case 'IZIN':
        statusColor = const Color(0xFF004AC6);
        break;
      case 'SAKIT':
        statusColor = const Color(0xFFD97706);
        break;
      case 'ALPA':
      default:
        statusColor = const Color(0xFFBA1A1A);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECEEF0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.studentName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF191C1E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'NIS: ${item.studentNis} • ${item.classroomName ?? "Kelas"}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF565E74),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.statusDisplay,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
