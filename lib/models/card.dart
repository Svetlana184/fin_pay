class Card {
  final String id;
  final String? userId; // только в /cards/:id через JOIN
  final String? cardNumber; // полный номер — только в /cards/:id
  final String cardType;
  final double balance;
  final String currency;
  final String status;
  final String? expiresAt; // приходит как строка "MM/YY" из /cards/:id
  final String? createdAt;

  // Поля только из GET /api/cards/:id
  final String? holderName;
  final String? validFrom; // "MM/YY"
  final String? expiresAtFormatted; // "MM/YY"
  final String? maskedNumber; // "4756 **** **** 9018"
  final String? last4Digits; // "9018"

  Card({
    required this.id,
    this.userId,
    this.cardNumber,
    required this.cardType,
    required this.balance,
    required this.currency,
    required this.status,
    this.expiresAt,
    this.createdAt,
    this.holderName,
    this.validFrom,
    this.expiresAtFormatted,
    this.maskedNumber,
    this.last4Digits,
  });

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      cardNumber: json['card_number'] as String?,
      cardType: (json['card_type'] as String?) ?? 'Unknown',
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      currency: (json['currency'] as String?) ?? 'RUB',
      status: (json['status'] as String?) ?? 'active',
      expiresAt: json['expires_at'] as String?,
      createdAt: json['created_at'] as String?,
      holderName: json['holder_name'] as String?,
      validFrom: json['valid_from'] as String?,
      expiresAtFormatted: json['expires_at_formatted'] as String?,
      maskedNumber: json['masked_number'] as String?,
      last4Digits: json['last_4_digits'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'card_number': cardNumber,
    'card_type': cardType,
    'balance': balance,
    'currency': currency,
    'status': status,
    'expires_at': expiresAt,
    'created_at': createdAt,
    'holder_name': holderName,
    'valid_from': validFrom,
    'expires_at_formatted': expiresAtFormatted,
    'masked_number': maskedNumber,
    'last_4_digits': last4Digits,
  };

  bool get isActive => status == 'active';
  bool get isBlocked => status == 'blocked';

  /// Отображаемый номер карты (маскированный)
  String get displayNumber {
    if (maskedNumber != null) return maskedNumber!;
    if (last4Digits != null) return '•••• •••• •••• $last4Digits';
    return '•••• •••• •••• ••••';
  }
}