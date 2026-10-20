import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class LocalStorage {
  static const String _keyToken = 'auth_token';
  static const String _keySchoolCode = 'active_school_code';
  static const String _keyUserData = 'user_data';
  static const String _keySchoolData = 'school_data';
  static const String _keyBaseUrl = 'base_url_override';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  // Token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_keyToken);
  }

  // Active School Code
  Future<void> saveSchoolCode(String schoolCode) async {
    await _prefs.setString(_keySchoolCode, schoolCode);
  }

  String? getSchoolCode() {
    return _prefs.getString(_keySchoolCode);
  }

  Future<void> clearSchoolCode() async {
    await _prefs.remove(_keySchoolCode);
  }

  // User Profile JSON
  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _prefs.setString(_keyUserData, jsonEncode(data));
  }

  Map<String, dynamic>? getUserData() {
    final raw = _prefs.getString(_keyUserData);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // School Data JSON (branding, name, color)
  Future<void> saveSchoolData(Map<String, dynamic> data) async {
    await _prefs.setString(_keySchoolData, jsonEncode(data));
  }

  Map<String, dynamic>? getSchoolData() {
    final raw = _prefs.getString(_keySchoolData);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Custom Base URL Override
  Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url);
  }

  String getBaseUrl() {
    final saved = _prefs.getString(_keyBaseUrl);
    if (saved != null && saved.trim().isNotEmpty) {
      return saved.trim();
    }
    return ApiConstants.defaultBaseUrl;
  }

  Future<void> clearAllSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUserData);
    // Note: We deliberately preserve the school code so user doesn't have to re-enter it on every logout
  }

  Future<void> resetAll() async {
    await _prefs.clear();
  }
}
