import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/widgets/fake_admin_chat_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminGlobalChatSection extends StatefulWidget {
  const AdminGlobalChatSection({super.key});

  @override
  State<AdminGlobalChatSection> createState() => _AdminGlobalChatSectionState();
}

class _AdminGlobalChatSectionState extends State<AdminGlobalChatSection> {
  Map<String, List<Map<String, dynamic>>> _tickets = {};
  final Map<String, TextEditingController> _controllers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTickets() async {
    final msgs = await FakeAdminGlobalChatApi.getMessages();
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final msg in msgs) {
      final userId = msg['userId'] ?? 'unknown_user';
      if (!grouped.containsKey(userId)) grouped[userId] = [];
      grouped[userId]!.add(msg);
    }
    setState(() {
      _tickets = grouped;
      // Crea un controller por ticket si no existe
      for (final userId in grouped.keys) {
        _controllers.putIfAbsent(userId, () => TextEditingController());
      }
      _loading = false;
    });
  }

  Future<void> _sendMessage(String userId) async {
    final controller = _controllers[userId];
    if (controller == null) return;
    final text = controller.text.trim();
    if (text.isEmpty) return;
    final msg = {
      'type': 'message',
      'text': text,
      'sender': 'admin',
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await FakeAdminGlobalChatApi.addMessage(msg);
    controller.clear();
    await _loadTickets();
  }

  Future<void> _endTicket(String userId) async {
    await FakeAdminGlobalChatApi.clearChatForUser(userId);
    _controllers[userId]?.dispose();
    _controllers.remove(userId);
    await _loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_tickets.isEmpty) {
      return const Center(child: Text('No support tickets.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _tickets.entries.map((entry) {
        final userId = entry.key;
        final messages = entry.value;
        final controller = _controllers[userId]!;
        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.support_agent, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Text('Ticket: $userId', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _endTicket(userId),
                      icon: const Icon(Icons.stop_circle, color: Colors.deepPurple),
                      label: const Text('End'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.deepPurple,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, idx) {
                      final msg = messages[idx];
                      final isAdmin = msg['sender'] == 'admin';
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
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
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
                          onSubmitted: (_) => _sendMessage(userId),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        backgroundColor: const Color(0xFFA78AAB),
                        child: const Icon(Icons.send, color: Colors.white),
                        onPressed: () => _sendMessage(userId),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}