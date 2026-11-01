class ClassroomModel {
  final String id;
  final String name;
  final int gradeLevel;
  final int capacity;
  final int studentCount;
  final String? homeroomTeacher;

  ClassroomModel({
    required this.id,
    required this.name,
    required this.gradeLevel,
    required this.capacity,
    required this.studentCount,
    this.homeroomTeacher,
  });

  factory ClassroomModel.fromJson(Map<String, dynamic> json) {
    return ClassroomModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      gradeLevel: json['grade_level'] as int? ?? 10,
      capacity: json['capacity'] as int? ?? 36,
      studentCount: json['student_count'] as int? ?? 0,
      homeroomTeacher: json['homeroom_teacher'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'grade_level': gradeLevel,
    'capacity': capacity,
    'student_count': studentCount,
    'homeroom_teacher': homeroomTeacher,
  };
}
