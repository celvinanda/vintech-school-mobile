import '../data/models/school_lookup_model.dart';
import '../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {
  final String? message;
  AuthLoading([this.message]);
}

class SchoolLookupSuccess extends AuthState {
  final SchoolLookupModel school;
  SchoolLookupSuccess(this.school);
}

class Authenticated extends AuthState {
  final UserProfileResponse profile;
  Authenticated(this.profile);
}

class Unauthenticated extends AuthState {
  final String? schoolCode;
  final SchoolLookupModel? cachedSchool;
  final String? sessionExpiredMessage;

  Unauthenticated({
    this.schoolCode,
    this.cachedSchool,
    this.sessionExpiredMessage,
  });
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
