import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';
import 'api_response.dart';

class ApiClient {
  final LocalStorage _storage;
  late final Dio dio;

  ApiClient(this._storage) {
    final baseUrl = _storage.getBaseUrl();

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: ApiConstants.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: ApiConstants.receiveTimeoutSeconds),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Sync base URL dynamically in case changed in settings
          options.baseUrl = _storage.getBaseUrl();

          // Inject Bearer token
          final token = _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Inject Active School Code
          final schoolCode = _storage.getSchoolCode();
          if (schoolCode != null && schoolCode.isNotEmpty) {
            options.headers['X-School-Code'] = schoolCode;
          }

          // Inject Device Platform
          String platform = 'unknown';
          if (kIsWeb) {
            platform = 'web';
          } else if (Platform.isAndroid) {
            platform = 'android';
          } else if (Platform.isIOS) {
            platform = 'ios';
          }
          options.headers['X-Device-Platform'] = platform;

          if (kDebugMode) {
            final queryStr = options.queryParameters.isNotEmpty
                ? '?${Uri(queryParameters: options.queryParameters.map((k, v) => MapEntry(k, v.toString()))).query}'
                : '';
            debugPrint('[DIO >>] ${options.method} ${options.baseUrl}${options.path}$queryStr');
            if (options.data != null) debugPrint('   Body: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('[DIO <<] ${response.statusCode} ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            debugPrint('[DIO !!] ${e.response?.statusCode}: ${e.message}');
            if (e.response?.data != null) debugPrint('   Error Data: ${e.response?.data}');
          }

          String message = 'Terjadi kesalahan pada koneksi server.';
          int? statusCode = e.response?.statusCode;
          dynamic details;

          if (e.response?.data != null && e.response?.data is Map<String, dynamic>) {
            final dataMap = e.response!.data as Map<String, dynamic>;
            if (dataMap.containsKey('message') && dataMap['message'] is String) {
              message = dataMap['message'] as String;
            }
            details = dataMap['details'];
          } else if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            message = 'Waktu koneksi ke server habis. Periksa koneksi internet Anda.';
          } else if (e.type == DioExceptionType.connectionError) {
            message = 'Tidak dapat terhubung ke server backend Vintech School ($baseUrl). Pastikan server aktif.';
          }

          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              response: e.response,
              type: e.type,
              error: ApiException(message, statusCode: statusCode, details: details),
            ),
          );
        },
      ),
    );
  }
}
