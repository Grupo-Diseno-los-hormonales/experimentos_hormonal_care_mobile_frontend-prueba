import 'package:flutter/material.dart';

class LabTestSection extends StatelessWidget {
  final List<Map<String, dynamic>> labTests;
  final Function(Map<String, dynamic>) onAddLabTest;
  final Function(int) onDeleteLabTest;

  const LabTestSection({
    required this.labTests,
    required this.onAddLabTest,
    required this.onDeleteLabTest,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lab Tests',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8F7193), // Texto morado oscuro
          ),
        ),
        const SizedBox(height: 10),
        ...labTests.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> labTest = entry.value;
          return _buildLabTestItem(labTest, index);
        }).toList(),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8F7193), // Botón morado oscuro
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            onAddLabTest({"testName": "", "file": null});
          },
          child: const Text(
            'Add Lab Test',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLabTestItem(Map<String, dynamic> labTest, int index) {
    return Card(
      color: const Color(0xFFDFCAE1), // Fondo morado claro
      child: ListTile(
        title: Text(
          labTest['testName'].isNotEmpty
              ? 'Lab Test: ${labTest["testName"]}'
              : 'Unnamed Test',
          style: const TextStyle(
            color: Color(0xFF8F7193), // Texto morado oscuro
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.upload_file, color: Color(0xFFA788AB)), // Icono morado intermedio
              onPressed: () {
                // Implementar lógica de carga de archivos
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF8F7193)), // Icono morado oscuro
              onPressed: () {
                onDeleteLabTest(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}