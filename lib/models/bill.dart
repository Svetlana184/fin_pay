class Bill {
  final String id;
  final String providerId;
  final String? billProfileId;
  final String billNumber;
  final String? externalId;
  final String periodFrom; // DATE из БД
  final String periodTo;
  final double serviceFee;
  final double tax;
  final double penalty;
  final double totalAmount;
  final String currency;
  final String status;
  final String issueDate;
  final String dueDate;
  final String? recipientName;
  final String? recipientAddress;
  final String? recipientPhone;
  final String createdAt;
  final String? paidAt;

  Bill({
    required this.id,
    required this.providerId,
    this.billProfileId,
    required this.billNumber,
    this.externalId,
    required this.periodFrom,
    required this.periodTo,
    required this.serviceFee,
    required this.tax,
    required this.penalty,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    this.recipientName,
    this.recipientAddress,
    this.recipientPhone,
    required this.createdAt,
    this.paidAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      providerId: (json['provider_id'] as String?) ?? '',
      billProfileId: json['bill_profile_id'] as String?,
      billNumber: (json['bill_number'] as String?) ?? '',
      externalId: json['external_id'] as String?,
      periodFrom: (json['period_from'] as String?) ?? '',
      periodTo: (json['period_to'] as String?) ?? '',
      serviceFee: double.tryParse(json['service_fee']?.toString() ?? '0') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '0') ?? 0.0,
      penalty: double.tryParse(json['penalty']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      currency: (json['currency'] as String?) ?? 'RUB',
      status: (json['status'] as String?) ?? 'pending',
      issueDate: (json['issue_date'] as String?) ?? '',
      dueDate: (json['due_date'] as String?) ?? '',
      recipientName: json['recipient_name'] as String?,
      recipientAddress: json['recipient_address'] as String?,
      recipientPhone: json['recipient_phone'] as String?,
      createdAt: (json['created_at'] as String?) ?? '',
      paidAt: json['paid_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'provider_id': providerId,
    'bill_profile_id': billProfileId,
    'bill_number': billNumber,
    'external_id': externalId,
    'period_from': periodFrom,
    'period_to': periodTo,
    'service_fee': serviceFee,
    'tax': tax,
    'penalty': penalty,
    'total_amount': totalAmount,
    'currency': currency,
    'status': status,
    'issue_date': issueDate,
    'due_date': dueDate,
    'recipient_name': recipientName,
    'recipient_address': recipientAddress,
    'recipient_phone': recipientPhone,
    'created_at': createdAt,
    'paid_at': paidAt,
  };

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';
}