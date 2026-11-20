class CreditCardTransaction {
  final String id;
  final String title;
  final String date;
  final double amount;
  final String icon; // camera, tv, shopping, etc.
  final String iconColor;

  const CreditCardTransaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  factory CreditCardTransaction.fromJson(Map<String, dynamic> json) {
    return CreditCardTransaction(
      id: json['id'] as String,
      title: json['counterparty_name'] as String? ?? json['title'] as String? ?? 'Transaction',
      date: json['created_at'] as String? ?? json['date'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      icon: json['category_icon'] as String? ?? 'shopping_cart',
      iconColor: json['category_color'] as String? ?? '0xFF3B2F9F',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date,
    'amount': amount,
    'icon': icon,
    'icon_color': iconColor,
  };

  String get formattedAmount => '-\$${amount.toStringAsFixed(0)}';
  String get formattedDate => date;
}

class CreditCardInfo {
  final String id;
  final String holderName;
  final String cardType;
  final String cardNumber;
  final String maskedNumber;
  final String last4Digits;
  final double balance;
  final String currency;
  final String status;

  const CreditCardInfo({
    required this.id,
    required this.holderName,
    required this.cardType,
    required this.cardNumber,
    required this.maskedNumber,
    required this.last4Digits,
    required this.balance,
    required this.currency,
    required this.status,
  });

  factory CreditCardInfo.fromJson(Map<String, dynamic> json) {
    return CreditCardInfo(
      id: json['id'] as String,
      holderName: json['holder_name'] as String? ?? 'User',
      cardType: json['card_type'] as String? ?? 'VISA',
      cardNumber: json['card_number'] as String? ?? '',
      maskedNumber: json['masked_number'] as String? ?? '**** **** **** ****',
      last4Digits: json['last_4_digits'] as String? ?? '0000',
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'active',
    );
  }
}