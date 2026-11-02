/// Konstanta resmi identitas, penomoran versi SemVer, dan lisensi Vintech School Enterprise.
class AppConstants {
  static const String appName = 'Vintech School Mobile';
  static const String edition = 'Enterprise Edition';
  
  /// Semantic Versioning standar industri (Major.Minor.Patch)
  /// - Major 2: Arsitektur Modern Offline-First, Hive CE Multi-box, Multi-Tenant RBAC
  /// - Minor 4: Modul Akademik Terpadu, Rapor Digital, Otomasi Tagihan SPP & Parent Portal
  /// - Patch 0: Kestabilan engine, OTA live code push & enkripsi kredensial
  static const String appVersion = '2.4.0';
  static const String buildNumber = '2401';
  static const String releaseChannel = 'Stable Production';

  /// Format representasi versi formal untuk UI dan Audit
  static String get versionDisplay => 'v$appVersion ($edition)';
  static String get fullBuildTag => 'v$appVersion+$buildNumber';
  static const String legalCopyright =
      '© 2026 PT Vintech Global Solusindo. Seluruh hak cipta dilindungi undang-undang.';
  static const String securityStandard =
      'Enkripsi TLS 1.3 • Multi-Tenant Cloud Architecture';
}
