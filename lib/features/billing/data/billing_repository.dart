import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import 'models/invoice_model.dart';

class BillingRepository {
  final ApiClient _apiClient;
  final LocalStorage _storage;

  BillingRepository(this._apiClient, this._storage);

  Dio get _dio => _apiClient.dio;

  String _invCacheKey(String? status, String? studentNis) =>
      '${(status == null || status.isEmpty) ? "ALL" : status.toUpperCase()}_${studentNis ?? "all"}';

  List<InvoiceModel>? getCachedInvoices({String? status, String? studentNis}) {
    final raw = _storage.getCachedInvoices(_invCacheKey(status, studentNis));
    if (raw == null) return null;
    return raw.map((i) => InvoiceModel.fromJson(i)).toList();
  }

  Future<List<InvoiceModel>> getInvoices({String? status, String? studentNis}) async {
    final cacheKey = _invCacheKey(status, studentNis);
    try {
      final response = await _dio.get(
        ApiConstants.invoices,
        queryParameters: {
          if (status != null && status.isNotEmpty && status.toUpperCase() != 'ALL')
            'status': status.toUpperCase(),
          if (studentNis != null && studentNis.isNotEmpty) 'student_nis': studentNis,
        },
      );

      final envelope = ApiResponse<List<dynamic>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as List<dynamic>,
      );

      if (envelope.success && envelope.data != null) {
        final models = envelope.data!
            .map((i) => InvoiceModel.fromJson(i as Map<String, dynamic>))
            .toList();
        await _storage.cacheInvoices(cacheKey, models.map((m) => m.toJson()).toList());
        return models;
      }
      return getCachedInvoices(status: status, studentNis: studentNis) ?? [];
    } on DioException catch (e) {
      final cached = getCachedInvoices(status: status, studentNis: studentNis);
      if (cached != null) return cached;
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal memuat daftar tagihan: ${e.message}');
    }
  }

  Future<InvoiceModel> initiateCheckout(String invoiceNumber) async {
    try {
      final response = await _dio.post(ApiConstants.invoiceCheckout(invoiceNumber));
      final envelope = ApiResponse<InvoiceModel>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => InvoiceModel.fromJson(json as Map<String, dynamic>),
      );

      if (envelope.success && envelope.data != null) {
        return envelope.data!;
      }
      throw ApiException(
        envelope.message.isNotEmpty ? envelope.message : 'Gagal membuat sesi pembayaran',
      );
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal inisialisasi pembayaran: ${e.message}');
    }
  }
}
