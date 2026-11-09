class User {
  final String id;
  final String phone;
  final String fullName;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  // JOIN-поля из user_profiles (приходят в /users/me)
  final String? email;
  final String? city;
  final String? country;
  final String? avatarUrl;
  final bool? isVerified;
  final int? verificationLevel;

  User({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.email,
    this.city,
    this.country,
    this.avatarUrl,
    this.isVerified,
    this.verificationLevel,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: (json['phone'] as String?) ?? '',
      fullName: (json['full_name'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'active',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      email: json['email'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool?,
      verificationLevel: json['verification_level'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone': phone,
    'full_name': fullName,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'email': email,
    'city': city,
    'country': country,
    'avatar_url': avatarUrl,
    'is_verified': isVerified,
    'verification_level': verificationLevel,
  };
}