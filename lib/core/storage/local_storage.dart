import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import 'hive_cache_service.dart';

/// Layanan Penyimpanan Lokal Hibrida Terpadu (Enterprise Hybrid Storage).
/// 1. flutter_secure_storage: Hardware-backed Keystore/Keychain untuk Auth Token.
/// 2. Hive Database: High-performance JSON Document Store untuk cache offline & outbox presensi.
/// 3. SharedPreferences: Key-Value store untuk preferensi dasar & tracking versi aplikasi.
class LocalStorage {
  static const String _keyToken = 'auth_token';
  static const String _keySchoolCode = 'active_school_code';
  static const String _keyUserData = 'user_data';
  static const String _keySchoolData = 'school_data';
  static const String _keyBaseUrl = 'base_url_override';
  static const String _keyLastAppVersion = 'last_seen_app_version';

  final SharedPreferences _prefs;
  final HiveCacheService _hive;
  final FlutterSecureStorage _secureStorage;
  final String _currentAppVersion;
  final bool _isReturningUser;

  // In-memory cache untuk akses token sinkron tanpa latensi (0ms) pada Dio Interceptor
  String? _cachedToken;

  LocalStorage(
    this._prefs,
    this._hive,
    this._secureStorage,
    this._currentAppVersion,
    this._isReturningUser, [
    this._cachedToken,
  ]);

  HiveCacheService get hive => _hive;
  String get currentAppVersion => _currentAppVersion;

  static Future<LocalStorage> init({
    FlutterSecureStorage? secureStorageOverride,
    String? currentVersionOverride,
  }) async {
    final secureStorage = secureStorageOverride ??
        const FlutterSecureStorage(
          aOptions: AndroidOptions(resetOnError: true),
        );

    final results = await Future.wait([
      SharedPreferences.getInstance(),
      HiveCacheService.init(),
    ]);

    final prefs = results[0] as SharedPreferences;
    final hive = results[1] as HiveCacheService;

    // 1. Ekstraksi Versi Aplikasi untuk Deteksi Pembaruan (Version-Aware Tracking)
    final currentVersion = currentVersionOverride ?? AppConstants.appVersion;
    final lastSeenVersion = prefs.getString(_keyLastAppVersion);
    final bool isReturning = (lastSeenVersion != null && lastSeenVersion == currentVersion);

    // 2. Akses Token Terenkripsi di Hardware Keystore / Keychain
    String? token;
    try {
      token = await secureStorage.read(key: _keyToken);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[STORAGE] Gagal membaca token dari SecureStorage: $e');
      }
    }

    // 3. Migrasi Aman dari Penyimpanan Plaintext Legacy (SharedPreferences / Hive)
    if (token == null || token.isEmpty) {
      final legacyHiveToken = hive.getJson(_keyToken, isSession: true) as String?;
      final legacyPrefsToken = prefs.getString(_keyToken);
      final legacyToken = (legacyHiveToken != null && legacyHiveToken.isNotEmpty)
          ? legacyHiveToken
          : legacyPrefsToken;

      if (legacyToken != null && legacyToken.isNotEmpty) {
        token = legacyToken;
        try {
          await secureStorage.write(key: _keyToken, value: token);
          if (kDebugMode) {
            debugPrint('[STORAGE] Berhasil migrasi token ke FlutterSecureStorage.');
          }
          // Hapus jejak plaintext token demi standar keamanan
          await prefs.remove(_keyToken);
          await hive.putJson(_keyToken, '', isSession: true);
        } catch (_) {}
      }
    }

    return LocalStorage(
      prefs,
      hive,
      secureStorage,
      currentVersion,
      isReturning,
      token,
    );
  }

  // ===========================================================================
  // AUTH & SESSION STORAGE
  // ===========================================================================

  /// Mengembalikan true HANYA jika pengguna telah membuka versi aplikasi yang sama sebelumnya.
  /// Jika pengguna pertama kali install atau baru saja update, akan bernilai false.
  bool isReturningUser() => _isReturningUser;

  /// Memperbarui catatan versi terakhir aplikasi yang dikunjungi pengguna
  Future<void> markUserVisited() async {
    await _prefs.setString(_keyLastAppVersion, _currentAppVersion);
  }

  /// Menyimpan token autentikasi ke dalam Hardware Keystore / Keychain
  Future<void> saveToken(String token) async {
    _cachedToken = token;
    try {
      await _secureStorage.write(key: _keyToken, value: token);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[STORAGE] Error menulis ke FlutterSecureStorage: $e');
      }
    }
    // Pastikan Hive dan SharedPreferences bersih dari plaintext token
    await _prefs.remove(_keyToken);
    await _hive.putJson(_keyToken, '', isSession: true);
  }

  /// Mengambil token secara sinkron & instan (0ms) dari in-memory cache
  String? getToken() => _cachedToken;

  /// Menghapus token dari secure storage dan memori
  Future<void> clearToken() async {
    _cachedToken = null;
    try {
      await _secureStorage.delete(key: _keyToken);
    } catch (_) {}
    await _prefs.remove(_keyToken);
    await _hive.putJson(_keyToken, '', isSession: true);
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

  /// Prefix unik per user: menjamin isolasi 100% saat berganti akun di perangkat yang sama
  String get _activeUserPrefix {
    final user = getUserData();
    final userId = user?['user']?['id'] ?? user?['user']?['username'] ?? 'guest';
    return '${_activeSchoolPrefix}_user_$userId';
  }

  Future<void> cacheDashboard(Map<String, dynamic> data) async {
    await _hive.putJson('dashboard_$_activeSchoolPrefix', data);
  }

  Map<String, dynamic>? getCachedDashboard() {
    final raw = _hive.getJson('dashboard_$_activeSchoolPrefix');
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }

  Future<void> cacheAttendances(String filterKey, List<Map<String, dynamic>> items) async {
    await _hive.putJson('attendances_${_activeUserPrefix}_$filterKey', items);
  }

  List<Map<String, dynamic>>? getCachedAttendances(String filterKey) {
    final raw = _hive.getJson('attendances_${_activeUserPrefix}_$filterKey');
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
    await _hive.putJson('invoices_${_activeUserPrefix}_$filterKey', items);
  }

  List<Map<String, dynamic>>? getCachedInvoices(String filterKey) {
    final raw = _hive.getJson('invoices_${_activeUserPrefix}_$filterKey');
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
    await clearToken();
    await _hive.clearSessionAndCache();
    await _prefs.clear();
  }
}
