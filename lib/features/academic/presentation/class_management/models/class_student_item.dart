import 'package:flutter/material.dart';
import 'package:vintech_school_mobile/features/academic/data/models/attendance_model.dart';
import 'package:vintech_school_mobile/features/academic/data/models/student_model.dart';
import 'package:vintech_school_mobile/features/academic/presentation/widgets/teacher_attendance/models/class_attendance_info.dart';

/// Model representasi data siswa dalam Manajemen Kelas
class ClassStudentItem {
  final String id;
  final String number;
  final String name;
  final String? roleBadge; // 'Ketua', 'Sekretaris', 'Bendahara', dll
  final String nis;
  final String nisn;
  final String gender;
  final double attendancePercent;
  final String status; // 'HADIR', 'SAKIT', 'IZIN', 'DISPENSASI', 'ALPA'
  final bool isAttention;
  final String? attentionNote;
  final String? phone;
  final String? parentPhone;

  const ClassStudentItem({
    required this.id,
    required this.number,
    required this.name,
    this.roleBadge,
    this.nis = '',
    required this.nisn,
    required this.gender,
    required this.attendancePercent,
    required this.status,
    this.isAttention = false,
    this.attentionNote,
    this.phone,
    this.parentPhone,
  });

  /// Identifier NIS utama untuk API (fallback ke NISN jika kosong)
  String get effectiveNis => nis.isNotEmpty ? nis : nisn;

  /// Factory untuk memetakan data riil StudentModel & AttendanceModel dari server
  static List<ClassStudentItem> fromRealData({
    required List<StudentModel> students,
    required List<AttendanceModel> attendances,
    required ClassAttendanceInfo info,
  }) {
    if (students.isEmpty) return generateListForClass(info);

    return List.generate(students.length, (index) {
      final s = students[index];
      final matchingAtts = attendances
          .where((a) => a.studentNis == s.nis)
          .toList();
      final latestAtt = matchingAtts.isNotEmpty ? matchingAtts.first : null;
      final rawStatus = latestAtt?.status.toUpperCase() ?? 'HADIR';

      String status = rawStatus;
      if (status != 'HADIR' &&
          status != 'SAKIT' &&
          status != 'IZIN' &&
          status != 'DISPENSASI' &&
          status != 'ALPA') {
        status = 'HADIR';
      }

      final isAttention = status == 'ALPA';
      final role = index == 0
          ? 'Ketua'
          : (index == 1 ? 'Sekretaris' : (index == 2 ? 'Bendahara' : null));

      return ClassStudentItem(
        id: s.id.isNotEmpty ? s.id : 'std_',
        number: (index + 1).toString().padLeft(2, '0'),
        name: s.fullName.isNotEmpty ? s.fullName : 'Siswa ',
        roleBadge: role,
        nis: s.nis,
        nisn: s.nisn?.isNotEmpty == true ? s.nisn! : s.nis,
        gender: s.gender == 'P' ? 'Perempuan' : 'Laki-laki',
        attendancePercent: isAttention ? 82 : (status == 'HADIR' ? 100 : 96),
        status: status,
        isAttention: isAttention,
        attentionNote: latestAtt?.notes.isNotEmpty == true
            ? latestAtt!.notes
            : (isAttention ? 'Tercatat Alpa • Butuh Perhatian' : null),
        phone: s.parentPhone,
        parentPhone: s.parentPhone ?? '0812-9876-5432',
      );
    });
  }

  /// Factory untuk menghasilkan data siswa realistis berdasarkan konteks rombel
  static List<ClassStudentItem> generateListForClass(ClassAttendanceInfo info) {
    return [
      const ClassStudentItem(
        id: 'std_01',
        number: '01',
        name: 'Muhammad Rizky Pratama',
        roleBadge: 'Ketua',
        nisn: '0068192841',
        gender: 'Laki-laki',
        attendancePercent: 100,
        status: 'HADIR',
        phone: '081234567801',
        parentPhone: '081298765401',
      ),
      const ClassStudentItem(
        id: 'std_02',
        number: '02',
        name: 'Adinda Putri Lestari',
        roleBadge: 'Sekretaris',
        nisn: '0068192842',
        gender: 'Perempuan',
        attendancePercent: 98,
        status: 'HADIR',
        phone: '081234567802',
        parentPhone: '081298765402',
      ),
      const ClassStudentItem(
        id: 'std_03',
        number: '03',
        name: 'Bagas Surya Pratama',
        roleBadge: 'Bendahara',
        nisn: '0068192843',
        gender: 'Laki-laki',
        attendancePercent: 94,
        status: 'SAKIT',
        phone: '081234567803',
        parentPhone: '081298765403',
      ),
      const ClassStudentItem(
        id: 'std_04',
        number: '04',
        name: 'Dimas Anggara',
        roleBadge: null,
        nisn: '0068192844',
        gender: 'Laki-laki',
        attendancePercent: 96,
        status: 'DISPENSASI',
        attentionNote: 'Dispensasi LKS',
        phone: '081234567804',
        parentPhone: '081298765404',
      ),
      ClassStudentItem(
        id: 'std_05',
        number: '05',
        name: 'Fajar Nugraha',
        roleBadge: null,
        nisn: '0068192845',
        gender: 'Laki-laki',
        attendancePercent: 82,
        status: info.alpaCount > 0 ? 'ALPA' : 'HADIR',
        isAttention: true,
        attentionNote: 'Alpa 3x • Butuh Perhatian',
        phone: '081234567805',
        parentPhone: '081298765405',
      ),
      const ClassStudentItem(
        id: 'std_06',
        number: '06',
        name: 'Siti Nurhaliza',
        roleBadge: null,
        nisn: '0068192846',
        gender: 'Perempuan',
        attendancePercent: 99,
        status: 'HADIR',
        phone: '081234567806',
        parentPhone: '081298765406',
      ),
      const ClassStudentItem(
        id: 'std_07',
        number: '07',
        name: 'Ahmad Faisal Arifin',
        roleBadge: 'Sie Kebersihan',
        nisn: '0068192847',
        gender: 'Laki-laki',
        attendancePercent: 97,
        status: 'HADIR',
        phone: '081234567807',
        parentPhone: '081298765407',
      ),
      const ClassStudentItem(
        id: 'std_08',
        number: '08',
        name: 'Cantika Dewi Maharani',
        roleBadge: null,
        nisn: '0068192848',
        gender: 'Perempuan',
        attendancePercent: 95,
        status: 'IZIN',
        phone: '081234567808',
        parentPhone: '081298765408',
      ),
      const ClassStudentItem(
        id: 'std_09',
        number: '09',
        name: 'Galih Wicaksono',
        roleBadge: 'Sie Keamanan',
        nisn: '0068192849',
        gender: 'Laki-laki',
        attendancePercent: 100,
        status: 'HADIR',
        phone: '081234567809',
        parentPhone: '081298765409',
      ),
      const ClassStudentItem(
        id: 'std_10',
        number: '10',
        name: 'Hana Putri Kirana',
        roleBadge: null,
        nisn: '0068192850',
        gender: 'Perempuan',
        attendancePercent: 98,
        status: 'HADIR',
        phone: '081234567810',
        parentPhone: '081298765410',
      ),
    ];
  }
}

/// Model Pengurus Kelas
class ClassOfficerItem {
  final String role;
  final String name;
  final String nisn;
  final IconData icon;
  final Color roleColor;
  final String? phone;

  const ClassOfficerItem({
    required this.role,
    required this.name,
    required this.nisn,
    required this.icon,
    required this.roleColor,
    this.phone,
  });

  static List<ClassOfficerItem> generateDefaultOfficers(String teacherName) {
    return [
      ClassOfficerItem(
        role: 'Wali Kelas',
        name: teacherName,
        nisn: 'NIP: 198802142011011002',
        icon: Icons.school_rounded,
        roleColor: const Color(0xFF004AC6),
        phone: '081122334455',
      ),
      const ClassOfficerItem(
        role: 'Ketua Kelas',
        name: 'Muhammad Rizky Pratama',
        nisn: 'NISN: 0068192841',
        icon: Icons.stars_rounded,
        roleColor: Color(0xFF004AC6),
        phone: '081234567801',
      ),
      const ClassOfficerItem(
        role: 'Wakil Ketua Kelas',
        name: 'Aditya Surya Wardhana',
        nisn: 'NISN: 0068192839',
        icon: Icons.shield_rounded,
        roleColor: Color(0xFF2563EB),
        phone: '081234567839',
      ),
      const ClassOfficerItem(
        role: 'Sekretaris 1',
        name: 'Adinda Putri Lestari',
        nisn: 'NISN: 0068192842',
        icon: Icons.edit_note_rounded,
        roleColor: Color(0xFF059669),
        phone: '081234567802',
      ),
      const ClassOfficerItem(
        role: 'Bendahara 1',
        name: 'Bagas Surya Pratama',
        nisn: 'NISN: 0068192843',
        icon: Icons.account_balance_wallet_rounded,
        roleColor: Color(0xFFD97706),
        phone: '081234567803',
      ),
      const ClassOfficerItem(
        role: 'Sie Kebersihan',
        name: 'Ahmad Faisal Arifin',
        nisn: 'NISN: 0068192847',
        icon: Icons.cleaning_services_rounded,
        roleColor: Color(0xFF0284C7),
        phone: '081234567807',
      ),
      const ClassOfficerItem(
        role: 'Sie Keamanan',
        name: 'Galih Wicaksono',
        nisn: 'NISN: 0068192849',
        icon: Icons.security_rounded,
        roleColor: Color(0xFF475569),
        phone: '081234567809',
      ),
    ];
  }
}

/// Model Jadwal Pelajaran
class ClassScheduleItem {
  final String day;
  final String period;
  final String time;
  final String subject;
  final String teacher;
  final String room;

  const ClassScheduleItem({
    required this.day,
    required this.period,
    required this.time,
    required this.subject,
    required this.teacher,
    required this.room,
  });

  static List<ClassScheduleItem> generateScheduleForClass(String day) {
    if (day == 'Senin') {
      return const [
        ClassScheduleItem(
          day: 'Senin',
          period: 'Jam 1 - 2',
          time: '07:15 - 08:35',
          subject: 'Upacara & Wali Kelas',
          teacher: 'Wali Kelas & Pembina',
          room: 'Lapangan Utama',
        ),
        ClassScheduleItem(
          day: 'Senin',
          period: 'Jam 3 - 5',
          time: '08:35 - 10:45',
          subject: 'Pemrograman Web & Mobile',
          teacher: 'Dani Hermawan, S.Kom',
          room: 'Lab Komputer RPL 1',
        ),
        ClassScheduleItem(
          day: 'Senin',
          period: 'Jam 6 - 8',
          time: '11:00 - 13:15',
          subject: 'Basis Data Terdistribusi',
          teacher: 'Ibu Rina Marlina, S.Pd',
          room: 'Lab Komputer RPL 2',
        ),
        ClassScheduleItem(
          day: 'Senin',
          period: 'Jam 9 - 10',
          time: '13:45 - 15:05',
          subject: 'Matematika Terapan',
          teacher: 'Bpk. Agus Salim, M.Pd',
          room: 'Ruang Teori 12',
        ),
      ];
    } else if (day == 'Selasa') {
      return const [
        ClassScheduleItem(
          day: 'Selasa',
          period: 'Jam 1 - 4',
          time: '07:00 - 09:40',
          subject: 'Rekayasa Perangkat Lunak',
          teacher: 'Dani Hermawan, S.Kom',
          room: 'Lab Komputer RPL 1',
        ),
        ClassScheduleItem(
          day: 'Selasa',
          period: 'Jam 5 - 7',
          time: '10:00 - 12:00',
          subject: 'Bahasa Inggris Kejuruan',
          teacher: 'Miss Sarah Johnson, M.Hum',
          room: 'Ruang Teori 12',
        ),
        ClassScheduleItem(
          day: 'Selasa',
          period: 'Jam 8 - 10',
          time: '12:45 - 14:45',
          subject: 'Produk Kreatif & Kewirausahaan',
          teacher: 'Drs. Bambang Sudiro',
          room: 'Lab Kreatif',
        ),
      ];
    } else {
      return const [
        ClassScheduleItem(
          day: 'Rabu',
          period: 'Jam 1 - 4',
          time: '07:00 - 09:40',
          subject: 'Pemodelan Perangkat Lunak',
          teacher: 'Dani Hermawan, S.Kom',
          room: 'Lab RPL 1',
        ),
        ClassScheduleItem(
          day: 'Rabu',
          period: 'Jam 5 - 8',
          time: '10:00 - 12:45',
          subject: 'Keamanan Siber & Jaringan',
          teacher: 'Ir. Hendra Wijaya',
          room: 'Lab Jaringan TJKT',
        ),
      ];
    }
  }
}

/// Model Piket Harian
class ClassPiketItem {
  final String day;
  final List<String> studentNames;

  const ClassPiketItem({required this.day, required this.studentNames});

  static List<ClassPiketItem> generatePiketList() {
    return const [
      ClassPiketItem(
        day: 'Senin',
        studentNames: [
          'Muhammad Rizky Pratama',
          'Adinda Putri Lestari',
          'Bagas Surya Pratama',
          'Dimas Anggara',
        ],
      ),
      ClassPiketItem(
        day: 'Selasa',
        studentNames: [
          'Fajar Nugraha',
          'Siti Nurhaliza',
          'Ahmad Faisal Arifin',
          'Cantika Dewi Maharani',
        ],
      ),
      ClassPiketItem(
        day: 'Rabu',
        studentNames: [
          'Galih Wicaksono',
          'Hana Putri Kirana',
          'Indra Lesmana',
          'Jihan Almira',
        ],
      ),
      ClassPiketItem(
        day: 'Kamis',
        studentNames: [
          'Kevin Sanjaya',
          'Lestari Wulandari',
          'Maulana Malik',
          'Nadia Safitri',
        ],
      ),
      ClassPiketItem(
        day: 'Jumat',
        studentNames: [
          'Oki Setiawan',
          'Putri Amelia',
          'Raditya Pratama',
          'Syifa Azzahra',
        ],
      ),
    ];
  }
}

/// Model Catatan Guru & Log Perkembangan Kelas
class ClassNoteItem {
  final String id;
  final String date;
  final String author;
  final String category; // 'Kedisiplinan', 'Prestasi', 'Kesehatan', 'Umum'
  final String studentName;
  final String content;
  final Color categoryColor;

  const ClassNoteItem({
    required this.id,
    required this.date,
    required this.author,
    required this.category,
    required this.studentName,
    required this.content,
    required this.categoryColor,
  });

  static List<ClassNoteItem> generateDefaultNotes() {
    return [
      const ClassNoteItem(
        id: 'note_1',
        date: 'Hari ini • 08:15 WIB',
        author: 'Dani Hermawan, S.Kom',
        category: 'Kedisiplinan',
        studentName: 'Fajar Nugraha',
        content: 'Tercatat alpa 3 kali beruntun. Sudah dikoordinasikan dengan Guru BK untuk pemanggilan orang tua.',
        categoryColor: Color(0xFFDC2626),
      ),
      const ClassNoteItem(
        id: 'note_2',
        date: 'Kemarin • 13:40 WIB',
        author: 'Dani Hermawan, S.Kom',
        category: 'Prestasi',
        studentName: 'Muhammad Rizky Pratama',
        content: 'Meraih Juara 1 Lomba Web Design tingkat Provinsi mewakili SMK Vintech.',
        categoryColor: Color(0xFF059669),
      ),
      const ClassNoteItem(
        id: 'note_3',
        date: '28 Okt 2026 • 09:10 WIB',
        author: 'Ibu Rina Marlina, S.Pd',
        category: 'Kesehatan',
        studentName: 'Bagas Surya Pratama',
        content:
            'Izin istirahat di UKS karena demam saat jam praktik Basis Data.',
        categoryColor: Color(0xFFD97706),
      ),
    ];
  }
}
