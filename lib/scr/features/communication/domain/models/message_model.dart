class MessageModel {
  final int id;
  final int senderProfileId;
  final int receiverProfileId;
  final String? text;
  final String messageType;
  final String? imageUrl;
  final String status;
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.senderProfileId,
    required this.receiverProfileId,
    this.text,
    required this.messageType,
    this.imageUrl,
    required this.status,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderProfileId: json['senderProfileId'],
      receiverProfileId: json['receiverProfileId'],
      text: json['text'],
      messageType: json['messageType'],
      imageUrl: json['imageUrl'],
      status: json['status'],
      sentAt: DateTime.parse(json['sentAt']),
    );
  }

  bool get isRead => status == 'READ';
  bool get isImage => messageType == 'IMAGE';
}