class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String audience;
  final String audienceDisplay;
  final bool isPinned;
  final String createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.audience,
    required this.audienceDisplay,
    required this.isPinned,
    required this.createdAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      audience: json['audience'] as String? ?? 'ALL',
      audienceDisplay: json['audience_display'] as String? ?? 'Semua',
      isPinned: json['is_pinned'] == true,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'audience': audience,
    'audience_display': audienceDisplay,
    'is_pinned': isPinned,
    'created_at': createdAt,
  };
}

class AttendanceTodaySummary {
  final String date;
  final int presentCount;
  final int izinCount;
  final int sakitCount;
  final int alpaCount;
  final int recordedCount;
  final double attendanceRate;

  AttendanceTodaySummary({
    required this.date,
    required this.presentCount,
    required this.izinCount,
    required this.sakitCount,
    required this.alpaCount,
    required this.recordedCount,
    required this.attendanceRate,
  });

  factory AttendanceTodaySummary.fromJson(Map<String, dynamic> json) {
    return AttendanceTodaySummary(
      date: json['date'] as String? ?? '',
      presentCount: json['present_count'] as int? ?? 0,
      izinCount: json['izin_count'] as int? ?? 0,
      sakitCount: json['sakit_count'] as int? ?? 0,
      alpaCount: json['alpa_count'] as int? ?? 0,
      recordedCount: json['recorded_count'] as int? ?? 0,
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble() ?? 100.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'present_count': presentCount,
    'izin_count': izinCount,
    'sakit_count': sakitCount,
    'alpa_count': alpaCount,
    'recorded_count': recordedCount,
    'attendance_rate': attendanceRate,
  };
}

class SchoolMajorModel {
  final String code;
  final String name;
  final String description;
  final List<String> tags;

  SchoolMajorModel({
    required this.code,
    required this.name,
    required this.description,
    required this.tags,
  });

  factory SchoolMajorModel.fromJson(Map<String, dynamic> json) {
    return SchoolMajorModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'description': description,
    'tags': tags,
  };
}

class SchoolTeacherModel {
  final String id;
  final String name;
  final String nip;
  final String specialization;
  final String phone;
  final String email;

  SchoolTeacherModel({
    required this.id,
    required this.name,
    required this.nip,
    required this.specialization,
    required this.phone,
    required this.email,
  });

  factory SchoolTeacherModel.fromJson(Map<String, dynamic> json) {
    return SchoolTeacherModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nip: json['nip'] as String? ?? '',
      specialization: json['specialization'] as String? ?? 'Tenaga Pendidik',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nip': nip,
    'specialization': specialization,
    'phone': phone,
    'email': email,
  };
}

class SchoolDashboardModel {
  final String id;
  final String code;
  final String name;
  final String npsn;
  final String levelDisplay;
  final String? primaryColor;
  final String? logoUrl;
  final String principalName;
  final String principalNip;
  final String schoolStatus;
  final String accreditation;
  final String accreditationDisplay;
  final String foundationName;
  final String city;
  final String district;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String motto;
  final String vision;
  final List<String> missions;
  final List<SchoolMajorModel> majors;
  final List<SchoolTeacherModel> teachers;
  final List<String> facilities;
  final int totalStudents;
  final int totalTeachers;
  final int totalClassrooms;
  final String currentAcademicYear;
  final AttendanceTodaySummary attendanceToday;
  final List<AnnouncementModel> announcements;

  SchoolDashboardModel({
    required this.id,
    required this.code,
    required this.name,
    this.npsn = '',
    required this.levelDisplay,
    this.primaryColor,
    this.logoUrl,
    this.principalName = 'Drs. Supiyanto',
    this.principalNip = '',
    this.schoolStatus = 'SWASTA',
    this.accreditation = 'A',
    this.accreditationDisplay = 'Akreditasi A (Unggul)',
    this.foundationName = '',
    this.city = '',
    this.district = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.motto = '',
    this.vision = '',
    this.missions = const [],
    this.majors = const [],
    this.teachers = const [],
    this.facilities = const [],
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalClassrooms,
    required this.currentAcademicYear,
    required this.attendanceToday,
    required this.announcements,
  });

  factory SchoolDashboardModel.fromJson(Map<String, dynamic> json) {
    final branding = json['branding'] as Map<String, dynamic>? ?? {};
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final att = summary['attendance_today'] as Map<String, dynamic>? ?? {};
    final rawAnnouncements =
        json['recent_announcements'] as List<dynamic>? ?? [];

    return SchoolDashboardModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      npsn: json['npsn'] as String? ?? '',
      levelDisplay: json['level_display'] as String? ?? '',
      primaryColor: branding['primary_color'] as String?,
      logoUrl: branding['logo_url'] as String?,
      principalName: json['principal_name'] as String? ?? 'Drs. Supiyanto',
      principalNip: json['principal_nip'] as String? ?? '',
      schoolStatus: json['school_status'] as String? ?? 'SWASTA',
      accreditation: json['accreditation'] as String? ?? 'A',
      accreditationDisplay:
          json['accreditation_display'] as String? ?? 'Akreditasi A (Unggul)',
      foundationName: json['foundation_name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      district: json['district'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
      motto: json['motto'] as String? ?? '',
      vision: json['vision'] as String? ?? '',
      missions: (json['missions'] as List<dynamic>?)
              ?.map((m) => m.toString())
              .toList() ??
          [],
      majors: (json['majors'] as List<dynamic>?)
              ?.map((m) =>
                  SchoolMajorModel.fromJson(Map<String, dynamic>.from(m as Map)))
              .toList() ??
          [],
      teachers: (json['teachers'] as List<dynamic>?)
              ?.map((t) =>
                  SchoolTeacherModel.fromJson(Map<String, dynamic>.from(t as Map)))
              .toList() ??
          [],
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((f) => f.toString())
              .toList() ??
          [],
      totalStudents: summary['total_students'] as int? ?? 0,
      totalTeachers: summary['total_teachers'] as int? ?? 0,
      totalClassrooms: summary['total_classrooms'] as int? ?? 0,
      currentAcademicYear: summary['current_academic_year'] as String? ?? '',
      attendanceToday: AttendanceTodaySummary.fromJson(att),
      announcements: rawAnnouncements
          .map(
            (a) =>
                AnnouncementModel.fromJson(Map<String, dynamic>.from(a as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'npsn': npsn,
    'level_display': levelDisplay,
    'principal_name': principalName,
    'principal_nip': principalNip,
    'school_status': schoolStatus,
    'accreditation': accreditation,
    'accreditation_display': accreditationDisplay,
    'foundation_name': foundationName,
    'city': city,
    'district': district,
    'address': address,
    'phone': phone,
    'email': email,
    'website': website,
    'motto': motto,
    'vision': vision,
    'missions': missions,
    'majors': majors.map((m) => m.toJson()).toList(),
    'teachers': teachers.map((t) => t.toJson()).toList(),
    'facilities': facilities,
    'branding': {'primary_color': primaryColor, 'logo_url': logoUrl},
    'summary': {
      'total_students': totalStudents,
      'total_teachers': totalTeachers,
      'total_classrooms': totalClassrooms,
      'current_academic_year': currentAcademicYear,
      'attendance_today': attendanceToday.toJson(),
    },
    'recent_announcements': announcements.map((a) => a.toJson()).toList(),
  };
}
