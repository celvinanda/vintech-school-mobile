class StudentModel {
  final String id;
  final String nis;
  final String? nisn;
  final String fullName;
  final String gender;
  final String? classroomName;
  final String? parentName;
  final String? parentPhone;
  final String? homeroomTeacherName;
  final String? homeroomTeacherPhone;
  final String? homeroomTeacherNip;
  final String? homeroomTeacherSpecialization;
  final String? homeroomTeacherEmail;

  StudentModel({
    required this.id,
    required this.nis,
    this.nisn,
    required this.fullName,
    required this.gender,
    this.classroomName,
    this.parentName,
    this.parentPhone,
    this.homeroomTeacherName,
    this.homeroomTeacherPhone,
    this.homeroomTeacherNip,
    this.homeroomTeacherSpecialization,
    this.homeroomTeacherEmail,
  });

  StudentModel copyWith({
    String? id,
    String? nis,
    String? nisn,
    String? fullName,
    String? gender,
    String? classroomName,
    String? parentName,
    String? parentPhone,
    String? homeroomTeacherName,
    String? homeroomTeacherPhone,
    String? homeroomTeacherNip,
    String? homeroomTeacherSpecialization,
    String? homeroomTeacherEmail,
  }) {
    return StudentModel(
      id: id ?? this.id,
      nis: nis ?? this.nis,
      nisn: nisn ?? this.nisn,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      classroomName: classroomName ?? this.classroomName,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      homeroomTeacherName: homeroomTeacherName ?? this.homeroomTeacherName,
      homeroomTeacherPhone: homeroomTeacherPhone ?? this.homeroomTeacherPhone,
      homeroomTeacherNip: homeroomTeacherNip ?? this.homeroomTeacherNip,
      homeroomTeacherSpecialization:
          homeroomTeacherSpecialization ?? this.homeroomTeacherSpecialization,
      homeroomTeacherEmail: homeroomTeacherEmail ?? this.homeroomTeacherEmail,
    );
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    String? classroomName;
    String? homeroomTeacherName = (json['homeroom_teacher'] as String?)?.trim();
    String? homeroomTeacherPhone = (json['homeroom_teacher_phone'] as String?)?.trim();
    String? homeroomTeacherNip = (json['homeroom_teacher_nip'] as String?)?.trim();
    String? homeroomTeacherSpecialization =
        (json['homeroom_teacher_specialization'] as String?)?.trim();
    String? homeroomTeacherEmail = (json['homeroom_teacher_email'] as String?)?.trim();

    final rawClassroom = json['classroom'];
    if (rawClassroom is Map) {
      classroomName = (rawClassroom['name'] as String?)?.trim();
      final crTeacher = (rawClassroom['homeroom_teacher'] as String?)?.trim();
      final crPhone = (rawClassroom['homeroom_teacher_phone'] as String?)?.trim();
      final crNip = (rawClassroom['homeroom_teacher_nip'] as String?)?.trim();
      final crSpec = (rawClassroom['homeroom_teacher_specialization'] as String?)?.trim();
      final crEmail = (rawClassroom['homeroom_teacher_email'] as String?)?.trim();
      if (homeroomTeacherName == null || homeroomTeacherName.isEmpty) {
        homeroomTeacherName = crTeacher;
      }
      if (homeroomTeacherPhone == null || homeroomTeacherPhone.isEmpty) {
        homeroomTeacherPhone = crPhone;
      }
      if (homeroomTeacherNip == null || homeroomTeacherNip.isEmpty) {
        homeroomTeacherNip = crNip;
      }
      if (homeroomTeacherSpecialization == null ||
          homeroomTeacherSpecialization.isEmpty) {
        homeroomTeacherSpecialization = crSpec;
      }
      if (homeroomTeacherEmail == null || homeroomTeacherEmail.isEmpty) {
        homeroomTeacherEmail = crEmail;
      }
    } else if (rawClassroom is String) {
      classroomName = rawClassroom.trim();
    }

    return StudentModel(
      id: json['id'] as String? ?? '',
      nis: json['nis'] as String? ?? '',
      nisn: json['nisn'] as String?,
      fullName: json['full_name'] as String? ?? '',
      gender: json['gender'] as String? ?? 'L',
      classroomName: classroomName,
      parentName: json['parent_name'] as String?,
      parentPhone: json['parent_phone'] as String?,
      homeroomTeacherName: homeroomTeacherName,
      homeroomTeacherPhone: homeroomTeacherPhone,
      homeroomTeacherNip: homeroomTeacherNip,
      homeroomTeacherSpecialization: homeroomTeacherSpecialization,
      homeroomTeacherEmail: homeroomTeacherEmail,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nis': nis,
    'nisn': nisn,
    'full_name': fullName,
    'gender': gender,
    'classroom': classroomName,
    'parent_name': parentName,
    'parent_phone': parentPhone,
    'homeroom_teacher': homeroomTeacherName,
    'homeroom_teacher_phone': homeroomTeacherPhone,
    'homeroom_teacher_nip': homeroomTeacherNip,
    'homeroom_teacher_specialization': homeroomTeacherSpecialization,
    'homeroom_teacher_email': homeroomTeacherEmail,
  };
}
