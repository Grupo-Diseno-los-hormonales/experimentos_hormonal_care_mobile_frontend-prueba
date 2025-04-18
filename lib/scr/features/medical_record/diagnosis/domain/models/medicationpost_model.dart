class MedicationPost {
  int medicalRecordId;
  int medicalTypeId;
  int prescriptionId;
  String name;
  int amount;
  String unitQ;
  int value;
  String unit;
  int timesPerDay;
  String timePeriod;

  MedicationPost({
    required this.medicalRecordId,
    required this.medicalTypeId,
    required this.prescriptionId,
    required this.name,
    required this.amount,
    required this.unitQ,
    required this.value,
    required this.unit,
    required this.timesPerDay,
    required this.timePeriod,
  });

  factory MedicationPost.fromJson(Map<String, dynamic> json) {
    return MedicationPost(
      medicalRecordId: json['medicalRecordId'],
      medicalTypeId: json['medicalTypeId'],
      prescriptionId: json['prescriptionId'],
      name: json['name'],
      amount: json['amount'],
      unitQ: json['unitQ'],
      value: json['value'],
      unit: json['unit'],
      timesPerDay: json['timesPerDay'],
      timePeriod: json['timePeriod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicalRecordId': medicalRecordId,
      'medicalTypeId': medicalTypeId,
      'prescriptionId': prescriptionId,
      'name': name,
      'amount': amount,
      'unitQ': unitQ,
      'value': value,
      'unit': unit,
      'timesPerDay': timesPerDay,
      'timePeriod': timePeriod,
    };
  }
}