class ParticipantModel {
  final int id;
  final int userId;
  final String participantType;
  final DateTime joinedAt;
  final DateTime lastSeenAt;

  ParticipantModel({
    required this.id,
    required this.userId,
    required this.participantType,
    required this.joinedAt,
    required this.lastSeenAt,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'],
      userId: json['userId'],
      participantType: json['participantType'],
      joinedAt: DateTime.parse(json['joinedAt']),
      lastSeenAt: DateTime.parse(json['lastSeenAt']),
    );
  }

  bool get isDoctor => participantType == 'DOCTOR';
  bool get isPatient => participantType == 'PATIENT';
  bool get isAdmin => participantType == 'ADMIN';
}