import '../models/message.dart';

class MessageService {
  // Демо-данные (в prod — GET /api/notifications или /api/messages)
  static final List<Conversation> _conversations = [
    Conversation(
      id: 'conv-1',
      sender: 'Bank of America',
      senderType: 'bank',
      lastMessage: 'Bank of America: 256486 is the au...',
      date: 'Today',
      icon: '🏦',
      iconColor: '0xFF3B2F9F',
      isUnread: true,
      messages: [
        Message(
          id: 'm1',
          text: 'Did you attempt transaction on debit card ending in 0000 at Mechant in NJ for \$1,200?\nReply YES or NO',
          isOutgoing: false,
          timestamp: '8/10/2018',
          date: '8/10/2018',
        ),
        Message(
          id: 'm2',
          text: 'Yes',
          isOutgoing: true,
          timestamp: '8/10/2018',
        ),
        Message(
          id: 'm3',
          text: 'Bank of America: 256486 is your authorization code which expires in 10 minutes. If you didn\'t request the code. Call: 18009898 for assistance',
          isOutgoing: false,
          timestamp: '8/10/2018',
          date: '8/10/2018',
        ),
        Message(
          id: 'm4',
          text: 'Thanks!',
          isOutgoing: true,
          timestamp: '8/10/2018',
        ),
      ],
    ),
    Conversation(
      id: 'conv-2',
      sender: 'Account',
      senderType: 'account',
      lastMessage: 'Your account is limited. Please foll...',
      date: '12/10',
      icon: '👤',
      iconColor: '0xFFFF4757',
      isUnread: true,
      messages: [
        Message(
          id: 'm5',
          text: 'Your account is limited. Please follow the verification process.',
          isOutgoing: false,
          timestamp: '12/10',
          date: '12/10',
        ),
      ],
    ),
    Conversation(
      id: 'conv-3',
      sender: 'Alert',
      senderType: 'alert',
      lastMessage: 'Your statement is ready for you to...',
      date: '11/10',
      icon: '🔔',
      iconColor: '0xFF1890FF',
      isUnread: false,
      messages: [
        Message(
          id: 'm6',
          text: 'Your statement is ready for you to download.',
          isOutgoing: false,
          timestamp: '11/10',
          date: '11/10',
        ),
      ],
    ),
    Conversation(
      id: 'conv-4',
      sender: 'Paypal',
      senderType: 'paypal',
      lastMessage: 'Your account has been locked. Ple...',
      date: '10/11',
      icon: '💳',
      iconColor: '0xFFFFA500',
      isUnread: false,
      messages: [
        Message(
          id: 'm7',
          text: 'Your account has been locked. Please contact support.',
          isOutgoing: false,
          timestamp: '10/11',
          date: '10/11',
        ),
      ],
    ),
    Conversation(
      id: 'conv-5',
      sender: 'Withdraw',
      senderType: 'withdraw',
      lastMessage: 'Dear customer, 2987456 is your co...',
      date: '10/12',
      icon: '💵',
      iconColor: '0xFF20B2AA',
      isUnread: false,
      messages: [
        Message(
          id: 'm8',
          text: 'Dear customer, 2987456 is your confirmation code.',
          isOutgoing: false,
          timestamp: '10/12',
          date: '10/12',
        ),
      ],
    ),
  ];

  Future<List<Conversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _conversations;
  }

  Future<Conversation?> getConversation(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _conversations.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> sendMessage(String conversationId, String text) async {
    final conv = _conversations.firstWhere((c) => c.id == conversationId);
    conv.messages.add(Message(
      id: 'm-${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      isOutgoing: true,
      timestamp: DateTime.now().toString().substring(0, 16),
    ));
    //conv.lastMessage = text;
    //conv.date = 'Just now';
  }
}