import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/widgets/edit_modal.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/widgets/editable_field.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/widgets/medication_section.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/diagnosis/presentation/widgets/lab_test_section.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/patient_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/domain/models/patient_model.dart'; // Importa el modelo de paciente
import 'package:intl/intl.dart'; // Importa el paquete intl para formatear fechas

class ConsultationScreen extends StatefulWidget {
  final int patientId;

  const ConsultationScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _ConsultationScreenState createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  List<Map<String, String>> medications = [];
  List<Map<String, dynamic>> labTests = [];
  String diagnosis = "";
  String treatment = "";
  late Future<Map<String, dynamic>> _patientFuture;

  @override
  void initState() {
    super.initState();
    _patientFuture = _fetchPatientDetails(widget.patientId);
  }

  Future<Map<String, dynamic>> _fetchPatientDetails(int patientId) async {
    final patientDetails = await PatientService().fetchPatientDetails(patientId);
    final profileDetails = await ProfileService().fetchProfileDetails(patientDetails['profileId']);
    return {
      'patientDetails': patientDetails,
      'profileDetails': profileDetails,
    };
  }
  // Función para construir los campos de información
  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Función para formatear la fecha
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'Unknown';
    final parsedDate = DateTime.parse(date);
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(parsedDate);
  }

  // Función para obtener la URL de la imagen
  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }
    if (!imageUrl.startsWith('http')) {
      return 'https://$imageUrl';
    }
    return imageUrl;
  }

  // Función para calcular la edad
  int _calculateAge(String? birthday) {
    if (birthday == null) return 0;
    final birthDate = DateTime.parse(birthday);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Función para construir el encabezado del paciente
  Widget _buildPatientHeader(Map<String, dynamic> profileDetails) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF4B5A62),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(_getImageUrl(profileDetails['image'])),
                backgroundColor: Colors.blueGrey[200],
                child: profileDetails['image'] == null || profileDetails['image'].isEmpty
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profileDetails['fullName'] ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            'Age: ${_calculateAge(profileDetails['birthday'])}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A828D),
        title: const Text('Consultation'),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _patientFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          } else {
            final patientDetails = snapshot.data!['patientDetails'];
            final profileDetails = snapshot.data!['profileDetails'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientHeader(profileDetails),
                  const SizedBox(height: 20),
                  const Text(
                    'Diagnosis',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF40535B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  EditableField(
                    label: 'Diagnosis',
                    value: diagnosis,
                    onSave: (newValue) {
                      setState(() {
                        diagnosis = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Treatment',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF40535B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  EditableField(
                    label: 'Treatment',
                    value: treatment,
                    onSave: (newValue) {
                      setState(() {
                        treatment = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  MedicationSection(
                    medications: medications,
                    onAddMedication: (medication) {
                      setState(() {
                        medications.add(medication);
                      });
                    },
                    onDeleteMedication: (index) {
                      setState(() {
                        medications.removeAt(index);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  LabTestSection(
                    labTests: labTests,
                    onAddLabTest: (labTest) {
                      setState(() {
                        labTests.add(labTest);
                      });
                    },
                    onDeleteLabTest: (index) {
                      setState(() {
                        labTests.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}