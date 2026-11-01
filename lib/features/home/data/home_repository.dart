import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import 'models/school_dashboard_model.dart';

class HomeRepository {
  final ApiClient _apiClient;
  final LocalStorage _storage;

  HomeRepository(this._apiClient, this._storage);

  Dio get _dio => _apiClient.dio;

  SchoolDashboardModel? getCachedDashboard() {
    final raw = _storage.getCachedDashboard();
    if (raw == null) return null;
    try {
      return SchoolDashboardModel.fromJson(raw);
    } catch (_) {
      return null;
    }
  }

  Future<SchoolDashboardModel> getCurrentSchoolDashboard() async {
    try {
      final response = await _dio.get(ApiConstants.currentSchool);
      final envelope = ApiResponse<SchoolDashboardModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => SchoolDashboardModel.fromJson(json as Map<String, dynamic>),
      );

      if (envelope.success && envelope.data != null) {
        await _storage.cacheDashboard(envelope.data!.toJson());
        return envelope.data!;
      }
      throw ApiException(
        envelope.message.isNotEmpty
            ? envelope.message
            : 'Gagal memuat dashboard',
      );
    } on DioException catch (e) {
      // Offline-First Fallback: Gunakan data Hive lokal jika jaringan terputus
      final cached = getCachedDashboard();
      if (cached != null) {
        return cached;
      }
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal memuat data sekolah: ${e.message}');
    }
  }
}
