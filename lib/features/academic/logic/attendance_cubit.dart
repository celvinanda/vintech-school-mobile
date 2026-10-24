import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/academic_repository.dart';
import '../data/models/attendance_model.dart';
import '../data/models/classroom_model.dart';
import '../data/models/student_model.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AcademicRepository _repository;

  List<ClassroomModel> _cachedClassrooms = [];
  List<StudentModel> _cachedStudents = [];

  AttendanceCubit(this._repository) : super(AttendanceInitial());

  List<ClassroomModel> get cachedClassrooms => _cachedClassrooms;
  List<StudentModel> get cachedStudents => _cachedStudents;

  Future<void> loadAttendances({
    String? classroomId,
    bool isStaff = false,
    bool forceRefreshMeta = false,
  }) async {
    final currentState = state;
    final hasExistingData = currentState is AttendanceLoaded;

    if (!hasExistingData) {
      emit(AttendanceLoading());
    }

    try {
      final futures = <Future<dynamic>>[
        _repository.getAttendances(classroomId: classroomId),
      ];

      final bool needClassrooms = _cachedClassrooms.isEmpty || forceRefreshMeta;
      if (needClassrooms) {
        futures.add(_repository.getClassrooms());
      }

      final bool needStudents = isStaff && (_cachedStudents.isEmpty || forceRefreshMeta);
      if (needStudents) {
        futures.add(_repository.getStudents(classroomId: classroomId));
      }

      final results = await Future.wait(futures);
      final attendances = results[0] as List<AttendanceModel>;

      int nextIdx = 1;
      if (needClassrooms) {
        _cachedClassrooms = results[nextIdx++] as List<ClassroomModel>;
      }
      if (needStudents) {
        _cachedStudents = results[nextIdx++] as List<StudentModel>;
      }

      emit(
        AttendanceLoaded(
          attendances: attendances,
          classrooms: _cachedClassrooms,
          students: _cachedStudents,
          selectedClassroomId: classroomId,
        ),
      );
    } catch (e) {
      if (!hasExistingData) {
        emit(AttendanceError(e.toString()));
      }
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
      await loadAttendances(isStaff: true);
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}
