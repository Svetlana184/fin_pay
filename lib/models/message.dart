class Conversation {
  final String id;
  final String sender;
  final String senderType; // 'bank', 'account', 'alert', 'paypal', 'withdraw'
  final String lastMessage;
  final String date;
  final String icon;
  final String iconColor;
  final bool isUnread;
  final List<Message> messages;

  const Conversation({
    required this.id,
    required this.sender,
    required this.senderType,
    required this.lastMessage,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.isUnread,
    required this.messages,
  });
}

class Message {
  final String id;
  final String text;
  final bool isOutgoing;
  final String timestamp;
  final String? date; // разделитель даты (например "8/10/2018")

  const Message({
    required this.id,
    required this.text,
    required this.isOutgoing,
    required this.timestamp,
    this.date,
  });
}