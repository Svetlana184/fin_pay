import 'package:flutter/material.dart';
import '../../services/message_service.dart';
import '../../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _service = MessageService();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  Conversation? _conversation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final conv = await _service.getConversation(widget.conversationId);
    if (mounted) {
      setState(() {
      _conversation = conv;
      _loading = false;
    });
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await _service.sendMessage(widget.conversationId, text);
    _controller.clear();
    await _load();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_conversation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Диалог не найден')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_conversation!.sender,
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _conversation!.messages.length,
              itemBuilder: (context, i) {
                final msg = _conversation!.messages[i];
                return Column(
                  children: [
                    if (msg.date != null && (i == 0 || _conversation!.messages[i - 1].date != msg.date))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(msg.date!, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ),
                    _MessageBubble(message: msg),
                  ],
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type something...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.grey[300]!)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: Color(0xFF3B2F9F), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isOut = message.isOutgoing;
    return Align(
      alignment: isOut ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isOut ? const Color(0xFF3B2F9F) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isOut ? 18 : 4),
            bottomRight: Radius.circular(isOut ? 4 : 18),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: _buildRichText(message.text, isOut),
      ),
    );
  }

  /// Парсит текст и выделяет жирным/цветным ключевые фрагменты
  Widget _buildRichText(String text, bool isOutgoing) {
    final spans = <TextSpan>[];
    final pattern = RegExp(r'(\d{6})|(1800\d{4})|(\$[\d,]+)', caseSensitive: false);
    int lastEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start),
            style: TextStyle(color: isOutgoing ? Colors.white : Colors.black87, fontSize: 14)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
          color: isOutgoing ? Colors.white : const Color(0xFF3B2F9F),
          fontWeight: FontWeight.bold,
          fontSize: 14,
          decoration: match.group(0)!.startsWith('1800') ? TextDecoration.underline : null,
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd),
          style: TextStyle(color: isOutgoing ? Colors.white : Colors.black87, fontSize: 14)));
    }

    return RichText(text: TextSpan(children: spans));
  }
}