import '../data/models/attendance_model.dart';
import '../data/models/classroom_model.dart';
import '../data/models/student_model.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceModel> attendances;
  final List<ClassroomModel> classrooms;
  final List<StudentModel> students;
  final String? selectedClassroomId;

  AttendanceLoaded({
    required this.attendances,
    this.classrooms = const [],
    this.students = const [],
    this.selectedClassroomId,
  });

  AttendanceLoaded copyWith({
    List<AttendanceModel>? attendances,
    List<ClassroomModel>? classrooms,
    List<StudentModel>? students,
    String? selectedClassroomId,
  }) {
    return AttendanceLoaded(
      attendances: attendances ?? this.attendances,
      classrooms: classrooms ?? this.classrooms,
      students: students ?? this.students,
      selectedClassroomId: selectedClassroomId ?? this.selectedClassroomId,
    );
  }
}

class AttendanceActionSuccess extends AttendanceState {
  final String message;
  AttendanceActionSuccess(this.message);
}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);
}
