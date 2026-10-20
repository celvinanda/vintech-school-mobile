import 'package:flutter_bloc/flutter_bloc.dart';
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

    try {
      final profile = await _repository.getMe().timeout(const Duration(seconds: 4));
      emit(Authenticated(profile));
    } catch (_) {
      // If fetching user fails with saved token, revert to unauthenticated
      final cachedUserData = _storage.getUserData();
      if (cachedUserData != null) {
        try {
          final profile = UserProfileResponse.fromJson(cachedUserData);
          emit(Authenticated(profile));
          return;
        } catch (_) {}
      }
      emit(Unauthenticated(schoolCode: schoolCode, cachedSchool: cachedSchool));
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

  Future<void> logout() async {
    emit(AuthLoading('Keluar akun...'));
    await _repository.logout();
    final schoolCode = _storage.getSchoolCode();
    final cachedSchoolData = _storage.getSchoolData();
    final SchoolLookupModel? cachedSchool = cachedSchoolData != null
        ? SchoolLookupModel.fromJson(cachedSchoolData)
        : null;
    emit(Unauthenticated(schoolCode: schoolCode, cachedSchool: cachedSchool));
  }
}
