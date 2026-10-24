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

  @override
  void initState() {
    super.initState();
    _fetchAttendances();
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

  Future<void> _fetchAttendances({
    String? classroomId,
    bool forceRefreshMeta = false,
  }) async {
    await context.read<AttendanceCubit>().loadAttendances(
          classroomId: classroomId,
          studentNis: _isStudent ? _myCleanNis : null,
          isStaff: _canRecordAttendance,
          forceRefreshMeta: forceRefreshMeta,
        );
  }

  List<AttendanceModel> _applyFilters(List<AttendanceModel> raw) {
    return raw.where((item) {
      // Siswa hanya melihat presensi pribadinya sendiri
      if (_isStudent) {
        if (item.studentNis.toLowerCase() != _myCleanNis.toLowerCase()) {
          return false;
        }
      }
      if (_statusFilter != 'ALL' && item.status.toUpperCase() != _statusFilter) {
        return false;
      }
      if (!_isStudent && _searchController.text.trim().isNotEmpty) {
        final query = _searchController.text.trim().toLowerCase();
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
        title: Text(_isStudent ? 'Presensi & Kedisiplinan' : 'Presensi Harian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang',
            onPressed: () => _fetchAttendances(forceRefreshMeta: true),
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
              onAction: () => _fetchAttendances(forceRefreshMeta: true),
            );
          }
          if (state is AttendanceLoaded) {
            final filtered = _applyFilters(state.attendances);

            return _isStudent
                ? _buildStudentPersonalView(context, state, filtered)
                : _buildTeacherRosterView(context, state, filtered);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ==========================================
  // TAMPILAN KHUSUS SISWA (JURNAL KEDISIPLINAN MOTIVASI)
  // ==========================================
  Widget _buildStudentPersonalView(
    BuildContext context,
    AttendanceLoaded state,
    List<AttendanceModel> personalRecords,
  ) {
    // Rekapitulasi presensi siswa
    final allMyRecords = state.attendances
        .where((r) => r.studentNis.toLowerCase() == _myCleanNis.toLowerCase())
        .toList();

    final hadirCount = allMyRecords.where((r) => r.status == 'HADIR').length;
    final izinCount = allMyRecords.where((r) => r.status == 'IZIN').length;
    final sakitCount = allMyRecords.where((r) => r.status == 'SAKIT').length;
    final alpaCount = allMyRecords.where((r) => r.status == 'ALPA').length;

    final int totalRecorded = allMyRecords.length;
    final double disciplineRate = totalRecorded > 0
        ? (hadirCount / totalRecorded) * 100
        : 100.0;

    String motivationQuote = 'Pertahankan kehadiranmu demi masa depan yang gemilang!';
    if (disciplineRate >= 95.0) {
      motivationQuote = 'Luar biasa! Kehadiranmu sangat disiplin. Pertahankan konsistensimu!';
    } else if (disciplineRate >= 80.0) {
      motivationQuote = 'Kedisiplinan adalah kunci kesuksesan belajarmu setiap hari.';
    } else {
      motivationQuote = 'Tingkatkan kehadiran di kelas untuk hasil belajar yang optimal.';
    }

    return RefreshIndicator(
      color: _schoolColor,
      onRefresh: () => _fetchAttendances(forceRefreshMeta: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          // Motivational Student Header Banner
          _buildMotivationalCard(
            disciplineRate: disciplineRate,
            quote: motivationQuote,
            hadirCount: hadirCount,
            izinCount: izinCount,
            sakitCount: sakitCount,
            alpaCount: alpaCount,
          ),

          const SizedBox(height: 20),

          // Status Filter Tabs
          Text(
            'Riwayat Kehadiran Pribadi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // Filter Capsules
          Row(
            children: [
              _buildFilterCapsule('ALL', 'Semua ($totalRecorded)', _schoolColor),
              const SizedBox(width: 6),
              _buildFilterCapsule('HADIR', 'Hadir ($hadirCount)', const Color(0xFF16A34A)),
              const SizedBox(width: 6),
              _buildFilterCapsule('IZIN', 'Izin ($izinCount)', const Color(0xFF2563EB)),
              const SizedBox(width: 6),
              _buildFilterCapsule('SAKIT', 'Sakit ($sakitCount)', const Color(0xFFD97706)),
              const SizedBox(width: 6),
              _buildFilterCapsule('ALPA', 'Alpa ($alpaCount)', const Color(0xFFDC2626)),
            ],
          ),

          const SizedBox(height: 16),

          // Timeline List of Personal Attendance
          if (personalRecords.isEmpty)
            EmptyOrErrorView(
              icon: Icons.checklist_rounded,
              iconColor: _schoolColor,
              title: 'Belum Ada Catatan',
              subtitle: _statusFilter == 'ALL'
                  ? 'Catatan presensi harian Anda akan tampil di sini begitu dicatat oleh pihak sekolah.'
                  : 'Tidak ada riwayat presensi dengan status $_statusFilter.',
              actionLabel: _statusFilter == 'ALL' ? null : 'Tampilkan Semua',
              onAction: () => setState(() => _statusFilter = 'ALL'),
            )
          else
            ...personalRecords.map((item) => _buildPersonalTimelineCard(item)),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard({
    required double disciplineRate,
    required String quote,
    required int hadirCount,
    required int izinCount,
    required int sakitCount,
    required int alpaCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            Color.lerp(const Color(0xFF0F172A), _schoolColor, 0.45)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: Color(0xFFFBBF24),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'JURNAL KEDISIPLINAN SAYA',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withAlpha(190),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withAlpha(35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withAlpha(120),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${disciplineRate.toStringAsFixed(0)}% Disiplin',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF4ADE80),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            widget.profile.user.fullName,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            quote,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withAlpha(200),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withAlpha(25)),
          const SizedBox(height: 14),

          // 4 Stat Capsules
          Row(
            children: [
              _buildPersonalStatItem('Hadir', '$hadirCount', const Color(0xFF4ADE80)),
              _buildPersonalStatItem('Izin', '$izinCount', const Color(0xFF60A5FA)),
              _buildPersonalStatItem('Sakit', '$sakitCount', const Color(0xFFFBBF24)),
              _buildPersonalStatItem('Alpa', '$alpaCount', const Color(0xFFF87171)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withAlpha(160),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTimelineCard(AttendanceModel item) {
    Color statusColor;
    IconData statusIcon;
    switch (item.status.toUpperCase()) {
      case 'HADIR':
        statusColor = const Color(0xFF16A34A);
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'IZIN':
        statusColor = const Color(0xFF2563EB);
        statusIcon = Icons.info_rounded;
        break;
      case 'SAKIT':
        statusColor = const Color(0xFFD97706);
        statusIcon = Icons.healing_rounded;
        break;
      case 'ALPA':
      default:
        statusColor = const Color(0xFFDC2626);
        statusIcon = Icons.cancel_rounded;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.date,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.notes.isNotEmpty
                          ? item.notes
                          : (item.status == 'HADIR'
                              ? 'Hadir tepat waktu di kelas'
                              : 'Keterangan tercatat di sistem'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontStyle: item.notes.isNotEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.statusDisplay,
                  style: GoogleFonts.plusJakartaSans(
                    color: statusColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAMPILAN KHUSUS GURU & ADMINISTRATOR SEKOLAH
  // ==========================================
  Widget _buildTeacherRosterView(
    BuildContext context,
    AttendanceLoaded state,
    List<AttendanceModel> filteredRecords,
  ) {
    final allRecords = state.attendances;
    final hadirCount = allRecords.where((r) => r.status == 'HADIR').length;
    final izinCount = allRecords.where((r) => r.status == 'IZIN').length;
    final sakitCount = allRecords.where((r) => r.status == 'SAKIT').length;
    final alpaCount = allRecords.where((r) => r.status == 'ALPA').length;

    return Column(
      children: [
        // Search & Filter Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Column(
            children: [
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildFilterCapsule('ALL', 'Semua (${allRecords.length})', _schoolColor),
                  const SizedBox(width: 6),
                  _buildFilterCapsule('HADIR', 'Hadir ($hadirCount)', const Color(0xFF16A34A)),
                  const SizedBox(width: 6),
                  _buildFilterCapsule('IZIN', 'Izin ($izinCount)', const Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  _buildFilterCapsule('SAKIT', 'Sakit ($sakitCount)', const Color(0xFFD97706)),
                  const SizedBox(width: 6),
                  _buildFilterCapsule('ALPA', 'Alpa ($alpaCount)', const Color(0xFFDC2626)),
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
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
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
                      onSelected: (_) => _fetchAttendances(classroomId: null),
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
                    onSelected: (_) => _fetchAttendances(classroomId: c.id),
                  ),
                );
              },
            ),
          ),

        // Teacher Roster List
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
                    });
                  },
                )
              : RefreshIndicator(
                  color: _schoolColor,
                  onRefresh: () => _fetchAttendances(
                    classroomId: state.selectedClassroomId,
                    forceRefreshMeta: true,
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
                    itemCount: filteredRecords.length,
                    itemBuilder: (context, index) {
                      final item = filteredRecords[index];
                      return _buildTeacherRosterCard(item);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTeacherRosterCard(AttendanceModel item) {
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
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
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
                    Text(
                      item.studentName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'NIS: ${item.studentNis} • ${item.classroomName ?? 'Kelas'}',
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

  Widget _buildFilterCapsule(String value, String label, Color color) {
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
}
