class TaxBill {
  final String id;
  final String userId;
  final String taxType;
  final String taxAuthority;
  final String? taxAuthorityCode;
  final String userTaxId;
  final int assessmentYear;
  final String? objectDescription;
  final String? objectAddress;
  final String? objectRegistrationNumber;
  final double assessedAmount;
  final double penalty;
  final double discount;
  final double totalAmount;
  final String currency;
  final String status;
  final String issueDate;
  final String dueDate;
  final String? documentNumber;
  final String? documentUrl;
  final String createdAt;
  final String? paidAt;

  TaxBill({
    required this.id,
    required this.userId,
    required this.taxType,
    required this.taxAuthority,
    this.taxAuthorityCode,
    required this.userTaxId,
    required this.assessmentYear,
    this.objectDescription,
    this.objectAddress,
    this.objectRegistrationNumber,
    required this.assessedAmount,
    required this.penalty,
    required this.discount,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    this.documentNumber,
    this.documentUrl,
    required this.createdAt,
    this.paidAt,
  });

  factory TaxBill.fromJson(Map<String, dynamic> json) {
    return TaxBill(
      id: json['id'] as String,
      userId: (json['user_id'] as String?) ?? '',
      taxType: (json['tax_type'] as String?) ?? '',
      taxAuthority: (json['tax_authority'] as String?) ?? '',
      taxAuthorityCode: json['tax_authority_code'] as String?,
      userTaxId: (json['user_tax_id'] as String?) ?? '',
      assessmentYear: (json['assessment_year'] as int?) ?? 0,
      objectDescription: json['object_description'] as String?,
      objectAddress: json['object_address'] as String?,
      objectRegistrationNumber: json['object_registration_number'] as String?,
      assessedAmount: double.tryParse(json['assessed_amount']?.toString() ?? '0') ?? 0.0,
      penalty: double.tryParse(json['penalty']?.toString() ?? '0') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      currency: (json['currency'] as String?) ?? 'RUB',
      status: (json['status'] as String?) ?? 'pending',
      issueDate: (json['issue_date'] as String?) ?? '',
      dueDate: (json['due_date'] as String?) ?? '',
      documentNumber: json['document_number'] as String?,
      documentUrl: json['document_url'] as String?,
      createdAt: (json['created_at'] as String?) ?? '',
      paidAt: json['paid_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'tax_type': taxType,
    'tax_authority': taxAuthority,
    'tax_authority_code': taxAuthorityCode,
    'user_tax_id': userTaxId,
    'assessment_year': assessmentYear,
    'object_description': objectDescription,
    'object_address': objectAddress,
    'object_registration_number': objectRegistrationNumber,
    'assessed_amount': assessedAmount,
    'penalty': penalty,
    'discount': discount,
    'total_amount': totalAmount,
    'currency': currency,
    'status': status,
    'issue_date': issueDate,
    'due_date': dueDate,
    'document_number': documentNumber,
    'document_url': documentUrl,
    'created_at': createdAt,
    'paid_at': paidAt,
  };

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';
}