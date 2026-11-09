class UserProfile {
  final String? email;
  final String? city;
  final String? country;
  final String? avatarUrl;
  final bool? isVerified;
  final int? verificationLevel;

  UserProfile({
    this.email,
    this.city,
    this.country,
    this.avatarUrl,
    this.isVerified,
    this.verificationLevel,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool?,
      verificationLevel: json['verification_level'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'city': city,
    'country': country,
    'avatar_url': avatarUrl,
    'is_verified': isVerified,
    'verification_level': verificationLevel,
  };
}