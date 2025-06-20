import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/diagnosis/domain/usecases/fakechat_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';


class DoctorChatScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final int currentUserId;

  const DoctorChatScreen({
    Key? key,
    required this.doctor,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _DoctorChatScreenState createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;
  int? _doctorProfileId;
  int? _patientProfileId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    setState(() => _isLoading = true);

    // Determinar doctor y paciente
    _doctorProfileId = widget.doctor['profileId'] ?? widget.doctor['userId'] ?? widget.doctor['id'];
    _patientProfileId = widget.currentUserId == _doctorProfileId
        ? widget.doctor['patientId']
        : widget.currentUserId;

    if (_doctorProfileId == null || _patientProfileId == null) {
      setState(() => _isLoading = false);
      return;
    }

    await _loadMessages();
    setState(() => _isLoading = false);
  }

  Future<void> _loadMessages() async {
    final msgs = await FakeChatApi.getMessages(_doctorProfileId!, _patientProfileId!);
    setState(() {
      _messages
        ..clear()
        ..addAll(msgs.map((msg) => ChatMessage(
              text: msg['text'],
              senderId: msg['senderProfileId'],
              timestamp: DateTime.parse(msg['sentAt']),
            )));
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final msg = {
      'text': text,
      'senderProfileId': widget.currentUserId,
      'sentAt': DateTime.now().toIso8601String(),
    };
    await FakeChatApi.addMessage(_doctorProfileId!, _patientProfileId!, msg);
    _messageController.clear();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctor['fullName'] ?? 'Doctor'),
        backgroundColor: const Color(0xFFA78AAB),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      final msg = _messages[idx];
                      final isMe = msg.senderId == widget.currentUserId;
                      return ListTile(
                        title: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFFE2D1F4) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(msg.text),
                          ),
                        ),
                        subtitle: Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Text(
                            DateFormat('hh:mm a').format(msg.timestamp),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
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
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final int senderId;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.senderId,
    required this.timestamp,
  });
}