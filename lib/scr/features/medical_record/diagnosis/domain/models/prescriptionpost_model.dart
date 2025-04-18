class PrescriptionPost {
  int medicalRecordId;
  String prescriptionDate;
  String notes;

  PrescriptionPost({
    required this.medicalRecordId,
    required this.prescriptionDate,
    required this.notes,
  });

  factory PrescriptionPost.fromJson(Map<String, dynamic> json) {
    return PrescriptionPost(
      medicalRecordId: json['medicalRecordId'],
      prescriptionDate: json['prescriptionDate'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicalRecordId': medicalRecordId,
      'prescriptionDate': prescriptionDate,
      'notes': notes,
    };
  }
}