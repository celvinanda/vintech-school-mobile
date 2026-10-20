class ApiConstants {
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;

  /// Official Production Cloud Server for Vintech School.
  static const String officialBaseUrl = 'https://school.vintech.cloud';

  /// Default backend URL points directly to the official cloud server.
  static String get defaultBaseUrl => officialBaseUrl;

  // Auth & Tenant
  static const String schoolLookup = '/api/v1/schools/lookup/';
  static const String login = '/api/v1/auth/login/';
  static const String me = '/api/v1/auth/me/';
  static const String switchSchool = '/api/v1/auth/switch-school/';
  static const String deviceToken = '/api/v1/auth/device-token/';
  static const String logout = '/api/v1/auth/logout/';

  // School
  static const String currentSchool = '/api/v1/schools/current/';
  static const String announcements = '/api/v1/schools/announcements/';

  // Academic
  static const String classrooms = '/api/v1/academic/classrooms/';
  static const String students = '/api/v1/academic/students/';
  static const String teachers = '/api/v1/academic/teachers/';
  static const String attendance = '/api/v1/academic/attendance/';

  // Billing
  static const String invoices = '/api/v1/billing/invoices/';
  static String invoiceCheckout(String invoiceNumber) =>
      '/api/v1/billing/invoices/$invoiceNumber/checkout/';
}
