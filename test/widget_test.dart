import 'package:flutter_test/flutter_test.dart';
import 'package:vintech_school_mobile/features/academic/data/models/attendance_model.dart';
import 'package:vintech_school_mobile/features/academic/data/models/classroom_model.dart';
import 'package:vintech_school_mobile/features/academic/data/models/student_model.dart';
import 'package:vintech_school_mobile/features/auth/data/models/school_lookup_model.dart';
import 'package:vintech_school_mobile/features/auth/data/models/user_model.dart';
import 'package:vintech_school_mobile/features/billing/data/models/invoice_model.dart';
import 'package:vintech_school_mobile/features/home/data/models/school_dashboard_model.dart';

void main() {
  test('Hive Offline-First JSON roundtrip serialization test for all domain models', () {
    final att = AttendanceModel(
      id: 'att-100',
      date: '2026-10-25',
      status: 'HADIR',
      statusDisplay: 'Hadir',
      notes: 'Tepat waktu',
      studentId: 'std-1',
      studentNis: '20261001',
      studentName: 'Rizky Pratama',
      classroomName: 'X MIPA 1',
    );
    final attRestored = AttendanceModel.fromJson(att.toJson());
    expect(attRestored.id, 'att-100');
    expect(attRestored.studentNis, '20261001');
    expect(attRestored.classroomName, 'X MIPA 1');

    final cls = ClassroomModel(
      id: 'c-1',
      name: 'X MIPA 1',
      gradeLevel: 10,
      capacity: 36,
      studentCount: 32,
      homeroomTeacher: 'Budi Santoso, S.Pd',
    );
    final clsRestored = ClassroomModel.fromJson(cls.toJson());
    expect(clsRestored.name, 'X MIPA 1');
    expect(clsRestored.studentCount, 32);

    final dash = SchoolDashboardModel(
      id: 'sch-1',
      code: 'SMAN1',
      name: 'SMAN 1 Jakarta',
      levelDisplay: 'SMA',
      primaryColor: '#10A83D',
      totalStudents: 120,
      totalTeachers: 18,
      totalClassrooms: 6,
      currentAcademicYear: '2026/2027 Ganjil',
      attendanceToday: AttendanceTodaySummary(
        date: '2026-10-25',
        presentCount: 24,
        izinCount: 1,
        sakitCount: 0,
        alpaCount: 0,
        recordedCount: 25,
        attendanceRate: 96.0,
      ),
      announcements: [
        AnnouncementModel(
          id: 'ann-1',
          title: 'Ujian Tengah Semester',
          content: 'Jadwal UTS dimulai minggu depan.',
          audience: 'ALL',
          audienceDisplay: 'Semua',
          isPinned: true,
          createdAt: '25 Okt 2026',
        ),
      ],
    );
    final dashRestored = SchoolDashboardModel.fromJson(dash.toJson());
    expect(dashRestored.name, 'SMAN 1 Jakarta');
    expect(dashRestored.attendanceToday.attendanceRate, 96.0);
    expect(dashRestored.announcements.first.title, 'Ujian Tengah Semester');
  });

  test('StudentModel and AttendanceModel handle map or string classroom safely', () {
    final studentJson = {
      'id': 'std-1',
      'nis': '20261001',
      'full_name': 'Rizky Pratama',
      'gender': 'L',
      'classroom': {'id': 'cls-1', 'name': 'X MIPA 1'},
    };
    final student = StudentModel.fromJson(studentJson);
    expect(student.classroomName, 'X MIPA 1');

    final attJson = {
      'id': 'att-1',
      'date': '2026-10-25',
      'status': 'HADIR',
      'status_display': 'Hadir',
      'notes': 'Tepat waktu',
      'student': {
        'id': 'std-1',
        'nis': '20261001',
        'full_name': 'Rizky Pratama',
      },
      'classroom': {'name': 'X MIPA 1'},
    };
    final att = AttendanceModel.fromJson(attJson);
    expect(att.classroomName, 'X MIPA 1');
    expect(att.studentName, 'Rizky Pratama');
  });

  test('UserModel smart identifier and initials extraction test', () {
    final student = UserModel(
      id: 1,
      username: 'siswa.sman1jkt.20261001',
      fullName: 'Rizky Pratama Putra',
      email: 'rizky@sman1.sch.id',
      isSuperuser: false,
    );

    expect(student.cleanIdentifier, '20261001');
    expect(student.firstName, 'Rizky');
    expect(student.initials, 'RP');
  });

  test('Wali Kelas (Homeroom Teacher) synchronization test across User and Student models', () {
    // 1. StudentModel parses homeroom teacher from root or nested classroom map
    final s1 = StudentModel.fromJson({
      'id': 's-1',
      'nis': '20261001',
      'full_name': 'Aditya Pratama Putra',
      'gender': 'L',
      'homeroom_teacher': '  Drs. Bambang Sutrisno  ',
      'homeroom_teacher_phone': '08123456789',
      'classroom': {
        'id': 'c-1',
        'name': 'X-IPA-1',
      },
    });
    expect(s1.homeroomTeacherName, 'Drs. Bambang Sutrisno');
    expect(s1.homeroomTeacherPhone, '08123456789');

    // 2. StudentModel falls back to classroom map if root is empty string
    final s2 = StudentModel.fromJson({
      'id': 's-2',
      'nis': '20261002',
      'full_name': 'Siti Aisyah',
      'gender': 'P',
      'homeroom_teacher': '',
      'homeroom_teacher_phone': '',
      'classroom': {
        'id': 'c-1',
        'name': 'X-IPA-1',
        'homeroom_teacher': 'Drs. Bambang Sutrisno',
        'homeroom_teacher_phone': '08123456789',
      },
    });
    expect(s2.homeroomTeacherName, 'Drs. Bambang Sutrisno');
    expect(s2.homeroomTeacherPhone, '08123456789');

    // 3. UserModel and ActiveSchoolModel parse homeroom teacher fields
    final user = UserModel.fromJson({
      'id': 10,
      'username': 'siswa',
      'full_name': 'Aditya Pratama Putra',
      'email': 'siswa@vintech.cloud',
      'nis': '20261001',
      'homeroom_teacher': 'Drs. Bambang Sutrisno',
      'homeroom_teacher_phone': '08123456789',
      'homeroom_teacher_nip': '197804122005011002',
      'homeroom_teacher_specialization': 'Matematika Lanjut',
      'homeroom_teacher_email': 'bambang@vintech.cloud',
    });
    expect(user.homeroomTeacher, 'Drs. Bambang Sutrisno');
    expect(user.homeroomTeacherPhone, '08123456789');
    expect(user.homeroomTeacherNip, '197804122005011002');
    expect(user.homeroomTeacherSpecialization, 'Matematika Lanjut');
    expect(user.homeroomTeacherEmail, 'bambang@vintech.cloud');

    final activeSchool = ActiveSchoolModel.fromJson({
      'id': 'sch-1',
      'code': 'SMAN1',
      'slug': 'sman-1',
      'name': 'SMAN 1 Vintech',
      'level': 'SMA',
      'role': 'STUDENT',
      'title': 'Siswa Aktif',
      'classroom_name': 'X-IPA-1',
      'nis': '20261001',
      'homeroom_teacher': 'Drs. Bambang Sutrisno',
      'homeroom_teacher_phone': '08123456789',
      'homeroom_teacher_nip': '197804122005011002',
      'homeroom_teacher_specialization': 'Matematika Lanjut',
      'homeroom_teacher_email': 'bambang@vintech.cloud',
    });
    expect(activeSchool.homeroomTeacher, 'Drs. Bambang Sutrisno');
    expect(activeSchool.homeroomTeacherPhone, '08123456789');
    expect(activeSchool.homeroomTeacherNip, '197804122005011002');
    expect(activeSchool.homeroomTeacherSpecialization, 'Matematika Lanjut');
    expect(activeSchool.homeroomTeacherEmail, 'bambang@vintech.cloud');
  });

  test('SchoolLookupModel serialization smoke test', () {
    final json = {
      'id': 'test-1',
      'code': 'SMAN1-JKT',
      'slug': 'sman-1-nusantara',
      'name': 'SMA Negeri 1 Nusantara',
      'level': 'SMA',
      'level_display': 'SMA / MA',
      'tier': 'ENTERPRISE',
      'tier_display': 'Enterprise',
      'branding': {
        'primary_color': '#1E3A8A',
        'logo_url': null,
      },
      'vintech_payment_configured': true,
    };

    final model = SchoolLookupModel.fromJson(json);
    expect(model.code, 'SMAN1-JKT');
    expect(model.name, 'SMA Negeri 1 Nusantara');
    expect(model.primaryColor, '#1E3A8A');
    expect(model.vintechPaymentConfigured, true);
  });

  test('InvoiceModel serialization smoke test', () {
    final json = {
      'id': 'inv-1',
      'invoice_number': 'INV/202610/0001',
      'period_label': 'Oktober 2026',
      'amount': 250000,
      'amount_display': 'Rp 250.000',
      'status': 'UNPAID',
      'status_display': 'Belum Bayar',
      'vintech_payment': {
        'checkout_url': 'https://pay.vintech.cloud/checkout/INV-001',
      },
      'fee_category': {
        'name': 'SPP Bulanan',
      },
      'student': {
        'nis': '2026001',
        'full_name': 'Ahmad Fauzan',
      },
    };

    final inv = InvoiceModel.fromJson(json);
    expect(inv.invoiceNumber, 'INV/202610/0001');
    expect(inv.isUnpaid, true);
    expect(inv.isPaid, false);
    expect(inv.checkoutUrl, 'https://pay.vintech.cloud/checkout/INV-001');
  });
}
