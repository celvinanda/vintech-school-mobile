class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;
  final dynamic errorDetails;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.meta,
    this.errorDetails,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic dataJson)? fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : json['data'] as T?,
      meta: json['meta'] as Map<String, dynamic>?,
      errorDetails: json['details'],
    );
  }

  factory ApiResponse.error(String message, [dynamic details]) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errorDetails: details,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;
}
