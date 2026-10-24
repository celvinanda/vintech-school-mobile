import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'hive_cache_service.dart';

class LocalStorage {
  static const String _keyToken = 'auth_token';
  static const String _keySchoolCode = 'active_school_code';
  static const String _keyUserData = 'user_data';
  static const String _keySchoolData = 'school_data';
  static const String _keyBaseUrl = 'base_url_override';

  final SharedPreferences _prefs;
  final HiveCacheService _hive;

  LocalStorage(this._prefs, this._hive);

  HiveCacheService get hive => _hive;

  static Future<LocalStorage> init() async {
    final results = await Future.wait([
      SharedPreferences.getInstance(),
      HiveCacheService.init(),
    ]);
    return LocalStorage(
      results[0] as SharedPreferences,
      results[1] as HiveCacheService,
    );
  }

  // ===========================================================================
  // AUTH & SESSION STORAGE (HIVE + SHARED PREFERENCES)
  // ===========================================================================

  Future<void> saveToken(String token) async {
    await _hive.putJson(_keyToken, token, isSession: true);
    await _prefs.setString(_keyToken, token);
  }

  String? getToken() {
    final fromHive = _hive.getJson(_keyToken, isSession: true) as String?;
    if (fromHive != null && fromHive.isNotEmpty) return fromHive;
    return _prefs.getString(_keyToken);
  }

  Future<void> clearToken() async {
    await _hive.putJson(_keyToken, '', isSession: true);
    await _prefs.remove(_keyToken);
  }

  Future<void> saveSchoolCode(String schoolCode) async {
    await _hive.putJson(_keySchoolCode, schoolCode, isSession: true);
    await _prefs.setString(_keySchoolCode, schoolCode);
  }

  String? getSchoolCode() {
    final fromHive = _hive.getJson(_keySchoolCode, isSession: true) as String?;
    if (fromHive != null && fromHive.isNotEmpty) return fromHive;
    return _prefs.getString(_keySchoolCode);
  }

  Future<void> clearSchoolCode() async {
    await _hive.putJson(_keySchoolCode, '', isSession: true);
    await _prefs.remove(_keySchoolCode);
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _hive.putJson(_keyUserData, data, isSession: true);
    await _prefs.setString(_keyUserData, jsonEncode(data));
  }

  Map<String, dynamic>? getUserData() {
    final fromHive = _hive.getJson(_keyUserData, isSession: true);
    if (fromHive is Map) {
      return Map<String, dynamic>.from(fromHive);
    }
    final raw = _prefs.getString(_keyUserData);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSchoolData(Map<String, dynamic> data) async {
    await _hive.putJson(_keySchoolData, data, isSession: true);
    await _prefs.setString(_keySchoolData, jsonEncode(data));
  }

  Map<String, dynamic>? getSchoolData() {
    final fromHive = _hive.getJson(_keySchoolData, isSession: true);
    if (fromHive is Map) {
      return Map<String, dynamic>.from(fromHive);
    }
    final raw = _prefs.getString(_keySchoolData);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ===========================================================================
  // OFFLINE DOMAIN CACHE (HIVE DATABASE)
  // ===========================================================================

  String get _activeSchoolPrefix => getSchoolCode() ?? 'default';

  Future<void> cacheDashboard(Map<String, dynamic> data) async {
    await _hive.putJson('dashboard_$_activeSchoolPrefix', data);
  }

  Map<String, dynamic>? getCachedDashboard() {
    final raw = _hive.getJson('dashboard_$_activeSchoolPrefix');
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> cacheAttendances(String filterKey, List<Map<String, dynamic>> items) async {
    await _hive.putJson('attendances_${_activeSchoolPrefix}_$filterKey', items);
  }

  List<Map<String, dynamic>>? getCachedAttendances(String filterKey) {
    final raw = _hive.getJson('attendances_${_activeSchoolPrefix}_$filterKey');
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  Future<void> cacheClassrooms(List<Map<String, dynamic>> items) async {
    await _hive.putJson('classrooms_$_activeSchoolPrefix', items);
  }

  List<Map<String, dynamic>>? getCachedClassrooms() {
    final raw = _hive.getJson('classrooms_$_activeSchoolPrefix');
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  Future<void> cacheStudents(String filterKey, List<Map<String, dynamic>> items) async {
    await _hive.putJson('students_${_activeSchoolPrefix}_$filterKey', items);
  }

  List<Map<String, dynamic>>? getCachedStudents(String filterKey) {
    final raw = _hive.getJson('students_${_activeSchoolPrefix}_$filterKey');
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  Future<void> cacheInvoices(String filterKey, List<Map<String, dynamic>> items) async {
    await _hive.putJson('invoices_${_activeSchoolPrefix}_$filterKey', items);
  }

  List<Map<String, dynamic>>? getCachedInvoices(String filterKey) {
    final raw = _hive.getJson('invoices_${_activeSchoolPrefix}_$filterKey');
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  // ===========================================================================
  // BASE URL & SESSION RESET
  // ===========================================================================

  Future<void> saveBaseUrl(String url) async {
    await _prefs.setString(_keyBaseUrl, url.trim());
  }

  String getBaseUrl() {
    final saved = _prefs.getString(_keyBaseUrl);
    if (saved != null && saved.trim().isNotEmpty) {
      final trimmed = saved.trim();
      if (trimmed == 'http://10.0.2.2:8001' || trimmed == 'http://127.0.0.1:8001') {
        return ApiConstants.defaultBaseUrl;
      }
      return trimmed;
    }
    return ApiConstants.defaultBaseUrl;
  }

  Future<void> clearAllSession() async {
    await clearToken();
    await _hive.putJson(_keyUserData, null, isSession: true);
    await _prefs.remove(_keyUserData);
  }

  Future<void> resetAll() async {
    await _hive.clearSessionAndCache();
    await _prefs.clear();
  }
}
