import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/class_student_item.dart';

/// Modal Bottom Sheet untuk mengelola susunan pengurus kelas (Ketua, Sekretaris, Bendahara, dll.)
class ManageOfficersSheet extends StatefulWidget {
  final List<ClassOfficerItem> currentOfficers;
  final List<ClassStudentItem> students;
  final ValueChanged<List<ClassOfficerItem>> onOfficersUpdated;

  const ManageOfficersSheet({
    super.key,
    required this.currentOfficers,
    required this.students,
    required this.onOfficersUpdated,
  });

  static void show(
    BuildContext context, {
    required List<ClassOfficerItem> currentOfficers,
    required List<ClassStudentItem> students,
    required ValueChanged<List<ClassOfficerItem>> onOfficersUpdated,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ManageOfficersSheet(
        currentOfficers: currentOfficers,
        students: students,
        onOfficersUpdated: onOfficersUpdated,
      ),
    );
  }

  @override
  State<ManageOfficersSheet> createState() => _ManageOfficersSheetState();
}

class _ManageOfficersSheetState extends State<ManageOfficersSheet> {
  late List<ClassOfficerItem> _officers;

  @override
  void initState() {
    super.initState();
    _officers = List.from(widget.currentOfficers);
  }

  void _editOfficerRole(int index) {
    final officer = _officers[index];
    if (officer.role == 'Wali Kelas') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wali Kelas ditetapkan melalui SK Kepala Sekolah.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String selectedStudentName = officer.name;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Ubah ${officer.role}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih siswa yang memegang posisi ${officer.role}:',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStudentName,
                    isExpanded: true,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                    items: widget.students.map((s) {
                      return DropdownMenuItem(
                        value: s.name,
                        child: Text('${s.number}. ${s.name}'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedStudentName = val;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final chosenStudent = widget.students.firstWhere(
                  (s) => s.name == selectedStudentName,
                  orElse: () => widget.students.first,
                );

                setState(() {
                  _officers[index] = ClassOfficerItem(
                    role: officer.role,
                    name: chosenStudent.name,
                    nisn: 'NISN: ${chosenStudent.nisn}',
                    icon: officer.icon,
                    roleColor: officer.roleColor,
                    phone: chosenStudent.phone,
                  );
                });

                Navigator.pop(ctx);
                widget.onOfficersUpdated(_officers);
                HapticFeedback.lightImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AC6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

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
                      'Kelola Pengurus Kelas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ketuk jabatan untuk mengganti siswa pemegang peran.',
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
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _officers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final officer = _officers[index];
                  final isHomeroom = officer.role == 'Wali Kelas';

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isHomeroom
                          ? const Color(0xFFF8FAFC)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(officer.icon, color: officer.roleColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                officer.role,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: officer.roleColor,
                                ),
                              ),
                              Text(
                                officer.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isHomeroom)
                          TextButton.icon(
                            icon: const Icon(Icons.edit_rounded, size: 14),
                            label: const Text('Ganti'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF004AC6),
                              textStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onPressed: () => _editOfficerRole(index),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
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
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '✓ Susunan pengurus kelas berhasil disimpan!',
                      ),
                      backgroundColor: Color(0xFF007D55),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'Selesai Mengelola Pengurus',
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
