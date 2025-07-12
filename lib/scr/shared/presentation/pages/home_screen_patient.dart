import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/appointment_screen_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/doctors_list_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/diagnosis/domain/models/medication_model.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/diagnosis/domain/services/medicalrecord_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/treatment_tracker/presentation/pages/treatment_tracker_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/widgets/language_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  late List<ExamItem> _examItems;
  bool _examItemsInitialized = false;
  
  // Lista de archivos seleccionados
  List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    
    // Cargar medicaciones
    _loadMedicalRecordId().then((_) {
      if (_medicalRecordId != null) {
        _loadMedications();
      }
    });
  }
  
  // Inicializar la lista de exámenes con traducciones
  void _initializeExamItems(BuildContext context) {
    _examItems = [
      ExamItem(controller: TextEditingController(text: AppLocalizations.of(context)?.hormonalTestLabel ?? "Hormonal test"), isChecked: false),
      ExamItem(controller: TextEditingController(text: AppLocalizations.of(context)?.bloodTestLabel ?? "Blood test"), isChecked: false),
      ExamItem(controller: TextEditingController(), isChecked: false),
      ExamItem(controller: TextEditingController(), isChecked: false),
    ];
    
    // Inicializar listeners para los exámenes
    for (var item in _examItems) {
      _addExamTextFieldListener(item.controller);
    }
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
        _errorMessage = AppLocalizations.of(context)?.errorLoadingPatientDataMessage ?? 'Error loading patient data';
        _isLoading = false;
      });
    }
  }
  
  // Cargar medicaciones desde el servicio
  Future<void> _loadMedications() async {
    if (_medicalRecordId == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)?.noMedicalRecordIdFoundMessage ?? 'No medical record ID found';
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
        _errorMessage = AppLocalizations.of(context)?.errorLoadingMedicationsMessage ?? 'Error loading medications';
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
              content: Text(AppLocalizations.of(context)?.filesSelectedMessage(_selectedFiles.length) ?? '${_selectedFiles.length} file(s) selected'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.errorSelectingFilesMessage(e.toString()) ?? 'Error selecting files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.storagePermissionRequiredMessage ?? 'Storage permissions are required to select files'),
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
      return AppLocalizations.of(context)?.noDosageInfoLabel ?? 'No dosage info';
    }
    
    String result = parts.join(' - ');
    
    // Traducir patrones específicos conocidos usando AppLocalizations
    if (result.contains('injection') && result.contains('units')) {
      // Extraer el número de unidades usando regex
      RegExp regExp = RegExp(r'(\d+)\s*units');
      Match? match = regExp.firstMatch(result);
      if (match != null) {
        String units = match.group(1) ?? '10';
        final localization = AppLocalizations.of(context);
        if (localization != null) {
          return localization.injectionUnitsLabel(units);
        }
      }
    }
    
    return result;
  }
  
  // Formatear la información de frecuencia
  String _formatFrequency(Medication medication) {
    if (medication.frequency != null && medication.frequency!.isNotEmpty && medication.frequency != 'Unknown') {
      String freq = medication.frequency!;
      
      // Traducir patrones específicos conocidos usando AppLocalizations
      if (freq.contains('times per day') || freq.contains('time per day')) {
        // Extraer el número de veces usando regex
        RegExp regExp = RegExp(r'(\d+)\s*times?\s*per\s*day');
        Match? match = regExp.firstMatch(freq);
        if (match != null) {
          String times = match.group(1) ?? '1';
          final localization = AppLocalizations.of(context);
          if (localization != null) {
            // Para español, usar singular para "1" y plural para el resto
            if (times == '1') {
              return localization.timesPerDayLabel(times).replaceAll('vez', 'vez');
            } else {
              return localization.timesPerDayLabel(times).replaceAll('vez', 'veces');
            }
          }
        }
      }
      
      // Traducir "daily" 
      if (freq.toLowerCase() == 'daily') {
        return AppLocalizations.of(context)?.dailyLabel ?? freq;
      }
      
      // Traducir "weekly"
      if (freq.toLowerCase() == 'weekly') {
        return AppLocalizations.of(context)?.weeklyLabel ?? freq;
      }
      
      // Traducir "monthly"
      if (freq.toLowerCase() == 'monthly') {
        return AppLocalizations.of(context)?.monthlyLabel ?? freq;
      }
      
      return freq;
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
    // Inicializar exámenes con traducciones solo una vez
    if (!_examItemsInitialized) {
      _initializeExamItems(context);
      _examItemsInitialized = true;
    }
    
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
                      tooltip: AppLocalizations.of(context)?.reloadMedicationsTooltip ?? 'Reload medications',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Título de medicación y contador
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.todayMedicationTitle ?? "Today's medication",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)?.medicationsCount(_medications.length) ?? "${_medications.length} medications",
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
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        AppLocalizations.of(context)?.noMedicationsFoundMessage ?? "No medications found",
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
                                    AppLocalizations.of(context)?.medicationNumberTitle(index + 1) ?? "Medication ${index + 1}",
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
                                            medication.drugName ?? (AppLocalizations.of(context)?.unknownMedicationLabel ?? 'Unknown medication'),
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
                                          '${AppLocalizations.of(context)?.dosageLabel ?? "Dosage:"} ${_formatDosage(medication)}',
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
                                              '${AppLocalizations.of(context)?.frequencyLabel ?? "Frequency:"} ${_formatFrequency(medication)}',
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
                                              '${AppLocalizations.of(context)?.durationLabel ?? "Duration:"} ${medication.duration}',
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
                      Text(
                        AppLocalizations.of(context)?.examsToEvaluateTitle ?? "Exams to evaluate",
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
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: AppLocalizations.of(context)?.enterExamNameHint ?? "Enter exam name",
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
                        Text(
                          AppLocalizations.of(context)?.selectedFilesTitle ?? "Selected Files",
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
                    child: Text(
                      AppLocalizations.of(context)?.uploadExamsButton ?? "Upload your exams",
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
      floatingActionButton: const LanguageButton(),
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