import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/invoice_model.dart';

class BillingRepository {
  final ApiClient _apiClient;

  BillingRepository(this._apiClient);

  Dio get _dio => _apiClient.dio;

  Future<List<InvoiceModel>> getInvoices({String? status, String? studentNis}) async {
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
        return envelope.data!
            .map((i) => InvoiceModel.fromJson(i as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
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
      throw ApiException(envelope.message.isNotEmpty ? envelope.message : 'Gagal membuat sesi pembayaran');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal inisialisasi pembayaran: ${e.message}');
    }
  }
}
