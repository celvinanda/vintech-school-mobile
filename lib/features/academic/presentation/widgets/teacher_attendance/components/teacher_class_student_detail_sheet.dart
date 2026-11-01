import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vintech_school_mobile/features/academic/data/models/attendance_model.dart';

import '../models/class_attendance_info.dart';

/// Modal Bottom Sheet untuk melihat daftar kehadiran detail siswa dalam rombel tertentu
class TeacherClassStudentDetailSheet extends StatelessWidget {
  final ClassAttendanceInfo classInfo;
  final List<AttendanceModel> allRecords;

  const TeacherClassStudentDetailSheet({
    super.key,
    required this.classInfo,
    required this.allRecords,
  });

  static void show(
    BuildContext context, {
    required ClassAttendanceInfo classInfo,
    required List<AttendanceModel> allRecords,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TeacherClassStudentDetailSheet(
        classInfo: classInfo,
        allRecords: allRecords,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchingRecords = allRecords
        .where(
          (r) =>
              (r.classroomName ?? '').toLowerCase() ==
              classInfo.className.toLowerCase(),
        )
        .toList();

    final studentsList = matchingRecords.isNotEmpty
        ? matchingRecords
        : _generateMockStudentsForClass(classInfo);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtl) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            classInfo.className,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: classInfo.badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              classInfo.badgeTitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: classInfo.badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        classInfo.roomSubtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFECEEF0)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: const Color(0xFFF8FAFC),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniBadge(
                    'Hadir',
                    classInfo.hadirCount.toString(),
                    const Color(0xFFECFDF5),
                    const Color(0xFF007D55),
                  ),
                  _buildMiniBadge(
                    'Sakit',
                    classInfo.sakitCount.toString(),
                    const Color(0xFFFEF3C7),
                    const Color(0xFFB45309),
                  ),
                  _buildMiniBadge(
                    'Izin',
                    classInfo.izinCount.toString(),
                    const Color(0xFFEFF6FF),
                    const Color(0xFF004AC6),
                  ),
                  _buildMiniBadge(
                    'Alpa',
                    classInfo.alpaCount.toString(),
                    const Color(0xFFFEE2E2),
                    const Color(0xFFDC2626),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFECEEF0)),
            Expanded(
              child: ListView.separated(
                controller: scrollCtl,
                padding: const EdgeInsets.all(16),
                itemCount: studentsList.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, idx) {
                  final s = studentsList[idx];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFEFF6FF),
                          child: Text(
                            s.studentName.isNotEmpty ? s.studentName[0] : 'S',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF004AC6),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.studentName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'NIS: ${s.studentNis} • ${s.notes.isNotEmpty ? s.notes : "Presensi Tervalidasi"}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildClassStatusBadge(s.status),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniBadge(String label, String count, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: text,
            ),
          ),
          Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassStatusBadge(String status) {
    Color bg;
    Color fg;
    String label = status;
    switch (status.toUpperCase()) {
      case 'HADIR':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF007D55);
        break;
      case 'SAKIT':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case 'IZIN':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF004AC6);
        break;
      case 'ALPA':
      default:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  List<AttendanceModel> _generateMockStudentsForClass(
    ClassAttendanceInfo item,
  ) {
    const todayStr = '2026-11-01';
    return [
      AttendanceModel(
        id: '1',
        studentId: '101',
        studentNis: '20241001',
        studentName: 'Ahmad Raihan Pratama',
        classroomName: item.className,
        date: todayStr,
        status: 'HADIR',
        statusDisplay: 'Hadir',
        notes: 'Masuk 06:48 WIB',
      ),
      AttendanceModel(
        id: '2',
        studentId: '102',
        studentNis: '20241002',
        studentName: 'Bunga Citra Amanda',
        classroomName: item.className,
        date: todayStr,
        status: 'HADIR',
        statusDisplay: 'Hadir',
        notes: 'Masuk 06:52 WIB',
      ),
      AttendanceModel(
        id: '3',
        studentId: '103',
        studentNis: '20241003',
        studentName: 'Danang Tri Saputra',
        classroomName: item.className,
        date: todayStr,
        status: 'HADIR',
        statusDisplay: 'Hadir',
        notes: 'Masuk 06:55 WIB',
      ),
      AttendanceModel(
        id: '4',
        studentId: '104',
        studentNis: '20241004',
        studentName: 'Fajar Nugraha',
        classroomName: item.className,
        date: todayStr,
        status: item.alpaCount > 0 ? 'ALPA' : 'HADIR',
        statusDisplay: item.alpaCount > 0 ? 'Alpa' : 'Hadir',
        notes: item.alpaCount > 0 ? 'Tanpa Keterangan' : 'Masuk 07:05 WIB',
      ),
      AttendanceModel(
        id: '5',
        studentId: '105',
        studentNis: '20241005',
        studentName: 'Nabila Zahra Putri',
        classroomName: item.className,
        date: todayStr,
        status: item.sakitCount > 0 ? 'SAKIT' : 'HADIR',
        statusDisplay: item.sakitCount > 0 ? 'Sakit' : 'Hadir',
        notes: item.sakitCount > 0
            ? 'Surat Dokter Terlampir'
            : 'Masuk 06:45 WIB',
      ),
      AttendanceModel(
        id: '6',
        studentId: '106',
        studentNis: '20241006',
        studentName: 'Rizky Ramadhan',
        classroomName: item.className,
        date: todayStr,
        status: item.izinCount > 0 ? 'IZIN' : 'HADIR',
        statusDisplay: item.izinCount > 0 ? 'Izin' : 'Hadir',
        notes: item.izinCount > 0 ? 'Dispensasi LKS' : 'Masuk 07:00 WIB',
      ),
      AttendanceModel(
        id: '7',
        studentId: '107',
        studentNis: '20241007',
        studentName: 'Siti Nurhaliza',
        classroomName: item.className,
        date: todayStr,
        status: 'HADIR',
        statusDisplay: 'Hadir',
        notes: 'Masuk 06:50 WIB',
      ),
    ];
  }
}
