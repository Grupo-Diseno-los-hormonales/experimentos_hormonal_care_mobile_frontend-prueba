import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/widgets/fake_admin_chat_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupportUserChatSection extends StatefulWidget {
  const SupportUserChatSection({super.key});

  @override
  State<SupportUserChatSection> createState() => _SupportUserChatSectionState();
}

class _SupportUserChatSectionState extends State<SupportUserChatSection> {
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndMessages();
  }

   Future<void> _loadUserIdAndMessages() async {
    final prefs = await SharedPreferences.getInstance();
    dynamic userIdRaw = prefs.get('user_id');
    String userId;
    if (userIdRaw == null) {
      userId = 'unknown_user';
    } else if (userIdRaw is int) {
      userId = userIdRaw.toString();
    } else {
      userId = userIdRaw as String;
    }
    setState(() {
      _userId = userId;
    });
    await _loadMessages();
  }
  Future<void> _loadMessages() async {
    final msgs = await FakeAdminGlobalChatApi.getMessages();
    // Filtra solo los mensajes de este usuario
    final filtered = msgs.where((msg) => msg['userId'] == _userId).toList();
    setState(() {
      _messages = filtered;
      _loading = false;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _userId == null) return;
    final msg = {
      'type': 'message',
      'text': text,
      'sender': 'user',
      'userId': _userId, // Guarda el userId en el mensaje
      'timestamp': DateTime.now().toIso8601String(),
    };
    await FakeAdminGlobalChatApi.addMessage(msg);
    _controller.clear();
    await _loadMessages();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isMe = msg['sender'] == 'user';
                return ListTile(
                  title: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFFE2D1F4) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg['text'] ?? ''),
                    ),
                  ),
                  subtitle: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      msg['timestamp'] != null
                          ? DateFormat('hh:mm a').format(DateTime.parse(msg['timestamp']))
                          : '',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFFA78AAB),
                child: const Icon(Icons.send, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}