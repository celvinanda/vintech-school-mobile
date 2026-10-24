import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_or_error_view.dart';
import '../../auth/data/models/user_model.dart';
import '../data/models/attendance_model.dart';
import '../logic/attendance_cubit.dart';
import '../logic/attendance_state.dart';
import 'attendance_entry_sheet.dart';

class AttendanceScreen extends StatefulWidget {
  final UserProfileResponse profile;

  const AttendanceScreen({super.key, required this.profile});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'ALL'; // ALL, HADIR, IZIN, SAKIT, ALPA
  bool _onlyMyAttendance = false;

  @override
  void initState() {
    super.initState();
    context.read<AttendanceCubit>().loadAttendances();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isStudent => widget.profile.activeSchool?.isStudent == true;
  bool get _canRecordAttendance =>
      widget.profile.activeSchool?.isStaffOrTeacher == true;
  Color get _schoolColor =>
      AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);
  String get _myCleanNis => widget.profile.user.cleanIdentifier;

  List<AttendanceModel> _applyLocalFilters(List<AttendanceModel> raw) {
    final query = _searchController.text.trim().toLowerCase();
    return raw.where((item) {
      if (_onlyMyAttendance && _isStudent) {
        if (item.studentNis.toLowerCase() != _myCleanNis.toLowerCase()) {
          return false;
        }
      }
      if (_statusFilter != 'ALL' && item.status.toUpperCase() != _statusFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final matchName = item.studentName.toLowerCase().contains(query);
        final matchNis = item.studentNis.toLowerCase().contains(query);
        final matchClass = (item.classroomName ?? '').toLowerCase().contains(query);
        return matchName || matchNis || matchClass;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Presensi Harian'),
        actions: [
          if (_isStudent)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: FilterChip(
                label: Text(
                  'Milik Saya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _onlyMyAttendance ? _schoolColor : const Color(0xFF475569),
                  ),
                ),
                selected: _onlyMyAttendance,
                selectedColor: _schoolColor.withAlpha(25),
                onSelected: (val) => setState(() => _onlyMyAttendance = val),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang',
            onPressed: () => context.read<AttendanceCubit>().loadAttendances(),
          ),
        ],
      ),
      floatingActionButton: _canRecordAttendance
          ? FloatingActionButton.extended(
              backgroundColor: _schoolColor,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => const AttendanceEntrySheet(),
                );
              },
              icon: const Icon(Icons.add_task_rounded, color: Colors.white),
              label: Text(
                'Input Presensi',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AttendanceError) {
            return EmptyOrErrorView(
              icon: Icons.error_outline_rounded,
              iconColor: AppTheme.danger,
              title: 'Gagal Memuat Data Presensi',
              subtitle: state.message,
              actionLabel: 'Coba Lagi',
              onAction: () => context.read<AttendanceCubit>().loadAttendances(),
            );
          }
          if (state is AttendanceLoaded) {
            final allRecords = state.attendances;
            final filteredRecords = _applyLocalFilters(allRecords);

            final hadirCount =
                allRecords.where((r) => r.status == 'HADIR').length;
            final izinCount =
                allRecords.where((r) => r.status == 'IZIN').length;
            final sakitCount =
                allRecords.where((r) => r.status == 'SAKIT').length;
            final alpaCount =
                allRecords.where((r) => r.status == 'ALPA').length;

            return Column(
              children: [
                // Top Search & Status Filter Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Column(
                    children: [
                      // Search Field
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Cari nama siswa, NIS, atau kelas...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Status Filter Capsules
                      Row(
                        children: [
                          _buildStatusPill('ALL', 'Semua (${allRecords.length})', _schoolColor),
                          const SizedBox(width: 6),
                          _buildStatusPill('HADIR', 'Hadir ($hadirCount)', const Color(0xFF16A34A)),
                          const SizedBox(width: 6),
                          _buildStatusPill('IZIN', 'Izin ($izinCount)', const Color(0xFF2563EB)),
                          const SizedBox(width: 6),
                          _buildStatusPill('SAKIT', 'Sakit ($sakitCount)', const Color(0xFFD97706)),
                          const SizedBox(width: 6),
                          _buildStatusPill('ALPA', 'Alpa ($alpaCount)', const Color(0xFFDC2626)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Classroom Horizontal Chips
                if (state.classrooms.isNotEmpty)
                  Container(
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      itemCount: state.classrooms.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isAll = state.selectedClassroomId == null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: const Text('Semua Kelas'),
                              selected: isAll,
                              selectedColor: _schoolColor.withAlpha(25),
                              labelStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: isAll ? FontWeight.w700 : FontWeight.w500,
                                color: isAll ? _schoolColor : const Color(0xFF475569),
                              ),
                              onSelected: (_) => context
                                  .read<AttendanceCubit>()
                                  .loadAttendances(classroomId: null),
                            ),
                          );
                        }
                        final c = state.classrooms[index - 1];
                        final isSelected = state.selectedClassroomId == c.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(c.name),
                            selected: isSelected,
                            selectedColor: _schoolColor.withAlpha(25),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? _schoolColor : const Color(0xFF475569),
                            ),
                            onSelected: (_) => context
                                .read<AttendanceCubit>()
                                .loadAttendances(classroomId: c.id),
                          ),
                        );
                      },
                    ),
                  ),

                // Attendance List
                Expanded(
                  child: filteredRecords.isEmpty
                      ? EmptyOrErrorView(
                          icon: Icons.fact_check_outlined,
                          title: 'Tidak Ada Data Presensi',
                          subtitle:
                              'Belum ada catatan presensi yang sesuai dengan pencarian atau filter Anda.',
                          actionLabel: 'Reset Filter',
                          onAction: () {
                            setState(() {
                              _searchController.clear();
                              _statusFilter = 'ALL';
                              _onlyMyAttendance = false;
                            });
                          },
                        )
                      : RefreshIndicator(
                          color: _schoolColor,
                          onRefresh: () => context
                              .read<AttendanceCubit>()
                              .loadAttendances(classroomId: state.selectedClassroomId),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
                            itemCount: filteredRecords.length,
                            itemBuilder: (context, index) {
                              final item = filteredRecords[index];
                              return _buildAttendanceCard(item);
                            },
                          ),
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatusPill(String value, String label, Color color) {
    final isSelected = _statusFilter == value;
    return Expanded(
      child: Material(
        color: isSelected ? color.withAlpha(22) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => setState(() => _statusFilter = value),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? color : const Color(0xFFE2E8F0),
                width: isSelected ? 1.4 : 1.0,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? color : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceModel item) {
    final bool isMe = _isStudent && item.studentNis == _myCleanNis;
    Color statusColor;
    switch (item.status.toUpperCase()) {
      case 'HADIR':
        statusColor = const Color(0xFF16A34A);
        break;
      case 'IZIN':
        statusColor = const Color(0xFF2563EB);
        break;
      case 'SAKIT':
        statusColor = const Color(0xFFD97706);
        break;
      case 'ALPA':
      default:
        statusColor = const Color(0xFFDC2626);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isMe ? _schoolColor : const Color(0xFFE2E8F0),
            width: isMe ? 1.5 : 1.0,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.status.isNotEmpty ? item.status.substring(0, 1) : 'H',
                    style: GoogleFonts.plusJakartaSans(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.studentName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: _schoolColor.withAlpha(22),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SAYA',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: _schoolColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'NIS: ${item.studentNis} • ${item.classroomName ?? 'Reguler'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.notes,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.statusDisplay,
                      style: GoogleFonts.plusJakartaSans(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.date,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
