class AttendanceModel {
  final String id;
  final String date;
  final String status; // HADIR, IZIN, SAKIT, ALPA
  final String statusDisplay;
  final String notes;
  final String studentId;
  final String studentNis;
  final String studentName;
  final String? classroomName;

  AttendanceModel({
    required this.id,
    required this.date,
    required this.status,
    required this.statusDisplay,
    required this.notes,
    required this.studentId,
    required this.studentNis,
    required this.studentName,
    this.classroomName,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] as Map<String, dynamic>? ?? {};

    String? classroomName;
    final rawClassroom = json['classroom'] ?? student['classroom'];
    if (rawClassroom is Map) {
      classroomName = rawClassroom['name'] as String?;
    } else if (rawClassroom is String) {
      classroomName = rawClassroom;
    }

    return AttendanceModel(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      status: json['status'] as String? ?? 'HADIR',
      statusDisplay:
          json['status_display'] as String? ?? json['status'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      studentId: student['id'] as String? ?? '',
      studentNis:
          student['nis'] as String? ?? json['student_nis'] as String? ?? '',
      studentName:
          student['full_name'] as String? ??
          json['student_name'] as String? ??
          '',
      classroomName: classroomName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'status': status,
    'status_display': statusDisplay,
    'notes': notes,
    'student': {'id': studentId, 'nis': studentNis, 'full_name': studentName},
    'classroom': classroomName,
  };
}
