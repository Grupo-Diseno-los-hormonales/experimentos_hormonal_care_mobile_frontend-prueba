import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/communication/domain/models/message_model.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/communication/domain/models/participant_model.dart';

class ConversationModel {
  final int id;
  final List<ParticipantModel> participants;
  final MessageModel? lastMessage;
  final DateTime lastActivityAt;
  final int messageCount;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.lastActivityAt,
    required this.messageCount,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participants: (json['participants'] as List)
          .map((p) => ParticipantModel.fromJson(p))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      lastActivityAt: DateTime.parse(json['lastActivityAt']),
      messageCount: json['messageCount'] ?? 0,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}