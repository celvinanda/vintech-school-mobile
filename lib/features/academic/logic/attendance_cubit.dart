import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/academic_repository.dart';
import '../data/models/attendance_model.dart';
import '../data/models/classroom_model.dart';
import '../data/models/student_model.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AcademicRepository _repository;

  AttendanceCubit(this._repository) : super(AttendanceInitial());

  Future<void> loadAttendances({String? classroomId}) async {
    emit(AttendanceLoading());
    try {
      final results = await Future.wait([
        _repository.getAttendances(classroomId: classroomId),
        _repository.getClassrooms(),
        _repository.getStudents(classroomId: classroomId),
      ]);

      emit(
        AttendanceLoaded(
          attendances: results[0] as List<AttendanceModel>,
          classrooms: results[1] as List<ClassroomModel>,
          students: results[2] as List<StudentModel>,
          selectedClassroomId: classroomId,
        ),
      );
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> recordAttendance({
    required String studentNis,
    required String status,
    String notes = '',
  }) async {
    try {
      final att = await _repository.recordAttendance(
        studentNis: studentNis,
        status: status,
        notes: notes,
      );
      emit(AttendanceActionSuccess('Presensi ${att.studentName} (${att.statusDisplay}) berhasil dicatat!'));
      await loadAttendances();
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}
