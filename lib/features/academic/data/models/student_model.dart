class StudentModel {
  final String id;
  final String nis;
  final String? nisn;
  final String fullName;
  final String gender;
  final String? classroomName;
  final String? parentName;
  final String? parentPhone;

  StudentModel({
    required this.id,
    required this.nis,
    this.nisn,
    required this.fullName,
    required this.gender,
    this.classroomName,
    this.parentName,
    this.parentPhone,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String? ?? '',
      nis: json['nis'] as String? ?? '',
      nisn: json['nisn'] as String?,
      fullName: json['full_name'] as String? ?? '',
      gender: json['gender'] as String? ?? 'L',
      classroomName: json['classroom'] as String?,
      parentName: json['parent_name'] as String?,
      parentPhone: json['parent_phone'] as String?,
    );
  }
}
