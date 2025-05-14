import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/appointment_screen_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/data/data_sources/remote/doctor_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/treatment_tracker/presentation/pages/treatment_tracker_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorListScreen extends StatefulWidget {
  final int? patientId;

  const DoctorListScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final DoctorService _doctorService = DoctorService();
  final ProfileService _profileService = ProfileService();
  
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  List<String> _specialties = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Obtener la lista de doctores
      final doctors = await _getAllDoctors();
      
      // Extraer especialidades únicas para el filtro
      final specialtiesSet = <String>{};
      for (var doctor in doctors) {
        if (doctor['specialty'] != null && doctor['specialty'].isNotEmpty) {
          specialtiesSet.add(doctor['specialty']);
        }
      }
      
      setState(() {
        _doctors = doctors;
        _specialties = ['All', ...specialtiesSet.toList()..sort()];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading doctors: $e');
      setState(() {
        _errorMessage = 'Failed to load doctors: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getAllDoctors() async {
    try {
      final token = await JwtStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      // Obtener la lista de todos los doctores
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/v1/doctor/doctors'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> doctorsData = json.decode(response.body);
        final List<Map<String, dynamic>> doctorsWithDetails = [];
        
        // Para cada doctor, obtener su información de perfil
        for (var doctor in doctorsData) {
          try {
            final doctorId = doctor['id'];
            final profileId = doctor['profileId'];
            
            if (profileId != null) {
              final profileDetails = await _profileService.fetchProfileDetails(profileId);
              
              doctorsWithDetails.add({
                'id': doctorId,
                'profileId': profileId,
                'fullName': profileDetails['fullName'] ?? 'Unknown',
                'specialty': doctor['specialty'] ?? 'General Medicine',
                'experience': doctor['experience'] ?? 'Not specified',
                'image': profileDetails['image'] ?? '',
                'about': doctor['about'] ?? 'No information available',
                'rating': (doctor['rating'] ?? 0.0).toDouble(),
              });
            }
          } catch (e) {
            print('Error fetching details for doctor: $e');
          }
        }
        
        return doctorsWithDetails;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or expired token');
      } else {
        throw Exception('Failed to load doctors: ${response.statusCode}');
      }
    } catch (e) {
      // Si hay un error o no hay conexión, usar datos de ejemplo
      print('Error fetching doctors, using sample data: $e');
      return [
        {
          'id': 1,
          'profileId': 101,
          'fullName': 'Dr. María Rodríguez',
          'specialty': 'Endocrinología',
          'rating': 4.8,
          'experience': '10 años',
          'image': 'https://randomuser.me/api/portraits/women/44.jpg',
          'about': 'Especialista en trastornos hormonales y metabólicos con enfoque en salud femenina.',
        },
        {
          'id': 2,
          'profileId': 102,
          'fullName': 'Dr. Carlos Mendoza',
          'specialty': 'Ginecología',
          'rating': 4.6,
          'experience': '15 años',
          'image': 'https://randomuser.me/api/portraits/men/32.jpg',
          'about': 'Especializado en salud reproductiva y tratamientos hormonales.',
        },
        {
          'id': 3,
          'profileId': 103,
          'fullName': 'Dra. Ana Gómez',
          'specialty': 'Endocrinología',
          'rating': 4.9,
          'experience': '8 años',
          'image': 'https://randomuser.me/api/portraits/women/68.jpg',
          'about': 'Enfocada en trastornos tiroideos y balance hormonal.',
        },
        {
          'id': 4,
          'profileId': 104,
          'fullName': 'Dr. Javier Pérez',
          'specialty': 'Medicina Interna',
          'rating': 4.7,
          'experience': '12 años',
          'image': 'https://randomuser.me/api/portraits/men/46.jpg',
          'about': 'Especialista en diagnóstico y tratamiento de enfermedades complejas.',
        },
        {
          'id': 5,
          'profileId': 105,
          'fullName': 'Dra. Lucía Martínez',
          'specialty': 'Ginecología',
          'rating': 4.5,
          'experience': '7 años',
          'image': 'https://randomuser.me/api/portraits/women/90.jpg',
          'about': 'Especializada en salud hormonal femenina y tratamientos personalizados.',
        },
      ];
    }
  }

  List<Map<String, dynamic>> _getFilteredDoctors() {
    return _doctors.where((doctor) {
      // Filtrar por búsqueda
      final nameMatches = doctor['fullName'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filtrar por especialidad
      final specialtyMatches = _selectedSpecialty == 'All' || 
                              doctor['specialty'] == _selectedSpecialty;
      
      return nameMatches && specialtyMatches;
    }).toList();
  }

  void _viewDoctorDetails(Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado con foto y nombre
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(doctor['image'] ?? 'https://via.placeholder.com/80'),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['fullName'] ?? 'Unknown Doctor',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor['specialty'] ?? 'General Medicine',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${doctor['rating'] ?? 0.0}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Experiencia
              const Text(
                'Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor['experience'] ?? 'Not specified',
                style: const TextStyle(fontSize: 16),
              ),
              
              const SizedBox(height: 16),
              
              // Acerca de
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor['about'] ?? 'No information available',
                style: const TextStyle(fontSize: 16),
              ),
              
              const SizedBox(height: 24),
              
              // Botón para agendar cita
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar el modal
                    _scheduleAppointment(doctor);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA78AAB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Schedule Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _scheduleAppointment(Map<String, dynamic> doctor) {
    // Aquí implementarías la navegación a la pantalla de programación de citas
    // con el doctor seleccionado
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scheduling appointment with ${doctor['fullName']}'),
        backgroundColor: const Color(0xFFA78AAB),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Ejemplo de navegación a una pantalla de programación de citas
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ScheduleAppointmentScreen(
    //       doctorId: doctor['id'],
    //       doctorName: doctor['fullName'],
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _getFilteredDoctors();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Find a Doctor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFA78AAB),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDoctors,
            tooltip: 'Refresh doctors',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search doctors...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFA78AAB)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                // Filtro de especialidades
                const SizedBox(height: 16),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specialties.length,
                    itemBuilder: (context, index) {
                      final specialty = _specialties[index];
                      final isSelected = specialty == _selectedSpecialty;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(specialty),
                          selected: isSelected,
                          selectedColor: const Color(0xFFA78AAB),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedSpecialty = specialty;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFA78AAB)))
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading doctors',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _fetchDoctors,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA78AAB),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredDoctors.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  'No doctors found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try changing your search criteria',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredDoctors.length,
                            itemBuilder: (context, index) {
                              final doctor = filteredDoctors[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () => _viewDoctorDetails(doctor),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Foto del doctor
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundImage: NetworkImage(doctor['image'] ?? 'https://via.placeholder.com/80'),
                                          backgroundColor: Colors.grey[200],
                                        ),
                                        const SizedBox(width: 16),
                                        
                                        // Información del doctor
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                doctor['fullName'] ?? 'Unknown Doctor',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                doctor['specialty'] ?? 'General Medicine',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star, color: Colors.amber, size: 18),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${doctor['rating'] ?? 0.0}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  const Icon(Icons.work, color: Color(0xFFA78AAB), size: 18),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    doctor['experience'] ?? 'Unknown',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              ElevatedButton(
                                                onPressed: () => _scheduleAppointment(doctor),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFA78AAB),
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Schedule Appointment',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1, // Índice para la pantalla de doctores
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreenPatient()),
              );
              break;
            case 1:
              // Ya estamos en esta pantalla
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AppointmentScreenPatient()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TreatmentTrackerScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}