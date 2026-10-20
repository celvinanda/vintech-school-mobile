class SchoolLookupModel {
  final String id;
  final String code;
  final String slug;
  final String name;
  final String? npsn;
  final String level;
  final String levelDisplay;
  final String tier;
  final String tierDisplay;
  final String? principalName;
  final String? city;
  final String? address;
  final String? phone;
  final String? email;
  final String? primaryColor;
  final String? logoUrl;
  final bool vintechPaymentConfigured;

  SchoolLookupModel({
    required this.id,
    required this.code,
    required this.slug,
    required this.name,
    this.npsn,
    required this.level,
    required this.levelDisplay,
    required this.tier,
    required this.tierDisplay,
    this.principalName,
    this.city,
    this.address,
    this.phone,
    this.email,
    this.primaryColor,
    this.logoUrl,
    required this.vintechPaymentConfigured,
  });

  factory SchoolLookupModel.fromJson(Map<String, dynamic> json) {
    final branding = json['branding'] as Map<String, dynamic>?;
    return SchoolLookupModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      npsn: json['npsn'] as String?,
      level: json['level'] as String? ?? '',
      levelDisplay: json['level_display'] as String? ?? '',
      tier: json['tier'] as String? ?? '',
      tierDisplay: json['tier_display'] as String? ?? '',
      principalName: json['principal_name'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      primaryColor: branding?['primary_color'] as String?,
      logoUrl: branding?['logo_url'] as String?,
      vintechPaymentConfigured: json['vintech_payment_configured'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'slug': slug,
      'name': name,
      'npsn': npsn,
      'level': level,
      'level_display': levelDisplay,
      'tier': tier,
      'tier_display': tierDisplay,
      'principal_name': principalName,
      'city': city,
      'address': address,
      'phone': phone,
      'email': email,
      'branding': {
        'primary_color': primaryColor,
        'logo_url': logoUrl,
      },
      'vintech_payment_configured': vintechPaymentConfigured,
    };
  }
}
