import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import 'models/attendance_model.dart';
import 'models/classroom_model.dart';
import 'models/student_model.dart';

class AcademicRepository {
  final ApiClient _apiClient;
  final LocalStorage _storage;
  bool _isFlushingOutbox = false;

  AcademicRepository(this._apiClient, this._storage);

  Dio get _dio => _apiClient.dio;
  bool get isFlushingOutbox => _isFlushingOutbox;

  String _attCacheKey(String? classroomId, String? studentNis) =>
      '${classroomId ?? "all"}_${studentNis ?? "all"}';

  String _stuCacheKey(String? classroomId, String? search) =>
      '${classroomId ?? "all"}_${search ?? "all"}';

  // ===========================================================================
  // LOCAL HIVE CACHE READERS (INSTANT 0 MS)
  // ===========================================================================

  List<ClassroomModel>? getCachedClassrooms() {
    final raw = _storage.getCachedClassrooms();
    if (raw == null) return null;
    return raw.map((c) => ClassroomModel.fromJson(c)).toList();
  }

  List<StudentModel>? getCachedStudents({String? classroomId, String? search}) {
    final raw = _storage.getCachedStudents(_stuCacheKey(classroomId, search));
    if (raw == null) return null;
    return raw.map((s) => StudentModel.fromJson(s)).toList();
  }

  List<AttendanceModel>? getCachedAttendances({
    String? classroomId,
    String? studentNis,
  }) {
    final raw = _storage.getCachedAttendances(
      _attCacheKey(classroomId, studentNis),
    );
    if (raw == null) return null;
    return raw.map((a) => AttendanceModel.fromJson(a)).toList();
  }

  // ===========================================================================
  // OFFLINE-FIRST NETWORK + HIVE PERSISTENCE
  // ===========================================================================

  Future<List<ClassroomModel>> getClassrooms() async {
    try {
      final response = await _dio.get(ApiConstants.classrooms);
      final envelope = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );

      if (envelope.success && envelope.data != null) {
        final list = envelope.data!['classrooms'] as List<dynamic>? ?? [];
        final models = list
            .map((c) => ClassroomModel.fromJson(c as Map<String, dynamic>))
            .toList();
        await _storage.cacheClassrooms(models.map((m) => m.toJson()).toList());
        return models;
      }
      return getCachedClassrooms() ?? [];
    } on DioException catch (e) {
      final cached = getCachedClassrooms();
      if (cached != null) return cached;
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal memuat daftar kelas: ${e.message}');
    }
  }

  Future<List<StudentModel>> getStudents({
    String? classroomId,
    String? search,
  }) async {
    final cacheKey = _stuCacheKey(classroomId, search);
    try {
      final response = await _dio.get(
        ApiConstants.students,
        queryParameters: {
          if (classroomId != null && classroomId.isNotEmpty)
            'classroom_id': classroomId,
          if (search != null && search.isNotEmpty) 'q': search,
        },
      );

      final envelope = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );

      if (envelope.success && envelope.data != null) {
        final models = envelope.data!
            .map((s) => StudentModel.fromJson(s as Map<String, dynamic>))
            .toList();
        await _storage.cacheStudents(
          cacheKey,
          models.map((m) => m.toJson()).toList(),
        );
        return models;
      }
      return getCachedStudents(classroomId: classroomId, search: search) ?? [];
    } on DioException catch (e) {
      final cached = getCachedStudents(
        classroomId: classroomId,
        search: search,
      );
      if (cached != null) return cached;
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal memuat direktori siswa: ${e.message}');
    }
  }

  Future<StudentModel?> getStudentByNis(String nis) async {
    final cleanNis = nis.trim();
    if (cleanNis.isEmpty) return null;

    final allCached = getCachedStudents();
    if (allCached != null) {
      for (final s in allCached) {
        if (s.nis == cleanNis) return s;
      }
    }

    try {
      final list = await getStudents(search: cleanNis);
      for (final s in list) {
        if (s.nis == cleanNis) return s;
      }
      return list.isNotEmpty ? list.first : null;
    } catch (_) {
      return null;
    }
  }

  Future<List<AttendanceModel>> getAttendances({
    String? classroomId,
    String? studentNis,
  }) async {
    final cacheKey = _attCacheKey(classroomId, studentNis);
    try {
      // Sinkronkan antrean presensi offline terlebih dahulu jika ada
      await flushOfflineOutbox();

      final response = await _dio.get(
        ApiConstants.attendance,
        queryParameters: {
          if (classroomId != null && classroomId.isNotEmpty)
            'classroom_id': classroomId,
          if (studentNis != null && studentNis.isNotEmpty)
            'student_nis': studentNis,
        },
      );

      final envelope = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );

      if (envelope.success && envelope.data != null) {
        final models = envelope.data!
            .map((a) => AttendanceModel.fromJson(a as Map<String, dynamic>))
            .toList();
        await _storage.cacheAttendances(
          cacheKey,
          models.map((m) => m.toJson()).toList(),
        );
        return models;
      }
      return getCachedAttendances(
            classroomId: classroomId,
            studentNis: studentNis,
          ) ??
          [];
    } on DioException catch (e) {
      final cached = getCachedAttendances(
        classroomId: classroomId,
        studentNis: studentNis,
      );
      if (cached != null) return cached;
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal memuat riwayat presensi: ${e.message}');
    }
  }

  /// Mengirim seluruh antrean presensi offline dari Hive ke Cloud Server
  /// Dilengkapi Mutex Lock (_isFlushingOutbox) untuk mencegah duplikasi pengiriman.
  Future<int> flushOfflineOutbox() async {
    if (_isFlushingOutbox) return 0;
    final schoolCode = _storage.getSchoolCode() ?? 'default';
    final pending = _storage.hive.getPendingAttendances(schoolCode);
    if (pending.isEmpty) return 0;

    _isFlushingOutbox = true;
    int syncedCount = 0;
    try {
      for (final item in pending) {
        try {
          await _dio.post(
            ApiConstants.attendance,
            data: {
              'student_nis': item['student_nis'],
              'status': item['status'],
              'notes': item['notes'],
            },
          );
          await _storage.hive.removePendingAttendance(item['id'] as String);
          syncedCount++;
        } catch (_) {
          // Berhenti jika koneksi masih terputus; akan dicoba ulang oleh BackgroundSyncService
          break;
        }
      }
    } finally {
      _isFlushingOutbox = false;
    }
    return syncedCount;
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
      throw ApiException(
        envelope.message.isNotEmpty
            ? envelope.message
            : 'Gagal mencatat presensi',
      );
    } on DioException catch (e) {
      // Jika offline (tidak ada sinyal), simpan ke Hive Offline Outbox Queue
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        final schoolCode = _storage.getSchoolCode() ?? 'default';
        await _storage.hive.enqueueAttendance(
          schoolCode: schoolCode,
          studentNis: studentNis.trim(),
          status: status.toUpperCase(),
          notes: notes.trim(),
        );

        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        final offlineRecord = AttendanceModel(
          id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
          date: todayStr,
          status: status.toUpperCase(),
          statusDisplay: '${status.toUpperCase()} (Offline)',
          notes: notes.trim().isNotEmpty
              ? '${notes.trim()} • Tersimpan di Hive (Menunggu Sinyal)'
              : 'Tersimpan di Hive (Menunggu Sinyal)',
          studentId: '',
          studentNis: studentNis.trim(),
          studentName: 'Siswa ($studentNis)',
        );

        // Tambahkan secara optimistik ke cache Hive lokal
        final cacheKey = _attCacheKey(null, null);
        final existing = getCachedAttendances() ?? [];
        final updated = [offlineRecord, ...existing];
        await _storage.cacheAttendances(
          cacheKey,
          updated.map((m) => m.toJson()).toList(),
        );

        return offlineRecord;
      }

      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal mencatat presensi: ');
    }
  }

  /// Mencatat presensi secara massal (Batch Attendance) untuk 1 rombel sekaligus
  /// Didukung penyimpanan antrean offline-first Hive Outbox jika jaringan terputus.
  Future<List<AttendanceModel>> recordBatchAttendance({
    required List<Map<String, String>> records,
  }) async {
    final schoolCode = _storage.getSchoolCode() ?? 'default';

    // 1. Kirim sekaligus (Batch API) dalam 1 round-trip HTTP berkecepatan tinggi
    try {
      final response = await _dio.post(
        ApiConstants.attendance,
        data: {'items': records},
      );

      final envelope = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );

      if (envelope.success && envelope.data != null) {
        final models = envelope.data!
            .map(
              (item) => AttendanceModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();

        // Perbarui cache lokal presensi hari ini
        final cacheKey = _attCacheKey(null, null);
        final existing = getCachedAttendances() ?? [];
        final updated = [...models, ...existing];
        await _storage.cacheAttendances(
          cacheKey,
          updated.map((m) => m.toJson()).toList(),
        );

        return models;
      }
    } catch (_) {
      // Jika terjadi kendala jaringan atau batch endpoint tidak merespons, lakukan fallback
    }

    // 2. Fallback per item dengan antrean offline Hive Outbox
    final List<AttendanceModel> results = [];
    for (final item in records) {
      final studentNis = item['student_nis'] ?? '';
      final status = item['status'] ?? 'HADIR';
      final notes = item['notes'] ?? '';

      if (studentNis.isEmpty) continue;

      try {
        final res = await recordAttendance(
          studentNis: studentNis,
          status: status,
          notes: notes,
        );
        results.add(res);
      } catch (e) {
        await _storage.hive.enqueueAttendance(
          schoolCode: schoolCode,
          studentNis: studentNis,
          status: status,
          notes: notes,
        );
      }
    }
    return results;
  }
}
