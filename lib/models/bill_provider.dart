class BillProvider {
  final String id;
  final String name;
  final String code;
  final String category;
  final String? logoUrl;
  final bool isActive;
  final String createdAt;

  BillProvider({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    this.logoUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory BillProvider.fromJson(Map<String, dynamic> json) {
    return BillProvider(
      id: json['id'] as String,
      name: (json['name'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      logoUrl: json['logo_url'] as String?,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: (json['created_at'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'category': category,
    'logo_url': logoUrl,
    'is_active': isActive,
    'created_at': createdAt,
  };
}