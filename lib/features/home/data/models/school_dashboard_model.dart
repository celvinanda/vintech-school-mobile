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

class SchoolDashboardModel {
  final String id;
  final String code;
  final String name;
  final String levelDisplay;
  final String? primaryColor;
  final String? logoUrl;
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
    required this.levelDisplay,
    this.primaryColor,
    this.logoUrl,
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
      levelDisplay: json['level_display'] as String? ?? '',
      primaryColor: branding['primary_color'] as String?,
      logoUrl: branding['logo_url'] as String?,
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
    'level_display': levelDisplay,
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
