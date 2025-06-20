class ChatMessage {
  final int id;
  final String text;
  final DateTime timestamp;
  final int senderId;
  final int receiverId;
  final bool isRead;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
    this.isRead = false,
    this.imageUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['sentAt'] ?? DateTime.now().toIso8601String()),
      senderId: json['senderProfileId'] ?? 0,
      receiverId: json['receiverProfileId'] ?? 0,
      isRead: json['status'] == 'READ',
      imageUrl: json['imageUrl'],
    );
  }

  bool isFromCurrentUser(int currentUserId) {
    return senderId == currentUserId;
  }
}
