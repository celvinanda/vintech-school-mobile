class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final bool isSuperuser;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.isSuperuser,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      isSuperuser: json['is_superuser'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'full_name': fullName,
        'email': email,
        'is_superuser': isSuperuser,
      };
}

class ActiveSchoolModel {
  final String id;
  final String code;
  final String slug;
  final String name;
  final String level;
  final String? city;
  final String? primaryColor;
  final String role;
  final String title;

  ActiveSchoolModel({
    required this.id,
    required this.code,
    required this.slug,
    required this.name,
    required this.level,
    this.city,
    this.primaryColor,
    required this.role,
    required this.title,
  });

  bool get isStudent => role == 'STUDENT';
  bool get isTeacher => role == 'TEACHER';
  bool get isAdmin => role == 'SCHOOL_ADMIN' || role == 'SUPERADMIN';
  bool get isPrincipal => role == 'PRINCIPAL';
  bool get isParent => role == 'PARENT';

  factory ActiveSchoolModel.fromJson(Map<String, dynamic> json) {
    return ActiveSchoolModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      level: json['level'] as String? ?? '',
      city: json['city'] as String?,
      primaryColor: json['primary_color'] as String?,
      role: json['role'] as String? ?? 'GUEST',
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'slug': slug,
        'name': name,
        'level': level,
        'city': city,
        'primary_color': primaryColor,
        'role': role,
        'title': title,
      };
}

class SchoolMembershipModel {
  final String membershipId;
  final String role;
  final String roleLabel;
  final String title;
  final bool isPrimary;
  final String schoolId;
  final String schoolCode;
  final String schoolSlug;
  final String schoolName;
  final String schoolLevel;
  final String? schoolCity;

  SchoolMembershipModel({
    required this.membershipId,
    required this.role,
    required this.roleLabel,
    required this.title,
    required this.isPrimary,
    required this.schoolId,
    required this.schoolCode,
    required this.schoolSlug,
    required this.schoolName,
    required this.schoolLevel,
    this.schoolCity,
  });

  factory SchoolMembershipModel.fromJson(Map<String, dynamic> json) {
    final s = json['school'] as Map<String, dynamic>? ?? {};
    return SchoolMembershipModel(
      membershipId: json['membership_id'] as String? ?? '',
      role: json['role'] as String? ?? '',
      roleLabel: json['role_label'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isPrimary: json['is_primary'] == true,
      schoolId: s['id'] as String? ?? '',
      schoolCode: s['code'] as String? ?? '',
      schoolSlug: s['slug'] as String? ?? '',
      schoolName: s['name'] as String? ?? '',
      schoolLevel: s['level'] as String? ?? '',
      schoolCity: s['city'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'membership_id': membershipId,
        'role': role,
        'role_label': roleLabel,
        'title': title,
        'is_primary': isPrimary,
        'school': {
          'id': schoolId,
          'code': schoolCode,
          'slug': schoolSlug,
          'name': schoolName,
          'level': schoolLevel,
          'city': schoolCity,
        },
      };
}

class AuthTokenModel {
  final String accessToken;
  final String tokenType;
  final String devicePlatform;
  final String? expiresAt;

  AuthTokenModel({
    required this.accessToken,
    required this.tokenType,
    required this.devicePlatform,
    this.expiresAt,
  });

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) {
    return AuthTokenModel(
      accessToken: json['access_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'Bearer',
      devicePlatform: json['device_platform'] as String? ?? 'unknown',
      expiresAt: json['expires_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'device_platform': devicePlatform,
        'expires_at': expiresAt,
      };
}

class UserProfileResponse {
  final UserModel user;
  final ActiveSchoolModel? activeSchool;
  final List<SchoolMembershipModel> memberships;
  final AuthTokenModel? auth;

  UserProfileResponse({
    required this.user,
    this.activeSchool,
    required this.memberships,
    this.auth,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      activeSchool: json['active_school'] != null
          ? ActiveSchoolModel.fromJson(json['active_school'] as Map<String, dynamic>)
          : null,
      memberships: (json['memberships'] as List<dynamic>? ?? [])
          .map((m) => SchoolMembershipModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      auth: json['auth'] != null
          ? AuthTokenModel.fromJson(json['auth'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        if (activeSchool != null) 'active_school': activeSchool!.toJson(),
        'memberships': memberships.map((m) => m.toJson()).toList(),
        if (auth != null) 'auth': auth!.toJson(),
      };
}
