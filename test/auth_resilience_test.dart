import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vintech_school_mobile/core/network/api_response.dart';
import 'package:vintech_school_mobile/core/storage/hive_cache_service.dart';
import 'package:vintech_school_mobile/core/storage/local_storage.dart';
import 'package:vintech_school_mobile/features/auth/data/auth_repository.dart';
import 'package:vintech_school_mobile/features/auth/data/models/school_lookup_model.dart';
import 'package:vintech_school_mobile/features/auth/data/models/user_model.dart';
import 'package:vintech_school_mobile/features/auth/logic/auth_cubit.dart';
import 'package:vintech_school_mobile/features/auth/logic/auth_state.dart';

class MockAuthRepository implements AuthRepository {
  Future<UserProfileResponse> Function()? onGetMe;

  @override
  Future<UserProfileResponse> getMe() async {
    if (onGetMe != null) return await onGetMe!();
    throw ApiException('Not implemented');
  }

  @override
  Future<SchoolLookupModel> lookupSchool(String code) => throw UnimplementedError();

  @override
  Future<UserProfileResponse> login({
    required String username,
    required String password,
    String? schoolCode,
  }) => throw UnimplementedError();

  @override
  Future<UserProfileResponse> switchSchool(String schoolCode) => throw UnimplementedError();

  @override
  Future<UserProfileResponse> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? parentRelationship,
    String? nik,
    String? occupation,
    String? emergencyPhone,
    String? address,
  }) => throw UnimplementedError();

  @override
  Future<UserProfileResponse> setupCredentials({
    required String username,
    required String password,
    String? confirmPassword,
  }) => throw UnimplementedError();

  @override
  Future<void> logout({bool clearLocalCache = false}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('vintech_test_hive_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    try {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('Token security: Auto-migration from legacy plaintext SharedPreferences to FlutterSecureStorage', () async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'legacy-plain-jwt-token-xyz',
    });
    FlutterSecureStorage.setMockInitialValues({});

    final storage = await LocalStorage.init(currentVersionOverride: '2.4.0+1');

    // 1. Token terbaca mulus
    expect(storage.getToken(), 'legacy-plain-jwt-token-xyz');

    // 2. Token tersimpan aman di Secure Storage
    const secureStorage = FlutterSecureStorage();
    final secureToken = await secureStorage.read(key: 'auth_token');
    expect(secureToken, 'legacy-plain-jwt-token-xyz');

    // 3. Token plaintext di SharedPreferences dihapus demi standar keamanan
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), isNull);
  });

  test('Version-Aware update detection: Fresh install vs returning vs app update', () async {
    // Skenario 1: First Launch (Belum pernah tersimpan versi)
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final storageFirstLaunch = await LocalStorage.init(currentVersionOverride: '2.4.0+1');
    expect(storageFirstLaunch.isReturningUser(), isFalse,
        reason: 'Pengguna baru harus mendapatkan sambutan branding penuh');

    // Pengguna menyelesaikan splash dan tercatat
    await storageFirstLaunch.markUserVisited();

    // Skenario 2: Returning Daily User (Versi sama persis)
    final storageDailyUser = await LocalStorage.init(currentVersionOverride: '2.4.0+1');
    expect(storageDailyUser.isReturningUser(), isTrue,
        reason: 'Pengguna harian mendapatkan dwell cepat (~400ms) bebas pajak waktu');

    // Skenario 3: Post-Update Launch (Aplikasi diperbarui dari toko aplikasi)
    final storagePostUpdate = await LocalStorage.init(currentVersionOverride: '2.5.0+2');
    expect(storagePostUpdate.isReturningUser(), isFalse,
        reason: 'Setelah update aplikasi, pengguna disajikan branding penuh & pembaruan versi');
  });

  test('Auth Resilience: HTTP 401 triggers clean forced-logout with friendly message', () async {
    final prefs = await SharedPreferences.getInstance();
    final hive = await HiveCacheService.init();
    const secureStorage = FlutterSecureStorage();

    final storage = LocalStorage(
      prefs,
      hive,
      secureStorage,
      '2.4.0+1',
      true,
      'expired-jwt-token',
    );

    final mockRepo = MockAuthRepository();
    mockRepo.onGetMe = () async {
      throw ApiException('Token expired or revoked', statusCode: 401);
    };

    final authCubit = AuthCubit(mockRepo, storage);

    final states = <AuthState>[];
    final sub = authCubit.stream.listen(states.add);

    await authCubit.checkSession();

    await Future.delayed(const Duration(milliseconds: 50));
    await sub.cancel();

    expect(authCubit.state, isA<Unauthenticated>());
    final unauthState = authCubit.state as Unauthenticated;
    expect(unauthState.sessionExpiredMessage, contains('Sesi Anda telah berakhir'));
    expect(storage.getToken(), isNull, reason: 'Token kedaluwarsa harus dihapus dari storage');
  });

  test('Auth Resilience: Network 5xx or Connection Timeout maintains cached Authenticated state', () async {
    final prefs = await SharedPreferences.getInstance();
    final hive = await HiveCacheService.init();
    const secureStorage = FlutterSecureStorage();

    final mockProfile = UserProfileResponse(
      user: UserModel(
        id: 1,
        username: 'siswa.test',
        fullName: 'Budi Santoso',
        email: 'budi@test.com',
        isSuperuser: false,
      ),
      memberships: [],
    );

    final storage = LocalStorage(
      prefs,
      hive,
      secureStorage,
      '2.4.0+1',
      true,
      'valid-cached-token',
    );

    // Simpan profil di Hive session
    await storage.saveUserData(mockProfile.toJson());

    final mockRepo = MockAuthRepository();
    // Simulasikan server down (502 Bad Gateway / Network Connection Error)
    mockRepo.onGetMe = () async {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/me/'),
        type: DioExceptionType.connectionTimeout,
        error: ApiException('Koneksi timeout', statusCode: 504),
      );
    };

    final authCubit = AuthCubit(mockRepo, storage);

    final states = <AuthState>[];
    final sub = authCubit.stream.listen(states.add);

    await authCubit.checkSession();

    await Future.delayed(const Duration(milliseconds: 50));
    await sub.cancel();

    // Sesi offline-first HARUS dipertahankan!
    expect(authCubit.state, isA<Authenticated>(),
        reason: 'Guru atau siswa dengan sinyal buruk atau server 5xx tidak boleh ditendang keluar');
    final authState = authCubit.state as Authenticated;
    expect(authState.profile.user.fullName, 'Budi Santoso');
    expect(storage.getToken(), 'valid-cached-token', reason: 'Token valid tidak boleh dihapus');
  });
}
