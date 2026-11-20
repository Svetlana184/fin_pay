class TransferRecipient {
  final String id;
  final String userId;
  final String recipientName;
  final String recipientAccount;
  final String? recipientBank;
  final bool isFavorite;
  final String? lastTransferAt;
  final String createdAt;

  const TransferRecipient({
    required this.id,
    required this.userId,
    required this.recipientName,
    required this.recipientAccount,
    this.recipientBank,
    this.isFavorite = false,
    this.lastTransferAt,
    required this.createdAt,
  });

  factory TransferRecipient.fromJson(Map<String, dynamic> json) {
    return TransferRecipient(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      recipientName: json['recipient_name'] as String? ?? '',
      recipientAccount: json['recipient_account'] as String? ?? '',
      recipientBank: json['recipient_bank'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      lastTransferAt: json['last_transfer_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'recipient_name': recipientName,
    'recipient_account': recipientAccount,
    'recipient_bank': recipientBank,
    'is_favorite': isFavorite,
    'last_transfer_at': lastTransferAt,
    'created_at': createdAt,
  };
}