class Treatment {
  String? description; // Cambiar a nullable
  int medicalRecordId;

  Treatment({this.description, required this.medicalRecordId});

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      description: json['description'] ?? 'No description available', // Valor predeterminado
      medicalRecordId: json['medicalRecordId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description ?? '', // Manejar nulos al enviar
      'medicalRecordId': medicalRecordId,
    };
  }
}