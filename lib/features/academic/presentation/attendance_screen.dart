import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/models/user_model.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<AttendanceCubit>().loadAttendances();
  }

  bool get _canRecordAttendance {
    final role = widget.profile.activeSchool?.role ?? '';
    return role == 'TEACHER' || role == 'SCHOOL_ADMIN' || role == 'SUPERADMIN';
  }

  Color get _schoolColor => AppTheme.parseHexColor(widget.profile.activeSchool?.primaryColor);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Harian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => const AttendanceEntrySheet(),
                );
              },
              icon: const Icon(Icons.add_task_rounded, color: Colors.white),
              label: const Text('Input Presensi', style: TextStyle(color: Colors.white)),
            )
          : null,
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AttendanceError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppTheme.danger, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<AttendanceCubit>().loadAttendances(),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is AttendanceLoaded) {
            final records = state.attendances;

            return Column(
              children: [
                // Class filter chips if classrooms available
                if (state.classrooms.isNotEmpty)
                  SizedBox(
                    height: 52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: state.classrooms.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          final isAll = state.selectedClassroomId == null;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: const Text('Semua Kelas'),
                              selected: isAll,
                              selectedColor: _schoolColor.withAlpha(40),
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
                          child: FilterChip(
                            label: Text(c.name),
                            selected: isSelected,
                            selectedColor: _schoolColor.withAlpha(40),
                            onSelected: (_) => context
                                .read<AttendanceCubit>()
                                .loadAttendances(classroomId: c.id),
                          ),
                        );
                      },
                    ),
                  ),

                Expanded(
                  child: records.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fact_check_outlined,
                                size: 54,
                                color: AppTheme.textMuted.withAlpha(100),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada catatan presensi.',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => context.read<AttendanceCubit>().loadAttendances(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final item = records[index];
                              Color statusColor;
                              switch (item.status) {
                                case 'HADIR':
                                  statusColor = AppTheme.success;
                                  break;
                                case 'IZIN':
                                  statusColor = const Color(0xFF3B82F6);
                                  break;
                                case 'SAKIT':
                                  statusColor = AppTheme.warning;
                                  break;
                                case 'ALPA':
                                default:
                                  statusColor = AppTheme.danger;
                                  break;
                              }

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.borderLight),
                                ),
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
                                          item.status.substring(0, 1),
                                          style: GoogleFonts.plusJakartaSans(
                                            color: statusColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
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
                                              color: AppTheme.textMain,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'NIS: ${item.studentNis} • ${item.classroomName ?? 'Kelas'}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                          if (item.notes.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              item.notes,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: statusColor.withAlpha(20),
                                            borderRadius: BorderRadius.circular(6),
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
                                        const SizedBox(height: 4),
                                        Text(
                                          item.date,
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppTheme.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
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
}
