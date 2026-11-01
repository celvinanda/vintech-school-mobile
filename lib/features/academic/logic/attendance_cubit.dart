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
    String? studentNis,
    bool isStaff = false,
    bool forceRefreshMeta = false,
  }) async {
    // 1. Muat instan dari Hive Database Lokal (0 ms Latency) jika belum ada di layar
    if (state is! AttendanceLoaded) {
      final hiveAtt = _repository.getCachedAttendances(
        classroomId: classroomId,
        studentNis: studentNis,
      );
      final hiveClassrooms = _repository.getCachedClassrooms();
      final hiveStudents = isStaff
          ? _repository.getCachedStudents(classroomId: classroomId)
          : null;

      if (hiveClassrooms != null && _cachedClassrooms.isEmpty) {
        _cachedClassrooms = hiveClassrooms;
      }
      if (hiveStudents != null && _cachedStudents.isEmpty) {
        _cachedStudents = hiveStudents;
      }

      if (hiveAtt != null) {
        emit(
          AttendanceLoaded(
            attendances: hiveAtt,
            classrooms: _cachedClassrooms,
            students: _cachedStudents,
            selectedClassroomId: classroomId,
          ),
        );
      } else {
        emit(AttendanceLoading());
      }
    }

    // 2. Sinkronisasi dengan Cloud Server di latar belakang
    try {
      final futures = <Future<dynamic>>[
        _repository.getAttendances(
          classroomId: classroomId,
          studentNis: studentNis,
        ),
      ];

      final bool needClassrooms = _cachedClassrooms.isEmpty || forceRefreshMeta;
      if (needClassrooms) {
        futures.add(_repository.getClassrooms());
      }

      final bool needStudents =
          isStaff && (_cachedStudents.isEmpty || forceRefreshMeta);
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
      if (state is! AttendanceLoaded) {
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
      emit(
        AttendanceActionSuccess(
          'Presensi ${att.studentName} (${att.statusDisplay}) berhasil dicatat!',
        ),
      );
      await loadAttendances(isStaff: true);
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}
