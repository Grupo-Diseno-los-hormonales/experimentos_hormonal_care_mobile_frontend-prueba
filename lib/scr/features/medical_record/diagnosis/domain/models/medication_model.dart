class Medication {
  final int id;
  final int medicalRecordId;
  final int prescriptionId;
  final int medicationTypeId;
  final String? drugName; // Cambiar a nullable
  final String? quantity; // Cambiar a nullable
  final String? concentration; // Cambiar a nullable
  final String? frequency; // Cambiar a nullable
  final String? duration; // Cambiar a nullable

  Medication({
    required this.id,
    required this.medicalRecordId,
    required this.prescriptionId,
    required this.medicationTypeId,
    this.drugName,
    this.quantity,
    this.concentration,
    this.frequency,
    this.duration,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      medicalRecordId: json['medicalRecordId'],
      prescriptionId: json['prescriptionId'],
      medicationTypeId: json['medicationTypeId'],
      drugName: json['drugName'] ?? 'Unknown drug', // Valor predeterminado
      quantity: json['quantity'] ?? '0', // Valor predeterminado
      concentration: json['concentration'] ?? '0', // Valor predeterminado
      frequency: json['frequency'] ?? 'Unknown', // Valor predeterminado
      duration: json['duration'] ?? 'Unknown', // Valor predeterminado
    );
  }
}