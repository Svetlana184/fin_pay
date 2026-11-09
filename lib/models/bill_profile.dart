class BillProfile {
  final String id;
  final String profileName;
  final String accountCode;
  final String recipientName;
  final String? recipientAddress;
  final String? recipientPhone;
  final bool isFavorite;

  // JOIN-поля из bill_providers
  final String? providerName;
  final String? category; // категория провайдера
  final String? logoUrl;

  BillProfile({
    required this.id,
    required this.profileName,
    required this.accountCode,
    required this.recipientName,
    this.recipientAddress,
    this.recipientPhone,
    required this.isFavorite,
    this.providerName,
    this.category,
    this.logoUrl,
  });

  factory BillProfile.fromJson(Map<String, dynamic> json) {
    return BillProfile(
      id: json['id'] as String,
      profileName: (json['profile_name'] as String?) ?? '',
      accountCode: (json['account_code'] as String?) ?? '',
      recipientName: (json['recipient_name'] as String?) ?? '',
      recipientAddress: json['recipient_address'] as String?,
      recipientPhone: json['recipient_phone'] as String?,
      isFavorite: (json['is_favorite'] as bool?) ?? false,
      providerName: json['provider_name'] as String?,
      category: json['category'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'profile_name': profileName,
    'account_code': accountCode,
    'recipient_name': recipientName,
    'recipient_address': recipientAddress,
    'recipient_phone': recipientPhone,
    'is_favorite': isFavorite,
    'provider_name': providerName,
    'category': category,
    'logo_url': logoUrl,
  };
}