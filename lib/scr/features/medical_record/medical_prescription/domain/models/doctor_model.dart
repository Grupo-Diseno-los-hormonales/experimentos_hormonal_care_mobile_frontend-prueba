class Doctor {
  int id;
  int professionalIdentificationNumber;
  String subSpecialty;
  int profileId;
  String doctorRecordId;

  Doctor({
    required this.id,
    required this.professionalIdentificationNumber,
    required this.subSpecialty,
    required this.profileId,
    required this.doctorRecordId,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      professionalIdentificationNumber: json['professionalIdentificationNumber'],
      subSpecialty: json['subSpecialty'],
      profileId: json['profileId'],
      doctorRecordId: json['doctorRecordId'],
    );
  }
}