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
