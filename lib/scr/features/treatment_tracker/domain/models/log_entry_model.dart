class LogEntry {
  final DateTime date;
  final double glucose;
  final double insulin;
  
  LogEntry({
    required this.date,
    required this.glucose,
    required this.insulin,
  });
  
  // Convertir a JSON para almacenamiento
  String toJson() {
    return '${date.toIso8601String()}|$glucose|$insulin';
  }
  
  // Crear desde JSON
  factory LogEntry.fromJson(String json) {
    final parts = json.split('|');
    return LogEntry(
      date: DateTime.parse(parts[0]),
      glucose: double.parse(parts[1]),
      insulin: double.parse(parts[2]),
    );
  }
}