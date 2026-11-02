import 'package:vintech_school_mobile/features/academic/data/models/attendance_model.dart';
import 'package:flutter/material.dart';
import 'package:vintech_school_mobile/features/auth/data/models/user_model.dart';

/// Model entitas untuk status pemantauan kehadiran rombel / kelas
class ClassAttendanceInfo {
  final String className;
  final String badgeTitle;
  final Color badgeBg;
  final Color badgeTextColor;
  final String roomSubtitle;
  final String statusLabel;
  final Color statusBg;
  final Color statusTextColor;
  final IconData statusIcon;
  final String progressText;
  final String cloudSyncText;
  final int totalStudents;
  final int hadirCount;
  final int sakitCount;
  final int izinCount;
  final int alpaCount;
  final String footerNote;
  final bool isAdvisory;
  final String statusKey; // 'locked', 'pending', 'waiting'

  const ClassAttendanceInfo({
    required this.className,
    required this.badgeTitle,
    required this.badgeBg,
    required this.badgeTextColor,
    required this.roomSubtitle,
    required this.statusLabel,
    required this.statusBg,
    required this.statusTextColor,
    required this.statusIcon,
    required this.progressText,
    required this.cloudSyncText,
    required this.totalStudents,
    required this.hadirCount,
    required this.sakitCount,
    required this.izinCount,
    required this.alpaCount,
    required this.footerNote,
    this.isAdvisory = false,
    required this.statusKey,
  });

  ClassAttendanceInfo copyWith({
    String? className,
    String? badgeTitle,
    Color? badgeBg,
    Color? badgeTextColor,
    String? roomSubtitle,
    String? statusLabel,
    Color? statusBg,
    Color? statusTextColor,
    IconData? statusIcon,
    String? progressText,
    String? cloudSyncText,
    int? totalStudents,
    int? hadirCount,
    int? sakitCount,
    int? izinCount,
    int? alpaCount,
    String? footerNote,
    bool? isAdvisory,
    String? statusKey,
  }) {
    return ClassAttendanceInfo(
      className: className ?? this.className,
      badgeTitle: badgeTitle ?? this.badgeTitle,
      badgeBg: badgeBg ?? this.badgeBg,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      roomSubtitle: roomSubtitle ?? this.roomSubtitle,
      statusLabel: statusLabel ?? this.statusLabel,
      statusBg: statusBg ?? this.statusBg,
      statusTextColor: statusTextColor ?? this.statusTextColor,
      statusIcon: statusIcon ?? this.statusIcon,
      progressText: progressText ?? this.progressText,
      cloudSyncText: cloudSyncText ?? this.cloudSyncText,
      totalStudents: totalStudents ?? this.totalStudents,
      hadirCount: hadirCount ?? this.hadirCount,
      sakitCount: sakitCount ?? this.sakitCount,
      izinCount: izinCount ?? this.izinCount,
      alpaCount: alpaCount ?? this.alpaCount,
      footerNote: footerNote ?? this.footerNote,
      isAdvisory: isAdvisory ?? this.isAdvisory,
      statusKey: statusKey ?? this.statusKey,
    );
  }

  /// Factory untuk menyediakan daftar rombel default sekolah
  static List<ClassAttendanceInfo> generateDefaultList(
    UserProfileResponse profile, {
    List<AttendanceModel>? allRecords,
  }) {
    final school = profile.activeSchool;
    final advisoryName = school?.classroomNameField ?? 'XII RPL 1';
    final teacherName = profile.user.fullName;

    int realHadir = 32;
    int realSakit = 2;
    int realIzin = 1;
    int realAlpa = 1;

    if (allRecords != null && allRecords.isNotEmpty) {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final todayRecs = allRecords.where((r) => r.date == todayStr).toList();
      final targetRecs = todayRecs.isNotEmpty ? todayRecs : allRecords;

      int h = 0, s = 0, i = 0, a = 0;
      for (final r in targetRecs) {
        switch (r.status.toUpperCase()) {
          case 'HADIR':
          case 'DISPENSASI':
            h++;
            break;
          case 'SAKIT':
            s++;
            break;
          case 'IZIN':
            i++;
            break;
          case 'ALPA':
            a++;
            break;
        }
      }
      if (h + s + i + a > 0) {
        realHadir = h;
        realSakit = s;
        realIzin = i;
        realAlpa = a;
      }
    }

    return [
      ClassAttendanceInfo(
        className: advisoryName,
        badgeTitle: 'Kelas Binaan Anda',
        badgeBg: const Color(0xFFEFF6FF),
        badgeTextColor: const Color(0xFF004AC6),
        roomSubtitle: 'Wali Kelas: $teacherName • Ruang Lab RPL 1',
        statusLabel: 'Selesai 100%',
        statusBg: const Color(0xFFECFDF5),
        statusTextColor: const Color(0xFF007D55),
        statusIcon: Icons.lock_rounded,
        progressText:
            'Progress: ${realHadir + realSakit + realIzin + realAlpa} / 36 Siswa',
        cloudSyncText: 'Sinkron Cloud',
        totalStudents: 36,
        hadirCount: realHadir,
        sakitCount: realSakit,
        izinCount: realIzin,
        alpaCount: realAlpa,
        footerNote: 'Terkunci: 07:45 WIB',
        isAdvisory: true,
        statusKey: 'locked',
      ),
      const ClassAttendanceInfo(
        className: 'XII RPL 2',
        badgeTitle: 'Belum Kunci',
        badgeBg: Color(0xFFFEE2E2),
        badgeTextColor: Color(0xFFDC2626),
        roomSubtitle: 'Guru: Ibu Rina Marlina, S.Pd. • Lab RPL 2',
        statusLabel: '28 / 36 Siswa',
        statusBg: Color(0xFFF1F5F9),
        statusTextColor: Color(0xFF475569),
        statusIcon: Icons.timelapse_rounded,
        progressText: 'Tersisa 8 siswa belum diabsen',
        cloudSyncText: 'Kurang 22%',
        totalStudents: 36,
        hadirCount: 26,
        sakitCount: 1,
        izinCount: 1,
        alpaCount: 0,
        footerNote: 'Batas submit: 10:00 WIB',
        statusKey: 'pending',
      ),
      const ClassAttendanceInfo(
        className: 'XI TJKT 1',
        badgeTitle: 'Kosong (0/34)',
        badgeBg: Color(0xFFFEF3C7),
        badgeTextColor: Color(0xFFB45309),
        roomSubtitle: 'Jadwal Praktik Lab Jaringan Komputer',
        statusLabel: 'Menunggu',
        statusBg: Color(0xFFFEF2F2),
        statusTextColor: Color(0xFFDC2626),
        statusIcon: Icons.warning_amber_rounded,
        progressText: 'Belum ada presensi dimulai',
        cloudSyncText: 'Jam Ke-4',
        totalStudents: 34,
        hadirCount: 0,
        sakitCount: 0,
        izinCount: 0,
        alpaCount: 0,
        footerNote: 'Jadwal aktif sekarang',
        statusKey: 'waiting',
      ),
      const ClassAttendanceInfo(
        className: 'XI TJKT 2',
        badgeTitle: 'Terkunci',
        badgeBg: Color(0xFFF1F5F9),
        badgeTextColor: Color(0xFF475569),
        roomSubtitle: 'Guru: Bpk. Dani Gunawan, S.Kom. • Lab Fiber',
        statusLabel: 'Selesai 100%',
        statusBg: Color(0xFFECFDF5),
        statusTextColor: Color(0xFF007D55),
        statusIcon: Icons.lock_rounded,
        progressText: 'Progress: 35 / 35 Siswa',
        cloudSyncText: 'Sinkron Cloud',
        totalStudents: 35,
        hadirCount: 33,
        sakitCount: 1,
        izinCount: 1,
        alpaCount: 0,
        footerNote: 'Terkunci: 08:00 WIB',
        statusKey: 'locked',
      ),
      const ClassAttendanceInfo(
        className: 'X PPLG 1',
        badgeTitle: 'Terkunci',
        badgeBg: Color(0xFFF1F5F9),
        badgeTextColor: Color(0xFF475569),
        roomSubtitle: 'Guru: Ibu Citra Lestari, M.Kom. • Teori 01',
        statusLabel: 'Selesai 100%',
        statusBg: Color(0xFFECFDF5),
        statusTextColor: Color(0xFF007D55),
        statusIcon: Icons.lock_rounded,
        progressText: 'Progress: 36 / 36 Siswa',
        cloudSyncText: 'Sinkron Cloud',
        totalStudents: 36,
        hadirCount: 35,
        sakitCount: 1,
        izinCount: 0,
        alpaCount: 0,
        footerNote: 'Terkunci: 07:40 WIB',
        statusKey: 'locked',
      ),
      const ClassAttendanceInfo(
        className: 'X PPLG 2',
        badgeTitle: 'Belum Kunci',
        badgeBg: Color(0xFFFEE2E2),
        badgeTextColor: Color(0xFFDC2626),
        roomSubtitle: 'Guru: Bpk. Ahmad Fauzi, S.Pd. • Teori 02',
        statusLabel: '30 / 36 Siswa',
        statusBg: Color(0xFFF1F5F9),
        statusTextColor: Color(0xFF475569),
        statusIcon: Icons.timelapse_rounded,
        progressText: 'Tersisa 6 siswa belum diabsen',
        cloudSyncText: 'Kurang 16%',
        totalStudents: 36,
        hadirCount: 29,
        sakitCount: 1,
        izinCount: 0,
        alpaCount: 0,
        footerNote: 'Batas submit: 10:00 WIB',
        statusKey: 'pending',
      ),
      const ClassAttendanceInfo(
        className: 'XII DKV 1',
        badgeTitle: 'Terkunci',
        badgeBg: Color(0xFFF1F5F9),
        badgeTextColor: Color(0xFF475569),
        roomSubtitle: 'Guru: Bpk. Eko Prasetyo, S.Sn. • Studio 1',
        statusLabel: 'Selesai 100%',
        statusBg: Color(0xFFECFDF5),
        statusTextColor: Color(0xFF007D55),
        statusIcon: Icons.lock_rounded,
        progressText: 'Progress: 34 / 34 Siswa',
        cloudSyncText: 'Sinkron Cloud',
        totalStudents: 34,
        hadirCount: 32,
        sakitCount: 1,
        izinCount: 1,
        alpaCount: 0,
        footerNote: 'Terkunci: 07:50 WIB',
        statusKey: 'locked',
      ),
      const ClassAttendanceInfo(
        className: 'XI DKV 2',
        badgeTitle: 'Terkunci',
        badgeBg: Color(0xFFF1F5F9),
        badgeTextColor: Color(0xFF475569),
        roomSubtitle: 'Guru: Ibu Maya Anggraini, M.Ds. • Studio Animasi',
        statusLabel: 'Selesai 100%',
        statusBg: Color(0xFFECFDF5),
        statusTextColor: Color(0xFF007D55),
        statusIcon: Icons.lock_rounded,
        progressText: 'Progress: 32 / 32 Siswa',
        cloudSyncText: 'Sinkron Cloud',
        totalStudents: 32,
        hadirCount: 30,
        sakitCount: 1,
        izinCount: 1,
        alpaCount: 0,
        footerNote: 'Terkunci: 07:35 WIB',
        statusKey: 'locked',
      ),
    ];
  }
}
