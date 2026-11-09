class Notification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String body;
  final dynamic data; // JSONB
  final String channel;
  final bool isRead;
  final String? readAt;
  final String? actionUrl;
  final String createdAt;
  final String? transactionId;
  final String? billPaymentId;
  final String? taxBillId;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.channel,
    required this.isRead,
    this.readAt,
    this.actionUrl,
    required this.createdAt,
    this.transactionId,
    this.billPaymentId,
    this.taxBillId,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: (json['user_id'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      data: json['data'],
      channel: (json['channel'] as String?) ?? 'push',
      isRead: (json['is_read'] as bool?) ?? false,
      readAt: json['read_at'] as String?,
      actionUrl: json['action_url'] as String?,
      createdAt: (json['created_at'] as String?) ?? '',
      transactionId: json['transaction_id'] as String?,
      billPaymentId: json['bill_payment_id'] as String?,
      taxBillId: json['tax_bill_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type': type,
    'title': title,
    'body': body,
    'data': data,
    'channel': channel,
    'is_read': isRead,
    'read_at': readAt,
    'action_url': actionUrl,
    'created_at': createdAt,
    'transaction_id': transactionId,
    'bill_payment_id': billPaymentId,
    'tax_bill_id': taxBillId,
  };

  bool get isUnread => !isRead;
  bool get isTransaction => type == 'transaction';
  bool get isPromotion => type == 'promotion';
  bool get isSecurity => type == 'security';
  bool get isSystem => type == 'system';
}