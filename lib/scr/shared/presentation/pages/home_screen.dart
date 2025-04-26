import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista de medicaciones
  final List<MedicationItem> _medicationItems = [
    MedicationItem(
      nameController: TextEditingController(text: "Levothyroxine"),
      dosageController: TextEditingController(text: "100 mcg"),
    ),
  ];
  
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
    
    // Inicializar listeners para las medicaciones
    for (var item in _medicationItems) {
      _addMedicationTextFieldListener(item);
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

  // Listener para los campos de medicación
  void _addMedicationTextFieldListener(MedicationItem item) {
    void checkAndAddNew() {
      // Si ambos campos del último elemento tienen texto, agregar uno nuevo
      if (_medicationItems.isNotEmpty &&
          _medicationItems.last.nameController.text.isNotEmpty &&
          _medicationItems.last.dosageController.text.isNotEmpty) {
        setState(() {
          final newItem = MedicationItem(
            nameController: TextEditingController(),
            dosageController: TextEditingController(),
          );
          _medicationItems.add(newItem);
          _addMedicationTextFieldListener(newItem);
        });
      }
    }

    // Agregar listeners a ambos controladores
    item.nameController.addListener(checkAndAddNew);
    item.dosageController.addListener(checkAndAddNew);
  }

  // Eliminar una medicación específica
  void _removeMedication(int index) {
    // No eliminar si solo queda un elemento
    if (_medicationItems.length <= 1) return;
    
    setState(() {
      final item = _medicationItems.removeAt(index);
      // Liberar los controladores
      item.nameController.dispose();
      item.dosageController.dispose();
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

  @override
  void dispose() {
    // Liberar los controladores de medicaciones
    for (var item in _medicationItems) {
      item.nameController.dispose();
      item.dosageController.dispose();
    }
    
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
                      "${_medicationItems.where((item) => item.nameController.text.isNotEmpty).length} medications",
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
                
                // Lista dinámica de medicaciones
                ...List.generate(_medicationItems.length, (index) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFBFA2C7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Solo mostrar título y botón de eliminar si no es el primer elemento o si hay más de uno
                            if (_medicationItems.length > 1 || index > 0) 
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
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                                    onPressed: () => _removeMedication(index),
                                    iconSize: 20,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            if (_medicationItems.length > 1 || index > 0) 
                              const SizedBox(height: 8),
                            
                            // Campos de nombre y dosis
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    height: 50,
                                    child: TextField(
                                      controller: _medicationItems[index].nameController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Medication name",
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    height: 50,
                                    child: TextField(
                                      controller: _medicationItems[index].dosageController,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Dosage",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchDoctorPage()),
              );*/
              break;
            case 2:
              /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationScreen()),
              );*/
              break;
            case 3:
              /*Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const TreatmentTrackerScreen(
                        //preferredName: 'Patient',
                        )),
              );*/
              break;
          }
        },
      ),
    );
  }
}

class MedicationItem {
  final TextEditingController nameController;
  final TextEditingController dosageController;

  MedicationItem({
    required this.nameController,
    required this.dosageController,
  });
}

class ExamItem {
  final TextEditingController controller;
  bool isChecked;

  ExamItem({
    required this.controller,
    required this.isChecked,
  });
}