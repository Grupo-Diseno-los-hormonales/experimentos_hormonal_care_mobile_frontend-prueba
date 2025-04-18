import 'profile_model.dart';

class Patient {
  int id;
  String typeOfBlood;
  String personalHistory;
  String familyHistory;
  String patientRecordId;
  int profileId;
  int doctorId;
  Profile? profile;

  Patient({
    required this.id,
    required this.typeOfBlood,
    required this.personalHistory,
    required this.familyHistory,
    required this.patientRecordId,
    required this.profileId,
    required this.doctorId,
    this.profile,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      typeOfBlood: json['typeOfBlood'],
      personalHistory: json['personalHistory'],
      familyHistory: json['familyHistory'],
      patientRecordId: json['patientRecordId'],
      profileId: json['profileId'],
      doctorId: json['doctorId'],
    );
  }
}