import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/academic_repository.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AcademicRepository _repository;

  AttendanceCubit(this._repository) : super(AttendanceInitial());

  Future<void> loadAttendances({String? classroomId}) async {
    emit(AttendanceLoading());
    try {
      final attendances = await _repository.getAttendances(classroomId: classroomId);
      final classrooms = await _repository.getClassrooms();
      final students = await _repository.getStudents(classroomId: classroomId);

      emit(
        AttendanceLoaded(
          attendances: attendances,
          classrooms: classrooms,
          students: students,
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
