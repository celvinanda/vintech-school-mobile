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
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    String? classroomName;
    String? homeroomTeacherName = json['homeroom_teacher'] as String?;
    String? homeroomTeacherPhone = json['homeroom_teacher_phone'] as String?;

    final rawClassroom = json['classroom'];
    if (rawClassroom is Map) {
      classroomName = rawClassroom['name'] as String?;
      homeroomTeacherName ??= rawClassroom['homeroom_teacher'] as String?;
      homeroomTeacherPhone ??= rawClassroom['homeroom_teacher_phone'] as String?;
    } else if (rawClassroom is String) {
      classroomName = rawClassroom;
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
      };
}
