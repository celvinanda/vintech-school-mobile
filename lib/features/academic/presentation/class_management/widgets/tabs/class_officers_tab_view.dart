import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vintech_school_mobile/features/academic/presentation/class_management/models/class_student_item.dart';

/// Tab 2: Struktur Organisasi dan Pengurus Kelas
class ClassOfficersTabView extends StatelessWidget {
  final List<ClassOfficerItem> officers;
  final ValueChanged<ClassOfficerItem>? onContactTap;

  const ClassOfficersTabView({
    super.key,
    required this.officers,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Struktur Pengurus Kelas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
            Text(
              'Periode 2026/2027',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: officers.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final officer = officers[index];
            final isHomeroom = officer.role == 'Wali Kelas';

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHomeroom ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isHomeroom
                      ? const Color(0xFFBFDBFE)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(15, 23, 42, 0.02),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: officer.roleColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      officer.icon,
                      color: officer.roleColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: officer.roleColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            officer.role,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: officer.roleColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          officer.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          officer.nisn,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kontak Pengurus',
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    color: officer.roleColor,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: officer.roleColor.withValues(alpha: 0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(7),
                      minimumSize: const Size(32, 32),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onContactTap?.call(officer);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
