class Medication {
  final int id;
  final int medicalRecordId;
  final int prescriptionId;
  final int medicationTypeId;
  final String drugName;
  final String quantity;
  final String concentration;
  final String frequency;
  final String duration;

  Medication({
    required this.id,
    required this.medicalRecordId,
    required this.prescriptionId,
    required this.medicationTypeId,
    required this.drugName,
    required this.quantity,
    required this.concentration,
    required this.frequency,
    required this.duration,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      medicalRecordId: json['medicalRecordId'],
      prescriptionId: json['prescriptionId'],
      medicationTypeId: json['medicationTypeId'],
      drugName: json['drugName'],
      quantity: json['quantity'],
      concentration: json['concentration'],
      frequency: json['frequency'],
      duration: json['duration'],
    );
  }
}