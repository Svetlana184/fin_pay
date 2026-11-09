class BillPayment {
  final String id;
  final String userId;
  final String? billId;
  final String? taxBillId;
  final String accountId;
  final String? otpCode;
  final String? otpVerifiedAt;
  final String? otpExpiresAt;
  final double amount;
  final String currency;
  final String status;
  final String? transactionId;
  final String? providerReference;
  final String? receiptUrl;
  final String? errorMessage;
  final String createdAt;
  final String? completedAt;

  BillPayment({
    required this.id,
    required this.userId,
    this.billId,
    this.taxBillId,
    required this.accountId,
    this.otpCode,
    this.otpVerifiedAt,
    this.otpExpiresAt,
    required this.amount,
    required this.currency,
    required this.status,
    this.transactionId,
    this.providerReference,
    this.receiptUrl,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  factory BillPayment.fromJson(Map<String, dynamic> json) {
    return BillPayment(
      id: json['id'] as String,
      userId: (json['user_id'] as String?) ?? '',
      billId: json['bill_id'] as String?,
      taxBillId: json['tax_bill_id'] as String?,
      accountId: (json['account_id'] as String?) ?? '',
      otpCode: json['otp_code'] as String?,
      otpVerifiedAt: json['otp_verified_at'] as String?,
      otpExpiresAt: json['otp_expires_at'] as String?,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: (json['currency'] as String?) ?? 'RUB',
      status: (json['status'] as String?) ?? 'pending',
      transactionId: json['transaction_id'] as String?,
      providerReference: json['provider_reference'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      errorMessage: json['error_message'] as String?,
      createdAt: (json['created_at'] as String?) ?? '',
      completedAt: json['completed_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'bill_id': billId,
    'tax_bill_id': taxBillId,
    'account_id': accountId,
    'otp_code': otpCode,
    'otp_verified_at': otpVerifiedAt,
    'otp_expires_at': otpExpiresAt,
    'amount': amount,
    'currency': currency,
    'status': status,
    'transaction_id': transactionId,
    'provider_reference': providerReference,
    'receipt_url': receiptUrl,
    'error_message': errorMessage,
    'created_at': createdAt,
    'completed_at': completedAt,
  };

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}