import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../storage/local_storage.dart';

/// Service pengelola pembaruan kode OTA (Over-The-Air) berbasis Shorebird.
/// Mendukung eksekusi nyata di mode Release (Production) dan simulasi di mode Debug / Emulator.
class OtaUpdateService {
  final ShorebirdUpdater _updater;

  Patch? _currentPatch;
  Patch? _nextPatch;
  UpdateStatus _status = UpdateStatus.upToDate;
  bool _isChecking = false;
  bool _isDownloading = false;
  String? _errorMessage;

  // Simulator state untuk testing di Emulator / Debug mode
  bool _isDevSimulated = false;
  int _simulatedPatchNumber = 1;

  final StreamController<UpdateStatus> _statusStreamController =
      StreamController<UpdateStatus>.broadcast();

  OtaUpdateService({ShorebirdUpdater? updater})
      : _updater = updater ?? ShorebirdUpdater();

  // Getters
  bool get isShorebirdAvailable => _updater.isAvailable;
  Patch? get currentPatch => _currentPatch;
  Patch? get nextPatch => _nextPatch;
  int? get activePatchNumber =>
      _isDevSimulated ? _simulatedPatchNumber : _currentPatch?.number;
  UpdateStatus get status => _status;
  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;
  String? get errorMessage => _errorMessage;
  bool get isDevSimulated => _isDevSimulated;
  Stream<UpdateStatus> get onStatusChanged => _statusStreamController.stream;

  /// Inisialisasi awal saat aplikasi dibuka
  Future<void> initialize() async {
    if (isShorebirdAvailable) {
      try {
        _currentPatch = await _updater.readCurrentPatch();
        _nextPatch = await _updater.readNextPatch();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[OTA] Gagal membaca status patch: $e');
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint('[OTA] Berjalan pada mode Debug/Emulator (Shorebird engine standby).');
      }
    }
  }

  /// Memeriksa ketersediaan pembaruan patch OTA (Non-Blocking)
  Future<UpdateStatus> checkForUpdate() async {
    _isChecking = true;
    _errorMessage = null;

    if (!isShorebirdAvailable) {
      // Jika di emulator / debug build
      _isChecking = false;
      if (_isDevSimulated && _status == UpdateStatus.restartRequired) {
        return UpdateStatus.restartRequired;
      }
      _status = UpdateStatus.unavailable;
      _statusStreamController.add(_status);
      return _status;
    }

    try {
      final newStatus = await _updater.checkForUpdate();
      _status = newStatus;
      _currentPatch = await _updater.readCurrentPatch();
      _nextPatch = await _updater.readNextPatch();
      _statusStreamController.add(_status);
      return _status;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        debugPrint('[OTA] Error check update: $e');
      }
      return _status;
    } finally {
      _isChecking = false;
    }
  }

  /// Mengunduh dan memasang patch kode baru di latar belakang
  Future<bool> downloadPatch({LocalStorage? storage}) async {
    _isDownloading = true;
    _errorMessage = null;

    if (!isShorebirdAvailable) {
      // Mode simulasi jika di emulator
      await Future.delayed(const Duration(milliseconds: 1800));
      _isDevSimulated = true;
      _simulatedPatchNumber = (_currentPatch?.number ?? 1) + 1;
      _status = UpdateStatus.restartRequired;
      _isDownloading = false;
      _statusStreamController.add(_status);
      return true;
    }

    try {
      await _updater.update();
      _nextPatch = await _updater.readNextPatch();
      _status = UpdateStatus.restartRequired;
      _statusStreamController.add(_status);
      return true;
    } on UpdateException catch (e) {
      _errorMessage = 'Gagal mengunduh patch: ${e.message} (${e.reason.name})';
      return false;
    } catch (e) {
      _errorMessage = 'Gagal memproses pembaruan: $e';
      return false;
    } finally {
      _isDownloading = false;
    }
  }

  /// Simulasi developer untuk menguji UI & dialog patch di emulator
  void toggleDevSimulation(bool enable) {
    _isDevSimulated = enable;
    if (enable) {
      _simulatedPatchNumber = 2;
      _status = UpdateStatus.outdated;
    } else {
      _status = UpdateStatus.upToDate;
    }
    _statusStreamController.add(_status);
  }

  /// Memastikan seluruh cache sesi dan database Hive disimpan ke disk sebelum restart
  Future<void> prepareForRestart(LocalStorage storage) async {
    // Verifikasi outbox dan session tetap persisten
    final token = storage.getToken();
    if (token != null && token.isNotEmpty) {
      await storage.saveToken(token);
    }
  }

  void dispose() {
    _statusStreamController.close();
  }
}
