class Beneficiary {
  final String id;
  final String name;
  final String cardNumber;
  final String? bankName;
  final String? branchName;
  final String transferType; // 'card_number', 'same_bank', 'another_bank'
  final String? avatarUrl;
  final DateTime createdAt;

  const Beneficiary({
    required this.id,
    required this.name,
    required this.cardNumber,
    this.bankName,
    this.branchName,
    required this.transferType,
    this.avatarUrl,
    required this.createdAt,
  });

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json['id'] as String,
      name: json['recipient_name'] as String? ?? '',
      cardNumber: json['recipient_account'] as String? ?? '',
      bankName: json['recipient_bank'] as String?,
      branchName: json['branch_name'] as String?,
      transferType: json['transfer_type'] as String? ?? 'card_number',
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipient_name': name,
    'recipient_account': cardNumber,
    'recipient_bank': bankName,
    'branch_name': branchName,
    'transfer_type': transferType,
    'avatar_url': avatarUrl,
    'created_at': createdAt.toIso8601String(),
  };
}