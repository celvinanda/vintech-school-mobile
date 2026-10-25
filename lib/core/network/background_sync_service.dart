import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import '../../features/academic/data/academic_repository.dart';
import '../../features/academic/logic/attendance_cubit.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/billing/logic/billing_cubit.dart';
import '../../features/home/logic/home_cubit.dart';
import '../storage/local_storage.dart';
import '../update/ota_update_service.dart';

/// Engine Sinkronisasi Latar Belakang & App Lifecycle (Offline-First Coordinator).
/// Menangani:
/// 1. Auto-Flush Outbox Hive saat sinyal kembali tersedia (Heartbeat 30 detik).
/// 2. Silent Revalidation saat aplikasi kembali dari background (AppLifecycleState.resumed).
/// 3. Non-Blocking Shorebird OTA Code Push background detection.
/// 4. Concurrency Mutex Lock & Cooldown Throttling agar hemat baterai & kuota.
class BackgroundSyncService with WidgetsBindingObserver {
  final LocalStorage storage;
  final AcademicRepository academicRepository;
  final HomeCubit homeCubit;
  final AttendanceCubit attendanceCubit;
  final BillingCubit billingCubit;
  final UserProfileResponse profile;
  final OtaUpdateService? otaUpdateService;
  final void Function(int syncedCount)? onOutboxSynced;
  final void Function(UpdateStatus status)? onOtaStatusChanged;

  Timer? _heartbeatTimer;
  bool _isSyncing = false;
  DateTime _lastFullSyncTime = DateTime.now();

  static const Duration _syncCooldown = Duration(seconds: 45);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  BackgroundSyncService({
    required this.storage,
    required this.academicRepository,
    required this.homeCubit,
    required this.attendanceCubit,
    required this.billingCubit,
    required this.profile,
    this.otaUpdateService,
    this.onOutboxSynced,
    this.onOtaStatusChanged,
  });

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      _checkAndFlushOutboxOnly();
    });
    // Cek antrean outbox segera saat sesi dimulai
    _checkAndFlushOutboxOnly();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) {
        debugPrint('[BG SYNC] Aplikasi kembali aktif (resumed), memeriksa sinkronisasi...');
      }
      _onAppResumed();
    }
  }

  Future<void> _checkAndFlushOutboxOnly() async {
    if (_isSyncing) return;
    if (storage.hive.totalPendingOutbox == 0) return;

    _isSyncing = true;
    try {
      final synced = await academicRepository.flushOfflineOutbox();
      if (synced > 0) {
        if (kDebugMode) {
          debugPrint('[BG SYNC] Berhasil menyinkronkan $synced data presensi offline ke server.');
        }
        onOutboxSynced?.call(synced);
        final isStudent = profile.activeSchool?.isStudent == true;
        final isStaff = profile.activeSchool?.isStaffOrTeacher == true;
        await Future.wait([
          homeCubit.loadDashboard(),
          attendanceCubit.loadAttendances(
            studentNis: isStudent ? profile.user.cleanIdentifier : null,
            isStaff: isStaff,
          ),
        ]);
      }
    } catch (_) {
      // Tetap tenang di latar belakang jika masih offline
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _onAppResumed() async {
    if (_isSyncing) return;

    final now = DateTime.now();
    final hasPendingOutbox = storage.hive.totalPendingOutbox > 0;
    final cooldownElapsed = now.difference(_lastFullSyncTime) >= _syncCooldown;

    if (!hasPendingOutbox && !cooldownElapsed) {
      return;
    }

    _isSyncing = true;
    try {
      if (hasPendingOutbox) {
        final synced = await academicRepository.flushOfflineOutbox();
        if (synced > 0) {
          onOutboxSynced?.call(synced);
        }
      }

      final isStudent = profile.activeSchool?.isStudent == true;
      final isStaff = profile.activeSchool?.isStaffOrTeacher == true;
      final cleanId = profile.user.cleanIdentifier;

      await Future.wait([
        homeCubit.loadDashboard(),
        attendanceCubit.loadAttendances(
          studentNis: isStudent ? cleanId : null,
          isStaff: isStaff,
        ),
        billingCubit.loadInvoices(
          studentNis: isStudent ? cleanId : null,
          silent: true,
        ),
      ]);
      _lastFullSyncTime = DateTime.now();

      // Silent non-blocking check for Shorebird OTA Code Push
      if (otaUpdateService != null && otaUpdateService!.isShorebirdAvailable) {
        otaUpdateService!.checkForUpdate().then((status) {
          if (status == UpdateStatus.outdated) {
            otaUpdateService!.downloadPatch(storage: storage);
          } else if (status == UpdateStatus.restartRequired) {
            onOtaStatusChanged?.call(status);
          }
        }).catchError((_) {});
      }
    } catch (_) {
      // Abaikan error jaringan saat background resume (data Hive tetap tampil)
    } finally {
      _isSyncing = false;
    }
  }
}
