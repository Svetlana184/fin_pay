import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/message_service.dart';
import '../../models/message.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final _service = MessageService();
  List<Conversation> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await _service.getConversations();
    if (mounted) {
      setState(() {
      _conversations = list;
      _loading = false;
    });
    }
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('0x', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Message',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _conversations.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final conv = _conversations[i];
            return _ConversationTile(
              conversation: conv,
              iconColor: _parseColor(conv.iconColor),
              onTap: () => context.push('/chat/${conv.id}'),
            );
          },
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final Color iconColor;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.iconColor,
    required this.onTap,
  });

  IconData _iconFor(String type) {
    switch (type) {
      case 'bank': return Icons.account_balance;
      case 'account': return Icons.person;
      case 'alert': return Icons.notifications_active;
      case 'paypal': return Icons.payment;
      case 'withdraw': return Icons.atm;
      default: return Icons.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Иконка отправителя
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_iconFor(conversation.senderType), color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            // Контент
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(conversation.sender,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(conversation.date,
                          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            if (conversation.isUnread) ...[
              const SizedBox(width: 8),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF3B2F9F), shape: BoxShape.circle)),
            ],
          ],
        ),
      ),
    );
  }
}