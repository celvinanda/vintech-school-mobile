import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Layanan Database Lokal Offline-First berbasis Hive.
/// Menyimpan data profil, dashboard sekolah, presensi, daftar kelas, siswa,
/// tagihan SPP, serta antrean sinkronisasi offline (Outbox Queue).
///
/// Kebijakan Pemulihan Data (Safe Recovery Policy):
/// 1. _cacheBoxName (Data Transien): Diperbolehkan reset otomatis jika file cache korup.
/// 2. _sessionBoxName (Sesi Pengguna): TIDAK PERNAH dihapus otomatis dari disk tanpa persetujuan.
/// 3. _outboxBoxName (Antrean Presensi Offline): DILINDUNGI MUTLAK (Zero Data Loss Policy).
///    Tidak boleh dihapus saat terjadi error pembukaan file.
class HiveCacheService {
  static const String _sessionBoxName = 'vintech_session_box';
  static const String _cacheBoxName = 'vintech_offline_cache_box';
  static const String _outboxBoxName = 'vintech_offline_outbox_box';

  final Box<String> _sessionBox;
  final Box<String> _cacheBox;
  final Box<String> _outboxBox;

  HiveCacheService._(this._sessionBox, this._cacheBox, this._outboxBox);

  /// Membuka Hive Box secara tangguh dengan proteksi ketat anti-data-loss.
  static Future<Box<String>> _openBoxSafely(
    String boxName, {
    bool allowDeleteOnCorruption = false,
  }) async {
    try {
      return await Hive.openBox<String>(boxName);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HIVE DB] Box $boxName gagal dibuka / terkunci: $e');
      }

      // HANYA box cache transien yang boleh dihapus otomatis dari disk
      if (allowDeleteOnCorruption) {
        if (kDebugMode) {
          debugPrint('[HIVE DB] Menghapus box cache sementara $boxName dari disk untuk pemulihan...');
        }
        try {
          await Hive.deleteBoxFromDisk(boxName);
        } catch (delErr) {
          if (kDebugMode) {
            debugPrint('[HIVE DB] Gagal deleteBoxFromDisk: $delErr');
          }
        }
        return await Hive.openBox<String>(boxName);
      }

      // Untuk Box Kritis (Session & Outbox Presensi Offline):
      // JANGAN PERNAH panggil deleteBoxFromDisk! Coba buka kembali sekali lagi.
      try {
        await Future.delayed(const Duration(milliseconds: 60));
        return await Hive.openBox<String>(boxName);
      } catch (retryError) {
        debugPrint(
          '[HIVE CRITICAL] Gagal membuka $boxName tanpa menghapus data penting: $retryError',
        );
        rethrow;
      }
    }
  }

  static Future<HiveCacheService> init() async {
    try {
      await Hive.initFlutter();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[HIVE DB] Hive.initFlutter notice: $e');
      }
    }

    // Penerapan Aturan Keamanan: Cache transien aman di-reset, Session & Outbox dilindungi mutlak
    final sessionBox = await _openBoxSafely(_sessionBoxName, allowDeleteOnCorruption: false);
    final cacheBox = await _openBoxSafely(_cacheBoxName, allowDeleteOnCorruption: true);
    final outboxBox = await _openBoxSafely(_outboxBoxName, allowDeleteOnCorruption: false);

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
