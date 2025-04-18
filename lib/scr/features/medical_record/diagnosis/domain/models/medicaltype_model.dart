class MedicalType {
  final String typeName;

  MedicalType({required this.typeName});

  factory MedicalType.fromJson(Map<String, dynamic> json) {
    return MedicalType(
      typeName: json['typeName'],
    );
  }
}