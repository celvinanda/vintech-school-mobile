import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;

  /// Default local development backend URL based on platform.
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8001';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 points to host machine loopback inside Android Emulator
      return 'http://10.0.2.2:8001';
    }
    // iOS Simulator, macOS, Windows
    return 'http://127.0.0.1:8001';
  }

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
