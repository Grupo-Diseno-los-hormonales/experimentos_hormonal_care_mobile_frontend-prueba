class Prescription {
  final int id;
  final int medicalRecordId;
  final String? prescriptionDate; // Cambiar a nullable
  final String? notes; // Cambiar a nullable

  Prescription({
    required this.id,
    required this.medicalRecordId,
    this.prescriptionDate,
    this.notes,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      medicalRecordId: json['medicalRecordId'],
      prescriptionDate: json['prescriptionDate'] ?? '', // Valor predeterminado
      notes: json['notes'] ?? 'No notes available', // Valor predeterminado
    );
  }
}