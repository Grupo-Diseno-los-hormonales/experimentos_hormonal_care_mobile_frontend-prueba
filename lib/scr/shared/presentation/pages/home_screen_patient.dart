import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/appointment_screen_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/doctors_list_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/diagnosis/domain/models/medication_model.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/diagnosis/domain/services/medicalrecord_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/treatment_tracker/presentation/pages/treatment_tracker_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenPatient extends StatefulWidget {
  const HomeScreenPatient({super.key});

  @override
  State<HomeScreenPatient> createState() => _HomeScreenPatientState();
}

class _HomeScreenPatientState extends State<HomeScreenPatient> {

  int? patientId;

  // Servicio para obtener datos médicos
  final MedicalRecordService _medicalRecordService = MedicalRecordService();
  
  // Lista de medicaciones desde el servicio
  List<Medication> _medications = [];
  
  // Estado de carga
  bool _isLoading = true;
  String _errorMessage = '';
  
  // ID del registro médico del paciente (se obtendrá de SharedPreferences)
  int? _medicalRecordId;
  
  // Lista de exámenes
  final List<ExamItem> _examItems = [
    ExamItem(controller: TextEditingController(text: "Hormonal test"), isChecked: false),
    ExamItem(controller: TextEditingController(text: "Blood test"), isChecked: false),
    ExamItem(controller: TextEditingController(), isChecked: false),
    ExamItem(controller: TextEditingController(), isChecked: false),
  ];
  
  // Lista de archivos seleccionados
  List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    // Inicializar listeners para los exámenes
    for (var item in _examItems) {
      _addExamTextFieldListener(item.controller);
    }
    
    // Cargar medicaciones
    _loadMedicalRecordId().then((_) {
      if (_medicalRecordId != null) {
        _loadMedications();
      }
    });
  }
  
  // Cargar el ID del registro médico desde SharedPreferences
  Future<void> _loadMedicalRecordId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        // Aquí debes usar la clave correcta donde guardas el ID del registro médico
        _medicalRecordId = prefs.getInt('medical_record_id');
        
        // Para propósitos de prueba, si no hay ID guardado, usar uno predeterminado
        // Elimina esta línea en producción y maneja el caso de ID nulo adecuadamente
        _medicalRecordId ??= 1; // ID de prueba
      });
    } catch (e) {
      print('Error loading medical record ID: $e');
      setState(() {
        _errorMessage = 'Error loading patient data';
        _isLoading = false;
      });
    }
  }
  
  // Cargar medicaciones desde el servicio
  Future<void> _loadMedications() async {
    if (_medicalRecordId == null) {
      setState(() {
        _errorMessage = 'No medical record ID found';
        _isLoading = false;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Obtener medicaciones del servicio
      final medications = await _medicalRecordService.getMedicationsByRecordId(_medicalRecordId!);
      
      setState(() {
        _medications = medications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading medications: $e');
      setState(() {
        _errorMessage = 'Error loading medications';
        _isLoading = false;
      });
    }
  }

  // Listener para los campos de exámenes
  void _addExamTextFieldListener(TextEditingController controller) {
    controller.addListener(() {
      if (_examItems.isNotEmpty && _examItems.last.controller.text.isNotEmpty) {
        setState(() {
          _examItems.add(ExamItem(
            controller: TextEditingController(),
            isChecked: false,
          ));
          _addExamTextFieldListener(_examItems.last.controller);
        });
      }
    });
  }

  // Función para seleccionar archivos PDF
  Future<void> _pickFiles() async {
    var status = await Permission.storage.request();
    
    if (status.isGranted) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: true,
        );

        if (result != null) {
          setState(() {
            _selectedFiles = result.files;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedFiles.length} archivo(s) seleccionado(s)'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar archivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se requieren permisos de almacenamiento para seleccionar archivos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Formatear la información de dosificación
  String _formatDosage(Medication medication) {
    List<String> parts = [];
    
    if (medication.quantity != null && medication.quantity!.isNotEmpty && medication.quantity != '0') {
      parts.add('${medication.quantity}');
    }
    
    if (medication.concentration != null && medication.concentration!.isNotEmpty && medication.concentration != '0') {
      parts.add('${medication.concentration}');
    }
    
    if (parts.isEmpty) {
      return 'No dosage info';
    }
    
    return parts.join(' - ');
  }
  
  // Formatear la información de frecuencia
  String _formatFrequency(Medication medication) {
    if (medication.frequency != null && medication.frequency!.isNotEmpty && medication.frequency != 'Unknown') {
      return medication.frequency!;
    }
    return '';
  }

  @override
  void dispose() {
    // Liberar los controladores de exámenes
    for (var item in _examItems) {
      item.controller.dispose();
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con logo y título
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2D1F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "HC",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "HormonalCare",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const Spacer(),
                    // Botón de recarga
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadMedications,
                      tooltip: 'Reload medications',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Título de medicación y contador
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's medication",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${_medications.length} medications",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 32),
                
                // Mostrar indicador de carga o mensaje de error
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFBFA2C7),
                    ),
                  )
                else if (_errorMessage.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                // Mostrar mensaje si no hay medicaciones
                else if (_medications.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "No medications found",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                // Mostrar lista de medicaciones
                else
                  ...List.generate(_medications.length, (index) {
                    final medication = _medications[index];
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFBFA2C7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título de la medicación
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Medication ${index + 1}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Nombre y dosis de la medicación
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nombre del medicamento
                                    Row(
                                      children: [
                                        const Icon(Icons.medication, size: 20, color: Colors.deepPurple),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            medication.drugName ?? 'Unknown medication',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    const Divider(height: 1),
                                    const SizedBox(height: 8),
                                    
                                    // Dosis
                                    Row(
                                      children: [
                                        const Icon(Icons.scale, size: 20, color: Colors.deepPurple),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Dosage: ${_formatDosage(medication)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Frecuencia (si está disponible)
                                    if (medication.frequency != null && medication.frequency!.isNotEmpty && medication.frequency != 'Unknown')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.schedule, size: 20, color: Colors.deepPurple),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Frequency: ${_formatFrequency(medication)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    
                                    // Duración (si está disponible)
                                    if (medication.duration != null && medication.duration!.isNotEmpty && medication.duration != 'Unknown')
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.date_range, size: 20, color: Colors.deepPurple),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Duration: ${medication.duration}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                
                const SizedBox(height: 16),
                
                // Sección de exámenes
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFA2C7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Exams to evaluate",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Lista dinámica de exámenes
                      ...List.generate(_examItems.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _examItems[index].isChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      _examItems[index].isChecked = value ?? false;
                                    });
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: const BorderSide(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  height: 50,
                                  child: TextField(
                                    controller: _examItems[index].controller,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter exam name",
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                
                // Mostrar archivos seleccionados
                if (_selectedFiles.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2D1F4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selected Files",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(_selectedFiles.length, (index) {
                          final file = _selectedFiles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.picture_as_pdf, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    file.name,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _selectedFiles.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Upload button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _pickFiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBFA2C7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Upload your exams",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                
              ],
            ),
          ),
        ),
      ),
      

      // Bottom navigation bar
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreenPatient()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DoctorListScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppointmentScreenPatient()), //cambiar por una solo para pacientes

              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TreatmentTrackerScreen(
                        //preferredName: 'Patient',
                        )),
              );
              break;
          }
        },
      ),
    );
  }
}

class ExamItem {
  final TextEditingController controller;
  bool isChecked;

  ExamItem({
    required this.controller,
    required this.isChecked,
  });
}