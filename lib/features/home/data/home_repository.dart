import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/school_dashboard_model.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository(this._apiClient);

  Dio get _dio => _apiClient.dio;

  Future<SchoolDashboardModel> getCurrentSchoolDashboard() async {
    try {
      final response = await _dio.get(ApiConstants.currentSchool);
      final envelope = ApiResponse<SchoolDashboardModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => SchoolDashboardModel.fromJson(json as Map<String, dynamic>),
      );

      if (envelope.success && envelope.data != null) {
        return envelope.data!;
      }
      throw ApiException(envelope.message.isNotEmpty ? envelope.message : 'Gagal memuat dashboard');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal memuat data sekolah: ${e.message}');
    }
  }
}
