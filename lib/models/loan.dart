class Loan {
  final String id;
  final String userId;
  final String loanType;
  final double principalAmount;
  final double remainingBalance;
  final double interestRate;
  final double monthlyPayment;
  final String startDate;
  final String endDate;
  final String status;
  final String? nextPaymentDate;
  final String createdAt;
  final String updatedAt;

  Loan({
    required this.id,
    required this.userId,
    required this.loanType,
    required this.principalAmount,
    required this.remainingBalance,
    required this.interestRate,
    required this.monthlyPayment,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.nextPaymentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as String,
      userId: (json['user_id'] as String?) ?? '',
      loanType: (json['loan_type'] as String?) ?? '',
      principalAmount: double.tryParse(json['principal_amount']?.toString() ?? '0') ?? 0.0,
      remainingBalance: double.tryParse(json['remaining_balance']?.toString() ?? '0') ?? 0.0,
      interestRate: double.tryParse(json['interest_rate']?.toString() ?? '0') ?? 0.0,
      monthlyPayment: double.tryParse(json['monthly_payment']?.toString() ?? '0') ?? 0.0,
      startDate: (json['start_date'] as String?) ?? '',
      endDate: (json['end_date'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'active',
      nextPaymentDate: json['next_payment_date'] as String?,
      createdAt: (json['created_at'] as String?) ?? '',
      updatedAt: (json['updated_at'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'loan_type': loanType,
    'principal_amount': principalAmount,
    'remaining_balance': remainingBalance,
    'interest_rate': interestRate,
    'monthly_payment': monthlyPayment,
    'start_date': startDate,
    'end_date': endDate,
    'status': status,
    'next_payment_date': nextPaymentDate,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  bool get isActive => status == 'active';
  bool get isPaidOff => status == 'paid_off';
  double get paidAmount => principalAmount - remainingBalance;
  double get progressPercent => principalAmount > 0 ? (paidAmount / principalAmount) * 100 : 0;
}