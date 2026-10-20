import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
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
    _nisController = TextEditingController(text: widget.initialStudentNis ?? '20261001');
  }

  void _submit() {
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
    return BlocListener<AttendanceCubit, AttendanceState>(
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
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Input Presensi Siswa',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nisController,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildStatusChip('HADIR', 'Hadir', AppTheme.success),
                  _buildStatusChip('IZIN', 'Izin', const Color(0xFF3B82F6)),
                  _buildStatusChip('SAKIT', 'Sakit', AppTheme.warning),
                  _buildStatusChip('ALPA', 'Alpa', AppTheme.danger),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan / Keterangan (Opsional)',
                  hintText: 'Contoh: Tepat waktu, Surat dokter, dll',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Simpan Presensi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String value, String label, Color color) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withAlpha(40),
      labelStyle: TextStyle(
        color: isSelected ? color : AppTheme.textMain,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? color : AppTheme.borderLight,
        width: 1.5,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatus = value;
          });
        }
      },
    );
  }
}
