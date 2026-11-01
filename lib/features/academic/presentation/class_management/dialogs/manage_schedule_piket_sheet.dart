import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/class_student_item.dart';

/// Modal Bottom Sheet untuk mengatur Jadwal Pelajaran & Piket Kebersihan
class ManageSchedulePiketSheet extends StatefulWidget {
  final List<ClassStudentItem> students;

  const ManageSchedulePiketSheet({super.key, required this.students});

  static void show(
    BuildContext context, {
    required List<ClassStudentItem> students,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ManageSchedulePiketSheet(students: students),
    );
  }

  @override
  State<ManageSchedulePiketSheet> createState() =>
      _ManageSchedulePiketSheetState();
}

class _ManageSchedulePiketSheetState extends State<ManageSchedulePiketSheet> {
  int _activeSection = 0; // 0 = Piket Kebersihan, 1 = Jadwal Pelajaran
  String _selectedDay = 'Senin';
  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atur Jadwal & Piket Kelas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Konfigurasi jadwal piket harian dan sesi pelajaran.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: const Color(0xFF94A3B8),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segmented switch: Piket vs Mapel
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _activeSection = 0);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: _activeSection == 0
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _activeSection == 0
                              ? const [
                                  BoxShadow(
                                    color: Color.fromRGBO(15, 23, 42, 0.05),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Piket Kebersihan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: _activeSection == 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _activeSection == 0
                                ? const Color(0xFF004AC6)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _activeSection = 1);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: _activeSection == 1
                              ? Colors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _activeSection == 1
                              ? const [
                                  BoxShadow(
                                    color: Color.fromRGBO(15, 23, 42, 0.05),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Jadwal Mapel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: _activeSection == 1
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: _activeSection == 1
                                ? const Color(0xFF004AC6)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Day chips selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _days.map((day) {
                  final isSelected = _selectedDay == day;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedDay = day);
                        }
                      },
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                      ),
                      selectedColor: const Color(0xFF004AC6),
                      backgroundColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF004AC6)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Content preview based on section
            if (_activeSection == 0) ...[
              Text(
                'Petugas Piket Hari $_selectedDay',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tercatat 4 siswa bertugas. Guru dapat merotasi atau menambahkan petugas cadangan.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.person_add_rounded, size: 16),
                      label: const Text('Tambah / Rotasi Petugas Piket'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF004AC6)),
                        foregroundColor: const Color(0xFF004AC6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✓ Roster piket $_selectedDay berhasil diselaraskan!',
                            ),
                            backgroundColor: const Color(0xFF007D55),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Penyesuaian Jadwal Mapel $_selectedDay',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sinkronisasi otomatis dengan server kurikulum sekolah.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.sync_rounded, size: 16),
                      label: const Text('Sinkronkan dengan Jadwal Kurikulum'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF004AC6)),
                        foregroundColor: const Color(0xFF004AC6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              '✓ Jadwal kurikulum telah terverifikasi sinkron!',
                            ),
                            backgroundColor: Color(0xFF007D55),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004AC6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Tutup Pengaturan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
