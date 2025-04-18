class Prescription {
  final int id;
  final int medicalRecordId;
  final String prescriptionDate;
  final String notes;

  Prescription({
    required this.id,
    required this.medicalRecordId,
    required this.prescriptionDate,
    required this.notes,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      medicalRecordId: json['medicalRecordId'],
      prescriptionDate: json['prescriptionDate'],
      notes: json['notes'],
    );
  }
}