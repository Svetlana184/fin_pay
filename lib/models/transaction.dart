class Transaction {
  final String id;
  final String? accountId;
  final String? counterpartyName;
  final String? categoryId;
  final double amount;
  final String currency;
  final String status;
  final String? description;
  final String createdAt;

  // JOIN-поля из API
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryType; // 'income' | 'expense'
  final String? cardMasked;

  Transaction({
    required this.id,
    this.accountId,
    this.counterpartyName,
    this.categoryId,
    required this.amount,
    required this.currency,
    required this.status,
    this.description,
    required this.createdAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryType,
    this.cardMasked,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      accountId: json['account_id'] as String?,
      counterpartyName: json['counterparty_name'] as String?,
      categoryId: json['category_id'] as String?,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: (json['currency'] as String?) ?? 'RUB',
      status: (json['status'] as String?) ?? 'completed',
      description: json['description'] as String?,
      createdAt: (json['created_at'] as String?) ?? DateTime.now().toIso8601String(),
      categoryName: json['category_name'] as String?,
      categoryIcon: json['category_icon'] as String?,
      categoryType: json['category_type'] as String?,
      cardMasked: json['card_masked'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'account_id': accountId,
    'counterparty_name': counterpartyName,
    'category_id': categoryId,
    'amount': amount,
    'currency': currency,
    'status': status,
    'description': description,
    'created_at': createdAt,
    'category_name': categoryName,
    'category_icon': categoryIcon,
    'category_type': categoryType,
    'card_masked': cardMasked,
  };

  bool get isIncome => amount > 0;
  bool get isExpense => amount < 0;
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';

  String get formattedAmount {
    final sign = isIncome ? '+' : '';
    return '$sign${amount.toStringAsFixed(2)} $currency';
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return createdAt;
    }
  }
}