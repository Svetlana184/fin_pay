class SavingsAccount {
  final String id;
  final String? userId;
  final String accountNumber;
  final String accountType;
  final double balance;
  final String currency;
  final double? interestRate;
  final String startDate;
  final String endDate;
  final int? termMonths; // вычисляемое поле из API
  final String status;
  final double minBalance;
  final String createdAt;
  final String updatedAt;

  SavingsAccount({
    required this.id,
    this.userId,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.currency,
    this.interestRate,
    required this.startDate,
    required this.endDate,
    this.termMonths,
    required this.status,
    required this.minBalance,
    required this.createdAt,
    required this.updatedAt
  });

  factory SavingsAccount.fromJson(Map<String, dynamic> json) {
    return SavingsAccount(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      accountNumber: (json['account_number'] as String?) ?? '',
      accountType: (json['account_type'] as String?) ?? '',
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      currency: (json['currency'] as String?) ?? 'RUB',
      interestRate: json['interest_rate'] != null
          ? double.tryParse(json['interest_rate'].toString())
          : null,
      startDate: (json['start_date'] as String?) ?? '',
      endDate: (json['end_date'] as String?) ?? '',
      termMonths: json['term_months'] as int?,
      status: (json['status'] as String?) ?? 'active',
      minBalance: double.tryParse(json['min_balance']?.toString() ?? '0') ?? 0.0,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'account_number': accountNumber,
    'account_type': accountType,
    'balance': balance,
    'currency': currency,
    'interest_rate': interestRate,
    'start_date': startDate,
    'end_date': endDate,
    'term_months': termMonths,
    'status': status,
    'min_balance': minBalance,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  bool get isActive => status == 'active';
  bool get isClosed => status == 'closed';
  bool get isFrozen => status == 'frozen';
}