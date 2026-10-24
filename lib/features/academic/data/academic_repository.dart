import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/attendance_model.dart';
import 'models/classroom_model.dart';
import 'models/student_model.dart';

class AcademicRepository {
  final ApiClient _apiClient;

  AcademicRepository(this._apiClient);

  Dio get _dio => _apiClient.dio;

  Future<List<ClassroomModel>> getClassrooms() async {
    try {
      final response = await _dio.get(ApiConstants.classrooms);
      final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );

      if (envelope.success && envelope.data != null) {
        final list = envelope.data!['classrooms'] as List<dynamic>? ?? [];
        return list.map((c) => ClassroomModel.fromJson(c as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal memuat daftar kelas: ${e.message}');
    }
  }

  Future<List<StudentModel>> getStudents({String? classroomId, String? search}) async {
    try {
      final response = await _dio.get(
        ApiConstants.students,
        queryParameters: {
          if (classroomId != null && classroomId.isNotEmpty) 'classroom_id': classroomId,
          if (search != null && search.isNotEmpty) 'q': search,
        },
      );

      final envelope = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );

      if (envelope.success && envelope.data != null) {
        return envelope.data!
            .map((s) => StudentModel.fromJson(s as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal memuat direktori siswa: ${e.message}');
    }
  }

  Future<List<AttendanceModel>> getAttendances({
    String? classroomId,
    String? studentNis,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.attendance,
        queryParameters: {
          if (classroomId != null && classroomId.isNotEmpty) 'classroom_id': classroomId,
          if (studentNis != null && studentNis.isNotEmpty) 'student_nis': studentNis,
        },
      );

      final envelope = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );

      if (envelope.success && envelope.data != null) {
        return envelope.data!
            .map((a) => AttendanceModel.fromJson(a as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal memuat riwayat presensi: ${e.message}');
    }
  }

  Future<AttendanceModel> recordAttendance({
    required String studentNis,
    required String status,
    String notes = '',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.attendance,
        data: {
          'student_nis': studentNis.trim(),
          'status': status.toUpperCase(),
          'notes': notes.trim(),
        },
      );

      final envelope = ApiResponse<AttendanceModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => AttendanceModel.fromJson(json as Map<String, dynamic>),
      );

      if (envelope.success && envelope.data != null) {
        return envelope.data!;
      }
      throw ApiException(envelope.message.isNotEmpty ? envelope.message : 'Gagal mencatat presensi');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal mencatat presensi: ${e.message}');
    }
  }
}
