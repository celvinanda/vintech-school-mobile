import '../../../academic/data/models/student_model.dart';

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

  /// Mengambil NIS atau NIP murni dari format username multi-tenant
  /// (contoh: "siswa.sman1jkt.20261001" -> "20261001")
  String get cleanIdentifier {
    final raw = username.trim();
    if (raw.contains('.')) {
      return raw.split('.').last;
    }
    return raw;
  }

  /// Mengambil nama panggilan depan pengguna
  String get firstName {
    final cleaned = fullName.trim();
    if (cleaned.isEmpty) return username;
    final parts = cleaned.split(RegExp(r'\s+'));
    return parts.first;
  }

  /// Mengambil inisial 2 huruf untuk avatar
  String get initials {
    final cleaned = fullName.trim();
    if (cleaned.isEmpty) {
      return username.isNotEmpty ? username[0].toUpperCase() : 'U';
    }
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  /// Nomor telepon terdaftar pengguna (dengan fallback default)
  String get phone => '+62 812-3456-7890';

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
  bool get isStaffOrTeacher => isTeacher || isAdmin || isPrincipal;

  String get roleDisplayLabel {
    switch (role) {
      case 'STUDENT':
        return 'Siswa Aktif';
      case 'TEACHER':
        return 'Tenaga Pendidik';
      case 'SCHOOL_ADMIN':
      case 'SUPERADMIN':
        return 'Administrator Sekolah';
      case 'PRINCIPAL':
        return 'Kepala Sekolah';
      case 'PARENT':
        return 'Wali Murid';
      default:
        return role;
    }
  }

  String get cardBadgeTitle {
    if (isAdmin) return 'KARTU ADMINISTRATOR';
    if (isPrincipal) return 'KARTU KEPALA SEKOLAH';
    if (isTeacher) return 'KARTU TENAGA PENDIDIK';
    if (isParent) return 'KARTU WALI MURID';
    return 'KARTU PELAJAR DIGITAL';
  }

  /// Alias getter untuk kompatibilitas UI
  String get schoolName => name;
  String get classroomName => title.isNotEmpty ? title : 'Kelas X-IPA-1';

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
  final List<StudentModel> children;

  UserProfileResponse({
    required this.user,
    this.activeSchool,
    required this.memberships,
    this.auth,
    this.children = const [],
  });

  /// Mengambil data anak pertama/utama jika pengguna adalah akun Orang Tua
  StudentModel? get primaryChild => children.isNotEmpty ? children.first : null;

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
      children: (json['children'] as List<dynamic>? ?? [])
          .map((c) => StudentModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        if (activeSchool != null) 'active_school': activeSchool!.toJson(),
        'memberships': memberships.map((m) => m.toJson()).toList(),
        if (auth != null) 'auth': auth!.toJson(),
        'children': children.map((c) => c.toJson()).toList(),
      };
}
