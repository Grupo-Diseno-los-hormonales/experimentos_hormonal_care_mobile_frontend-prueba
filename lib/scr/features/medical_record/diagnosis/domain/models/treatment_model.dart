class Treatment {
  String description;
  int medicalRecordId;

  Treatment({required this.description, required this.medicalRecordId});

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      description: json['description'],
      medicalRecordId: json['medicalRecordId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'medicalRecordId': medicalRecordId,
    };
  }
}