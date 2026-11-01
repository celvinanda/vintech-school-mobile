import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Layanan Database Lokal Offline-First berbasis Hive.
/// Menyimpan data profil, dashboard sekolah, presensi, daftar kelas, siswa,
/// tagihan SPP, serta antrean sinkronisasi offline (Outbox Queue).
/// Dilengkapi sistem pemulihan otomatis jika box korup atau terkunci di disk.
class HiveCacheService {
  static const String _sessionBoxName = 'vintech_session_box';
  static const String _cacheBoxName = 'vintech_offline_cache_box';
  static const String _outboxBoxName = 'vintech_offline_outbox_box';

  final Box<String> _sessionBox;
  final Box<String> _cacheBox;
  final Box<String> _outboxBox;

  HiveCacheService._(this._sessionBox, this._cacheBox, this._outboxBox);

  /// Membuka Hive Box secara tangguh dengan fallback otomatis jika korup
  static Future<Box<String>> _openBoxSafely(String boxName) async {
    try {
      return await Hive.openBox<String>(boxName);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HIVE DB] Box $boxName korup/terkunci: $e. Memulihkan database...');
      }
      try {
        await Hive.deleteBoxFromDisk(boxName);
      } catch (_) {}
      return await Hive.openBox<String>(boxName);
    }
  }

  static Future<HiveCacheService> init() async {
    try {
      await Hive.initFlutter();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HIVE DB] Hive.initFlutter warning: $e');
      }
    }

    final sessionBox = await _openBoxSafely(_sessionBoxName);
    final cacheBox = await _openBoxSafely(_cacheBoxName);
    final outboxBox = await _openBoxSafely(_outboxBoxName);

    if (kDebugMode) {
      debugPrint(
        '[HIVE DB] Offline-First Storage siap '
        '(Session: ${sessionBox.length}, Cache: ${cacheBox.length}, Outbox: ${outboxBox.length})',
      );
    }
    return HiveCacheService._(sessionBox, cacheBox, outboxBox);
  }

  // ===========================================================================
  // GENERIC STRUCTURED JSON CACHE WITH TIMESTAMP
  // ===========================================================================

  Future<void> putJson(String key, dynamic data, {bool isSession = false}) async {
    final payload = jsonEncode({
      'updated_at': DateTime.now().toIso8601String(),
      'data': data,
    });
    final targetBox = isSession ? _sessionBox : _cacheBox;
    await targetBox.put(key, payload);
  }

  dynamic getJson(String key, {bool isSession = false}) {
    final targetBox = isSession ? _sessionBox : _cacheBox;
    final raw = targetBox.get(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded['data'];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HIVE DB] Gagal decode key $key: $e');
      }
      return null;
    }
  }

  DateTime? getUpdatedAt(String key, {bool isSession = false}) {
    final targetBox = isSession ? _sessionBox : _cacheBox;
    final raw = targetBox.get(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final ts = decoded['updated_at'] as String?;
      return ts != null ? DateTime.tryParse(ts) : null;
    } catch (_) {
      return null;
    }
  }

  // ===========================================================================
  // OFFLINE OUTBOX QUEUE (UNTUK INPUT PRESENSI SAAT OFFLINE)
  // ===========================================================================

  Future<void> enqueueAttendance({
    required String schoolCode,
    required String studentNis,
    required String status,
    required String notes,
    String? recordedByUsername,
  }) async {
    final id = '${DateTime.now().millisecondsSinceEpoch}_$studentNis';
    final payload = jsonEncode({
      'id': id,
      'school_code': schoolCode,
      'student_nis': studentNis,
      'status': status,
      'notes': notes,
      'recorded_by': recordedByUsername ?? '',
      'created_at': DateTime.now().toIso8601String(),
    });
    await _outboxBox.put(id, payload);
  }

  List<Map<String, dynamic>> getPendingAttendances(String schoolCode, {String? username}) {
    final List<Map<String, dynamic>> items = [];
    for (final key in _outboxBox.keys) {
      final raw = _outboxBox.get(key);
      if (raw != null) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final matchesSchool = map['school_code'] == schoolCode;
          final matchesUser = (username == null || username.isEmpty) ||
              (map['recorded_by'] == null || map['recorded_by'] == '' || map['recorded_by'] == username);
          if (matchesSchool && matchesUser) {
            items.add(map);
          }
        } catch (_) {}
      }
    }
    return items;
  }

  Future<void> removePendingAttendance(String id) async {
    await _outboxBox.delete(id);
  }

  int get totalSessionEntries => _sessionBox.length;
  int get totalCachedEntries => _cacheBox.length;
  int get totalPendingOutbox => _outboxBox.length;

  Future<void> clearCacheOnly() async {
    await _cacheBox.clear();
  }

  Future<void> clearSessionAndCache() async {
    await _sessionBox.clear();
    await _cacheBox.clear();
  }
}
