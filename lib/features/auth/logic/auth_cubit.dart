import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/local_storage.dart';
import '../data/auth_repository.dart';
import '../data/models/school_lookup_model.dart';
import '../data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final LocalStorage _storage;

  AuthCubit(this._repository, this._storage) : super(AuthInitial());

  Future<void> checkSession() async {
    emit(AuthLoading('Memeriksa sesi login...'));
    final token = _storage.getToken();
    final schoolCode = _storage.getSchoolCode();
    final cachedSchoolData = _storage.getSchoolData();
    final SchoolLookupModel? cachedSchool = cachedSchoolData != null
        ? SchoolLookupModel.fromJson(cachedSchoolData)
        : null;

    if (token == null || token.isEmpty) {
      emit(Unauthenticated(schoolCode: schoolCode, cachedSchool: cachedSchool));
      return;
    }

    // 1. Offline-First Instant Auth: Jika profil tersimpan di Hive, aktifkan instan (~1-5 ms)
    final cachedUserData = _storage.getUserData();
    if (cachedUserData != null) {
      try {
        final cachedProfile = UserProfileResponse.fromJson(cachedUserData);
        emit(Authenticated(cachedProfile));
      } catch (_) {}
    }

    // 2. Sinkronisasi profil terbaru di latar belakang jika online (timeout 4 detik)
    try {
      final profile = await _repository.getMe().timeout(const Duration(seconds: 4));
      emit(Authenticated(profile));
    } catch (e) {
      int? statusCode;
      if (e is ApiException) {
        statusCode = e.statusCode;
      } else if (e is DioException) {
        statusCode = e.response?.statusCode ??
            (e.error is ApiException ? (e.error as ApiException).statusCode : null);
      }

      // Klasifikasi error yang ketat: HANYA HTTP 401 murni yang memicu logout paksa
      final is401 = statusCode == 401 ||
          e.toString().toLowerCase().contains('401') ||
          e.toString().toLowerCase().contains('unauthorized');

      if (is401) {
        // Token dicabut atau kadaluwarsa di server -> hapus sesi dan arahkan login ulang dengan pesan ramah
        if (kDebugMode) {
          debugPrint('[AUTH] HTTP 401 terdeteksi: Sesi telah kedaluwarsa. Mengarahkan ke Login...');
        }
        await _storage.clearAllSession();
        emit(Unauthenticated(
          schoolCode: schoolCode,
          cachedSchool: cachedSchool,
          sessionExpiredMessage: 'Sesi Anda telah berakhir. Silakan masuk kembali.',
        ));
      } else if (state is! Authenticated) {
        // Jika TIDAK punya data cache offline dan jaringan bermasalah -> arahkan ke Login
        emit(Unauthenticated(schoolCode: schoolCode, cachedSchool: cachedSchool));
      } else {
        // PERTAHANKAN SESI OFFLINE-FIRST:
        // Jika user sudah masuk dari data lokal Hive, kegagalan jaringan (timeout, 5xx server, tanpa internet)
        // TIDAK BOLEH mengeluarkan user dari aplikasi.
        if (kDebugMode) {
          debugPrint('[AUTH] Background sync profil gagal ($e), mempertahankan sesi lokal offline-first.');
        }
      }
    }
  }

  Future<void> lookupSchool(String code) async {
    emit(AuthLoading('Mencari sekolah...'));
    try {
      final school = await _repository.lookupSchool(code);
      emit(SchoolLookupSuccess(school));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> login(String username, String password, {String? schoolCode}) async {
    emit(AuthLoading('Masuk ke akun...'));
    try {
      final profile = await _repository.login(
        username: username,
        password: password,
        schoolCode: schoolCode,
      );
      emit(Authenticated(profile));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> switchSchool(String schoolCode) async {
    emit(AuthLoading('Beralih sekolah...'));
    try {
      final profile = await _repository.switchSchool(schoolCode);
      emit(Authenticated(profile));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? parentRelationship,
    String? nik,
    String? occupation,
    String? emergencyPhone,
    String? address,
  }) async {
    try {
      final updatedProfile = await _repository.updateProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        parentRelationship: parentRelationship,
        nik: nik,
        occupation: occupation,
        emergencyPhone: emergencyPhone,
        address: address,
      );
      emit(Authenticated(updatedProfile));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout({bool clearLocalCache = false}) async {
    emit(AuthLoading('Keluar akun...'));
    await _repository.logout(clearLocalCache: clearLocalCache);
    final schoolCode = _storage.getSchoolCode();
    final cachedSchoolData = _storage.getSchoolData();
    final SchoolLookupModel? cachedSchool = cachedSchoolData != null
        ? SchoolLookupModel.fromJson(cachedSchoolData)
        : null;
    emit(Unauthenticated(schoolCode: schoolCode, cachedSchool: cachedSchool));
  }
}
