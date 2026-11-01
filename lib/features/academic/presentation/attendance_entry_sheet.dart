import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../data/models/student_model.dart';
import '../logic/attendance_cubit.dart';
import '../logic/attendance_state.dart';

class AttendanceEntrySheet extends StatefulWidget {
  final String? initialStudentNis;

  const AttendanceEntrySheet({super.key, this.initialStudentNis});

  @override
  State<AttendanceEntrySheet> createState() => _AttendanceEntrySheetState();
}

class _AttendanceEntrySheetState extends State<AttendanceEntrySheet> {
  late final TextEditingController _nisController;
  final TextEditingController _notesController = TextEditingController();
  String _selectedStatus = 'HADIR';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nisController = TextEditingController(
      text: widget.initialStudentNis ?? '20261001',
    );
  }

  @override
  void dispose() {
    _nisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AttendanceCubit>().recordAttendance(
        studentNis: _nisController.text.trim(),
        status: _selectedStatus,
        notes: _notesController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceCubit, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceActionSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.success,
            ),
          );
        } else if (state is AttendanceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      },
      builder: (context, state) {
        final List<StudentModel> students = state is AttendanceLoaded
            ? state.students
            : const [];

        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.defaultPrimary.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.edit_calendar_rounded,
                              color: AppTheme.defaultPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Input Presensi Siswa',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quick Student Picker Chips if students are loaded
                  if (students.isNotEmpty) ...[
                    Text(
                      'Pilih Siswa Cepat:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: students.length > 10 ? 10 : students.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final s = students[idx];
                          final isSelected =
                              _nisController.text.trim() == s.nis;
                          return ActionChip(
                            backgroundColor: isSelected
                                ? AppTheme.defaultPrimary.withAlpha(25)
                                : const Color(0xFFF8FAFC),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.defaultPrimary
                                  : const Color(0xFFE2E8F0),
                            ),
                            label: Text(
                              '${s.fullName.split(' ').first} (${s.nis})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppTheme.defaultPrimary
                                    : const Color(0xFF334155),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _nisController.text = s.nis;
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  TextFormField(
                    controller: _nisController,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nomor Induk Siswa (NIS)',
                      hintText: 'Contoh: 20261001',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'NIS siswa wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Status Kehadiran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusOption(
                        'HADIR',
                        'Hadir',
                        const Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusOption(
                        'IZIN',
                        'Izin',
                        const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusOption(
                        'SAKIT',
                        'Sakit',
                        const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusOption(
                        'ALPA',
                        'Alpa',
                        const Color(0xFFDC2626),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan / Keterangan (Opsional)',
                      hintText: 'Contoh: Tepat waktu, Izin lomba, Surat dokter',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _submit,
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                      ),
                      label: const Text('Simpan Presensi'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(String value, String label, Color color) {
    final isSelected = _selectedStatus == value;
    return Expanded(
      child: Material(
        color: isSelected ? color.withAlpha(25) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _selectedStatus = value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? color : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
