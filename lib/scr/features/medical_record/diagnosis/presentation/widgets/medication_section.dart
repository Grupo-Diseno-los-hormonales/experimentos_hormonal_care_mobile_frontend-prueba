import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MedicationSection extends StatelessWidget {
  final List<Map<String, String>> medications;
  final Function(Map<String, String>) onAddMedication;
  final Function(int) onDeleteMedication;

  const MedicationSection({
    required this.medications,
    required this.onAddMedication,
    required this.onDeleteMedication,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.medicationLabel ?? 'Medication',
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8F7193), // Texto morado oscuro
          ),
        ),
        const SizedBox(height: 10),
        ...medications.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, String> medication = entry.value;
          return _buildMedicationItem(context, medication, index);
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
            _showAddMedicationDialog(context);
          },
          child: const Text(
            'Add Medication',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationItem(BuildContext context, Map<String, String> medication, int index) {
    return Card(
      color: const Color(0xFFDFCAE1), // Fondo morado claro
      child: ListTile(
        title: Text(
          'Medication: ${medication["name"]}',
          style: const TextStyle(
            color: Color(0xFF8F7193), // Texto morado oscuro
          ),
        ),
        subtitle: Text(
          '${AppLocalizations.of(context)?.concentrationLabel ?? 'Concentration'}: ${medication["concentration"]}, ${AppLocalizations.of(context)?.unitLabel ?? 'Unit'}: ${medication["unit"]}, ${AppLocalizations.of(context)?.frequencyLabel ?? 'Frequency'}: ${medication["frequency"]}',
          style: const TextStyle(
            color: Color(0xFFA788AB), // Texto morado intermedio
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Color(0xFF8F7193)), // Icono morado oscuro
          onPressed: () {
            onDeleteMedication(index);
          },
        ),
      ),
    );
  }

  void _showAddMedicationDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController concentrationController = TextEditingController();
    TextEditingController unitController = TextEditingController();
    TextEditingController frequencyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add Medication',
            style: TextStyle(color: Color(0xFF8F7193)), // Texto morado oscuro
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Medication Name',
                  hintStyle: TextStyle(color: Color(0xFFA788AB)), // Texto morado intermedio
                ),
              ),
              TextField(
                controller: concentrationController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.concentrationLabel ?? 'Concentration',
                  hintStyle: const TextStyle(color: Color(0xFFA788AB)), // Texto morado intermedio
                ),
              ),
              TextField(
                controller: unitController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.unitLabel ?? 'Unit',
                  hintStyle: const TextStyle(color: Color(0xFFA788AB)), // Texto morado intermedio
                ),
              ),
              TextField(
                controller: frequencyController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)?.frequencyLabel ?? 'Frequency',
                  hintStyle: const TextStyle(color: Color(0xFFA788AB)), // Texto morado intermedio
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                onAddMedication({
                  "name": nameController.text,
                  "concentration": concentrationController.text,
                  "unit": unitController.text,
                  "frequency": frequencyController.text,
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Color(0xFF8F7193)), // Texto morado oscuro
              ),
            ),
          ],
        );
      },
    );
  }
}