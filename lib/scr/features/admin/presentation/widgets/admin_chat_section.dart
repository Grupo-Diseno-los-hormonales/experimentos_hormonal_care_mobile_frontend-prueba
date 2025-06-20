import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/widgets/fake_admin_chat_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class AdminChatSection extends StatefulWidget {
  final List<Map<String, dynamic>> users; // [{id, name, role}]
  final String adminId;

  const AdminChatSection({super.key, required this.users, required this.adminId});

  @override
  State<AdminChatSection> createState() => _AdminChatSectionState();
}

class _AdminChatSectionState extends State<AdminChatSection> {
  String? _selectedUserId;
  String? _selectedUserName;
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selector de usuario
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: _selectedUserId,
            hint: const Text('Select user to chat'),
            isExpanded: true,
            items: widget.users.map((user) {
              return DropdownMenuItem<String>(
                value: user['id'].toString(),
                child: Text('${user['name']} (${user['role']})'),
              );
            }).toList(),
            onChanged: (userId) async {
              setState(() {
                _selectedUserId = userId;
                _selectedUserName = widget.users.firstWhere((u) => u['id'].toString() == userId)['name'];
                _loading = true;
              });
              final msgs = await FakeAdminChatApi.getMessages(userId!);
              setState(() {
                _messages = msgs;
                _loading = false;
              });
              _scrollToBottom();
            },
          ),
        ),
        if (_selectedUserId == null)
          const Expanded(
            child: Center(child: Text('Select a user to start chatting.')),
          )
        else if (_loading)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isAdmin = msg['senderId'] == widget.adminId;
                return ListTile(
                  title: Align(
                    alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isAdmin ? const Color(0xFFE2D1F4) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(msg['text'] ?? ''),
                    ),
                  ),
                  subtitle: Align(
                    alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      msg['sentAt'] != null
                          ? DateFormat('hh:mm a').format(DateTime.parse(msg['sentAt']))
                          : '',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                );
              },
            ),
          ),
        if (_selectedUserId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message to $_selectedUserName...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
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

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _selectedUserId == null) return;
    final msg = {
      'text': text,
      'senderId': widget.adminId,
      'sentAt': DateTime.now().toIso8601String(),
    };
    await FakeAdminChatApi.addMessage(_selectedUserId!, msg);
    _controller.clear();
    final msgs = await FakeAdminChatApi.getMessages(_selectedUserId!);
    setState(() {
      _messages = msgs;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }
}