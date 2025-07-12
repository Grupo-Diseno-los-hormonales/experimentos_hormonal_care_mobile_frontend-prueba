import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/appointment_screen_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/doctor_chat_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/treatment_tracker/presentation/pages/treatment_tracker_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen_patient.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/widgets/language_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({Key? key}) : super(key: key);

  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final MedicalAppointmentApi _appointmentApi = MedicalAppointmentApi();
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _selectedSpecialty = '';
  List<String> _specialties = [];
  late int _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _loadCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializar las especialidades con la traducción después de que el contexto esté disponible
    if (_selectedSpecialty.isEmpty) {
      _selectedSpecialty = AppLocalizations.of(context)?.allButton ?? 'All';
      if (_specialties.isEmpty) {
        _specialties = [_selectedSpecialty];
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = await JwtStorage.getUserId(); // este método ya lo usas
      if (userId != null) {
        setState(() {
          _currentUserId = userId;
        });
      } else {
        throw Exception(AppLocalizations.of(context)?.userIdErrorMessage ?? 'No se pudo obtener el ID del usuario');
      }
    } catch (e) {
      print('Error obteniendo userId: $e');
    }
  }

  // Método para obtener la traducción de una especialidad
  String _getTranslatedSpecialty(String specialty) {
    switch (specialty.toLowerCase()) {
      case 'diabetes':
        return AppLocalizations.of(context)?.diabetesButton ?? 'Diabetes';
      case 'hormones':
        return AppLocalizations.of(context)?.hormonesButton ?? 'Hormones';
      case 'obesity':
        return AppLocalizations.of(context)?.obesityButton ?? 'Obesity';
      case 'thyroid':
        return AppLocalizations.of(context)?.thyroidButton ?? 'Thyroid';
      default:
        return specialty;
    }
  }
  
  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Obtener la lista de doctores usando el nuevo endpoint
      final doctors = await _appointmentApi.fetchAllDoctors();
      
      // Extraer especialidades únicas para el filtro y traducirlas
      final specialtiesSet = <String>{};
      for (var doctor in doctors) {
        if (doctor['specialty'] != null && doctor['specialty'].isNotEmpty) {
          specialtiesSet.add(_getTranslatedSpecialty(doctor['specialty']));
        }
      }
      
      setState(() {
        _doctors = doctors;
        _specialties = [AppLocalizations.of(context)?.allButton ?? 'All', ...specialtiesSet.toList()..sort()];
        _isLoading = false;
      });
      
      print('Loaded ${doctors.length} doctors successfully');
    } catch (e) {
      print('Error loading doctors: $e');
      setState(() {
        _errorMessage = 'Failed to load doctors: $e';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFilteredDoctors() {
    final allText = AppLocalizations.of(context)?.allButton ?? 'All';
    return _doctors.where((doctor) {
      // Filtrar por búsqueda en el nombre
      final nameMatches = doctor['fullName']?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      
      // Filtrar por especialidad
      final specialtyMatches = _selectedSpecialty == allText || 
                              _getTranslatedSpecialty(doctor['specialty'] ?? '') == _selectedSpecialty;
      
      return nameMatches && specialtyMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _getFilteredDoctors();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.findADoctorTitle ?? 'Find a Doctor',
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
            onPressed: _loadDoctors,
            tooltip: AppLocalizations.of(context)?.refreshDoctorsTooltip ?? 'Refresh doctors',
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
                    hintText: AppLocalizations.of(context)?.searchDoctorsHint ?? 'Search doctors...',
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
                              AppLocalizations.of(context)?.errorLoadingDoctorsMessage ?? 'Error loading doctors',
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
                              onPressed: _loadDoctors,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA78AAB),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              child: Text(AppLocalizations.of(context)?.retryButton ?? 'Retry'),
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
                                Text(
                                  AppLocalizations.of(context)?.noDoctorsFoundMessage ?? 'No doctors found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)?.tryChangingSearchCriteriaMessage ?? 'Try changing your search criteria',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDoctors,
                            color: const Color(0xFFA78AAB),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredDoctors.length,
                              itemBuilder: (context, index) {
                                final doctor = filteredDoctors[index];
                                return _buildDoctorCard(doctor);
                              },
                            ),
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
      floatingActionButton: const LanguageButton(),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDoctorDetails(doctor),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto del doctor
              CircleAvatar(
                radius: 40,
                backgroundImage: doctor['imageUrl'] != null
                    ? NetworkImage(doctor['imageUrl'])
                    : null,
                backgroundColor: Colors.grey[200],
                child: doctor['imageUrl'] == null
                    ? const Icon(Icons.person, size: 40, color: Color(0xFFA78AAB))
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Información del doctor
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          doctor['fullName'] ?? (AppLocalizations.of(context)?.unknownDoctorLabel ?? 'Unknown Doctor'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8), // Espacio entre el nombre y la imagen
                        // Agregar la imagen de verificado
                        Image.asset('assets/images/verified.png', width: 18, height: 18), // Ajusta el tamaño según necesites
                      ],
                    ), // Fin del Row para el nombre y la imagen
                    const SizedBox(height: 4),
                    Text(
                      _getTranslatedSpecialty(doctor['specialty'] ?? '') != '' 
                        ? _getTranslatedSpecialty(doctor['specialty'] ?? '')
                        : (AppLocalizations.of(context)?.generalMedicineLabel ?? 'General Medicine'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _scheduleAppointment(doctor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA78AAB),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)?.scheduleAppointmentButton ?? 'Schedule Appointment',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
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
  }

  void _showDoctorDetails(Map<String, dynamic> doctor) {
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
                    backgroundImage: doctor['imageUrl'] != null
                        ? NetworkImage(doctor['imageUrl'])
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: doctor['imageUrl'] == null
                        ? const Icon(Icons.person, size: 40, color: Color(0xFFA78AAB))
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['fullName'] ?? (AppLocalizations.of(context)?.unknownDoctorLabel ?? 'Unknown Doctor'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              // Experiencia
              Text(
                AppLocalizations.of(context)?.experienceLabel ?? 'Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getTranslatedSpecialty(doctor['specialty'] ?? '') != '' 
                  ? _getTranslatedSpecialty(doctor['specialty'] ?? '')
                  : (AppLocalizations.of(context)?.notSpecifiedLabel ?? 'Not specified'),
                style: const TextStyle(fontSize: 16),
              ),
              
              const SizedBox(height: 16),
              
              
              // Información de contacto
              if (doctor['phoneNumber'] != null || doctor['email'] != null) ...[
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)?.contactInformationLabel ?? 'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (doctor['phoneNumber'] != null)
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 18, color: Color(0xFFA78AAB)),
                      const SizedBox(width: 8),
                      Text(
                        doctor['phoneNumber'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                if (doctor['email'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email, size: 18, color: Color(0xFFA78AAB)),
                      const SizedBox(width: 8),
                      Text(
                        doctor['email'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ],
              
              const Spacer(),
              
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
                  child: Text(
                    AppLocalizations.of(context)?.scheduleAppointmentButton ?? 'Schedule Appointment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
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
    if (doctor['userId'] == null) {
      if (doctor['id'] != null) {
        doctor['userId'] = doctor['id'];
      } else if (doctor['profileId'] != null) {
        doctor['userId'] = doctor['profileId'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.doctorIdErrorMessage ?? 'Error: Could not get doctor ID')),
        );
        return;
      }
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorChatScreen(
          doctor: doctor, 
          currentUserId: _currentUserId,
        ),
      ),
    );
  }
}