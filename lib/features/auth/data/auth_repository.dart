import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';

import '../../../core/network/api_client.dart';

import '../../../core/network/api_response.dart';

import '../../../core/storage/local_storage.dart';

import 'models/school_lookup_model.dart';

import 'models/user_model.dart';



class AuthRepository {

  final ApiClient _apiClient;

  final LocalStorage _storage;



  AuthRepository(this._apiClient, this._storage);



  Dio get _dio => _apiClient.dio;



  Future<SchoolLookupModel> lookupSchool(String code) async {

    try {

      final response = await _dio.get(

        ApiConstants.schoolLookup,

        queryParameters: {'code': code.trim()},

      );



      final envelope = ApiResponse<SchoolLookupModel>.fromJson(

        response.data as Map<String, dynamic>,

        (json) => SchoolLookupModel.fromJson(json as Map<String, dynamic>),

      );



      if (envelope.success && envelope.data != null) {

        // Save school code and basic data

        await _storage.saveSchoolCode(envelope.data!.code);

        await _storage.saveSchoolData(envelope.data!.toJson());

        return envelope.data!;

      }

      throw ApiException(envelope.message.isNotEmpty ? envelope.message : 'Sekolah tidak ditemukan');

    } on DioException catch (e) {

      if (e.error is ApiException) throw e.error as ApiException;

      throw ApiException('Gagal mencari sekolah: ${e.message}');

    }

  }



  Future<UserProfileResponse> login({

    required String username,

    required String password,

    String? schoolCode,

  }) async {

    try {

      final response = await _dio.post(

        ApiConstants.login,

        data: {

          'username': username.trim(),

          'password': password.trim(),

          if (schoolCode != null && schoolCode.trim().isNotEmpty) ...{

            'school_code': schoolCode.trim(),

          },

        },

      );



      final envelope = ApiResponse<UserProfileResponse>.fromJson(

        response.data as Map<String, dynamic>,

        (json) => UserProfileResponse.fromJson(json as Map<String, dynamic>),

      );



      if (envelope.success && envelope.data != null) {

        final profile = envelope.data!;

        // Persist token

        if (profile.auth != null) {

          await _storage.saveToken(profile.auth!.accessToken);

        }

        // Persist school code and school details

        if (profile.activeSchool != null) {

          await _storage.saveSchoolCode(profile.activeSchool!.code);

          await _storage.saveSchoolData(profile.activeSchool!.toJson());

        }

        // Persist user data

        await _storage.saveUserData(profile.toJson());



        return profile;

      }

      throw ApiException(envelope.message.isNotEmpty ? envelope.message : 'Gagal melakukan login');

    } on DioException catch (e) {

      if (e.error is ApiException) throw e.error as ApiException;

      throw ApiException('Gagal melakukan login: ${e.message}');

    }

  }



  Future<UserProfileResponse> getMe() async {

    try {

      final response = await _dio.get(ApiConstants.me);

      final envelope = ApiResponse<UserProfileResponse>.fromJson(

        response.data as Map<String, dynamic>,

        (json) => UserProfileResponse.fromJson(json as Map<String, dynamic>),

      );



      if (envelope.success && envelope.data != null) {

        await _storage.saveUserData(envelope.data!.toJson());

        return envelope.data!;

      }

      throw ApiException(envelope.message);

    } on DioException catch (e) {

      if (e.error is ApiException) throw e.error as ApiException;

      throw ApiException('Gagal mengambil profil: ${e.message}');

    }

  }



  Future<UserProfileResponse> switchSchool(String schoolCode) async {

    try {

      final response = await _dio.post(

        ApiConstants.switchSchool,

        data: {'school_code': schoolCode.trim()},

      );



      final envelope = ApiResponse<UserProfileResponse>.fromJson(

        response.data as Map<String, dynamic>,

        (json) => UserProfileResponse.fromJson(json as Map<String, dynamic>),

      );



      if (envelope.success && envelope.data != null) {

        await _storage.saveSchoolCode(schoolCode);

        await _storage.saveUserData(envelope.data!.toJson());

        return envelope.data!;

      }

      throw ApiException(envelope.message);

    } on DioException catch (e) {

      if (e.error is ApiException) throw e.error as ApiException;

      throw ApiException('Gagal berpindah sekolah: ${e.message}');

    }

  }



  Future<UserProfileResponse> updateProfile({

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

      final response = await _dio.post(

        ApiConstants.editProfile,

        data: {

          'full_name': fullName.trim(),

          'email': email.trim(),

          'phone': phone.trim(),

          if (parentRelationship != null && parentRelationship.isNotEmpty)

            'parent_relationship': parentRelationship.trim(),

          if (nik != null && nik.isNotEmpty) 'nik': nik.trim(),

          if (occupation != null && occupation.isNotEmpty)

            'occupation': occupation.trim(),

          if (emergencyPhone != null && emergencyPhone.isNotEmpty)

            'emergency_phone': emergencyPhone.trim(),

          if (address != null && address.isNotEmpty)

            'address': address.trim(),

        },

      );



      final envelope = ApiResponse<UserProfileResponse>.fromJson(

        response.data as Map<String, dynamic>,

        (json) => UserProfileResponse.fromJson(json as Map<String, dynamic>),

      );



      if (envelope.success && envelope.data != null) {

        final profile = envelope.data!;

        final enrichedUser = profile.user.copyWith(

          parentRelationship: parentRelationship,

          nik: nik,

          occupation: occupation,

          emergencyPhone: emergencyPhone,

          address: address,

        );

        final enrichedProfile = profile.copyWith(user: enrichedUser);



        await _storage.saveUserData(enrichedProfile.toJson());

        return enrichedProfile;

      }

      throw ApiException(envelope.message.isNotEmpty

          ? envelope.message

          : 'Gagal memperbarui profil');

    } on DioException catch (e) {

      if (e.error is ApiException) throw e.error as ApiException;

      throw ApiException('Gagal memperbarui profil: ${e.message}');

    }

  }



  Future<UserProfileResponse> setupCredentials({
    required String username,
    required String password,
    String? confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.setupCredentials,
        data: {
          'username': username.trim(),
          'password': password.trim(),
          if (confirmPassword != null && confirmPassword.isNotEmpty)
            'confirm_password': confirmPassword.trim(),
        },
      );

      final envelope = ApiResponse<UserProfileResponse>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => UserProfileResponse.fromJson(json as Map<String, dynamic>),
      );

      if (envelope.success && envelope.data != null) {
        final profile = envelope.data!;
        await _storage.saveUserData(profile.toJson());
        return profile;
      }
      throw ApiException(envelope.message.isNotEmpty
          ? envelope.message
          : 'Gagal mengatur username dan kata sandi.');
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Gagal mengatur username dan kata sandi: ${e.message}');
    }
  }

  Future<void> logout({bool clearLocalCache = false}) async {

    try {

      await _dio.post(ApiConstants.logout);

    } catch (_) {

      // Continue clearing session locally regardless of server error

    } finally {

      if (clearLocalCache) {

        final schoolCode = _storage.getSchoolCode();

        final schoolData = _storage.getSchoolData();

        await _storage.resetAll();

        // Preserve school branding for seamless login UX

        if (schoolCode != null) await _storage.saveSchoolCode(schoolCode);

        if (schoolData != null) await _storage.saveSchoolData(schoolData);

      } else {

        await _storage.clearAllSession();

      }

    }

  }

}

