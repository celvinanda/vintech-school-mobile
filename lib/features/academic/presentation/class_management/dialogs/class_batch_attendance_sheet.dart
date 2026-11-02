import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vintech_school_mobile/features/academic/logic/attendance_cubit.dart';
import 'package:vintech_school_mobile/features/academic/presentation/widgets/teacher_attendance/models/class_attendance_info.dart';

import '../models/class_student_item.dart';

/// Modal Bottom Sheet untuk pengisian presensi cepat 1 rombel sekaligus (Batch Attendance)
class ClassBatchAttendanceSheet extends StatefulWidget {
  final ClassAttendanceInfo classInfo;
  final List<ClassStudentItem> students;
  final VoidCallback onSaved;

  const ClassBatchAttendanceSheet({
    super.key,
    required this.classInfo,
    required this.students,
    required this.onSaved,
  });

  static void show(
    BuildContext context, {
    required ClassAttendanceInfo classInfo,
    required List<ClassStudentItem> students,
    required VoidCallback onSaved,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ClassBatchAttendanceSheet(
        classInfo: classInfo,
        students: students,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<ClassBatchAttendanceSheet> createState() =>
      _ClassBatchAttendanceSheetState();
}

class _ClassBatchAttendanceSheetState extends State<ClassBatchAttendanceSheet> {
  late Map<String, String>
  _statuses; // student_nis -> 'HADIR' | 'SAKIT' | 'IZIN' | 'ALPA'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _statuses = {for (final s in widget.students) s.nisn: s.status};
  }

  int get _hadirCount =>
      _statuses.values.where((v) => v == 'HADIR' || v == 'DISPENSASI').length;
  int get _sakitCount => _statuses.values.where((v) => v == 'SAKIT').length;
  int get _izinCount => _statuses.values.where((v) => v == 'IZIN').length;
  int get _alpaCount => _statuses.values.where((v) => v == 'ALPA').length;

  void _markAllHadir() {
    HapticFeedback.lightImpact();
    setState(() {
      for (final key in _statuses.keys) {
        _statuses[key] = 'HADIR';
      }
    });
  }

  Future<void> _submitBatch() async {
    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final List<Map<String, String>> payload = widget.students.map((s) {
      final status = _statuses[s.nisn] ?? 'HADIR';
      return {
        'student_nis': s.nisn,
        'status': status,
        'notes': 'Presensi Rombel ${widget.classInfo.className}',
      };
    }).toList();

    await context.read<AttendanceCubit>().recordBatchAttendance(
      records: payload,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      widget.onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Header title & Mark All button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Presensi Rombel • ${widget.classInfo.className}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tandai kehadiran ${widget.students.length} siswa secara massal.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.done_all_rounded, size: 16),
                  label: const Text('Semua Hadir'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF007D55),
                    backgroundColor: const Color(0xFFECFDF5),
                    textStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _markAllHadir,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Live KPI Counter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildKpiChip(
                    'Hadir',
                    '$_hadirCount',
                    const Color(0xFF059669),
                  ),
                  _buildKpiChip(
                    'Sakit',
                    '$_sakitCount',
                    const Color(0xFFD97706),
                  ),
                  _buildKpiChip('Izin', '$_izinCount', const Color(0xFF004AC6)),
                  _buildKpiChip('Alpa', '$_alpaCount', const Color(0xFFDC2626)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Student list with 4 status selector buttons per row
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.52,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.students.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final s = widget.students[index];
                  final currentStatus = _statuses[s.nisn] ?? 'HADIR';

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        // Number
                        Container(
                          width: 24,
                          alignment: Alignment.center,
                          child: Text(
                            s.number,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Student name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                s.nisn,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Segmented selection (H, S, I, A)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatusPill(
                              s.nisn,
                              'H',
                              'HADIR',
                              currentStatus,
                              const Color(0xFF059669),
                            ),
                            const SizedBox(width: 4),
                            _buildStatusPill(
                              s.nisn,
                              'S',
                              'SAKIT',
                              currentStatus,
                              const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 4),
                            _buildStatusPill(
                              s.nisn,
                              'I',
                              'IZIN',
                              currentStatus,
                              const Color(0xFF004AC6),
                            ),
                            const SizedBox(width: 4),
                            _buildStatusPill(
                              s.nisn,
                              'A',
                              'ALPA',
                              currentStatus,
                              const Color(0xFFDC2626),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded, size: 18),
                label: Text(
                  _isSubmitting
                      ? 'Menyimpan Presensi...'
                      : 'Simpan Presensi Rombel (${widget.students.length} Siswa)',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitBatch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiChip(String label, String count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          count,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(
    String studentNis,
    String label,
    String statusKey,
    String currentStatus,
    Color activeColor,
  ) {
    final isSelected = currentStatus == statusKey;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _statuses[studentNis] = statusKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
