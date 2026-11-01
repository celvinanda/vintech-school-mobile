import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/class_student_item.dart';

/// Dialog untuk mencatat jurnal / catatan perkembangan siswa
class AddClassNoteDialog extends StatefulWidget {
  final List<ClassStudentItem> students;
  final ValueChanged<ClassNoteItem> onNoteAdded;

  const AddClassNoteDialog({
    super.key,
    required this.students,
    required this.onNoteAdded,
  });

  static void show(
    BuildContext context, {
    required List<ClassStudentItem> students,
    required ValueChanged<ClassNoteItem> onNoteAdded,
  }) {
    showDialog(
      context: context,
      builder: (_) =>
          AddClassNoteDialog(students: students, onNoteAdded: onNoteAdded),
    );
  }

  @override
  State<AddClassNoteDialog> createState() => _AddClassNoteDialogState();
}

class _AddClassNoteDialogState extends State<AddClassNoteDialog> {
  late String _selectedStudentName;
  String _selectedCategory = 'Kedisiplinan';
  final TextEditingController _contentController = TextEditingController();

  static const List<String> _categories = [
    'Kedisiplinan',
    'Prestasi',
    'Kesehatan',
    'Umum',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStudentName = widget.students.isNotEmpty
        ? widget.students.first.name
        : 'Siswa Rombel';
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Kedisiplinan':
        return const Color(0xFFDC2626);
      case 'Prestasi':
        return const Color(0xFF059669);
      case 'Kesehatan':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF004AC6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Color(0xFF004AC6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tambah Catatan Siswa',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: const Color(0xFF94A3B8),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Select Student Dropdown
            Text(
              'Pilih Siswa',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStudentName,
                  isExpanded: true,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                  items: widget.students.map((s) {
                    return DropdownMenuItem(
                      value: s.name,
                      child: Text(
                        '${s.number}. ${s.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedStudentName = val;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Select Category
            Text(
              'Kategori Catatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                final catColor = _getCategoryColor(cat);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? catColor.withValues(alpha: 0.12)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? catColor : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected ? catColor : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Content input
            Text(
              'Isi Catatan / Uraian Kejadian',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _contentController,
              maxLines: 3,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Tuliskan keterangan detail kejadian, absensi, atau prestasi...',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF004AC6)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final text = _contentController.text.trim();
                      if (text.isEmpty) return;

                      final newNote = ClassNoteItem(
                        id: 'note_${DateTime.now().millisecondsSinceEpoch}',
                        date: 'Baru saja',
                        author: 'Wali Kelas',
                        category: _selectedCategory,
                        studentName: _selectedStudentName,
                        content: text,
                        categoryColor: _getCategoryColor(_selectedCategory),
                      );

                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      widget.onNoteAdded(newNote);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004AC6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Simpan Catatan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
