import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/screens/add_appointment.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/screens/appointment_detail.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/data/data_sources/remote/patient_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomePatientsScreen extends StatefulWidget {
  final int doctorId;

  HomePatientsScreen({required this.doctorId});

  @override
  _HomePatientsScreenState createState() => _HomePatientsScreenState();
}

class _HomePatientsScreenState extends State<HomePatientsScreen> {
  final MedicalAppointmentApi _appointmentApi = MedicalAppointmentApi();
  final PatientService _patientService = PatientService();
  final ProfileService _profileService = ProfileService();

  List<Map<String, String>> patients = [];
  String errorMessage = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      isLoading = true;
    });

    try {
      final role = await JwtStorage.getRole();

      if (role != 'ROLE_DOCTOR') {
        throw Exception('Only doctors can view patients');
      }

      final appointments = await _appointmentApi.fetchAppointmentsForToday();
      final List<Map<String, String>> fetchedPatients = [];
      final limaTimeZone = tz.getLocation('America/Lima');

      for (var appointment in appointments) {
        final patientDetails = await _patientService.fetchPatientDetails(appointment['patientId']);
        final profileDetails = await _profileService.fetchProfileDetails(patientDetails['profileId']);
        fetchedPatients.add({
          'name': profileDetails['fullName'] ?? 'No name',
          'time': appointment['startTime'] ?? 'No start time',
          'endTime': appointment['endTime'] ?? 'No end time',
          'image': profileDetails['image'] ?? '',
          'eventDate': appointment['eventDate'] ?? 'No date',
          'patientId': appointment['patientId'].toString(),
          'title': appointment['title'] ?? 'No title',
          'description': appointment['description'] ?? 'No description',
          'color': appointment['color'] ?? '0xFF039BE5',
          'appointmentId': appointment['id'].toString(),
        });
      }

      fetchedPatients.sort((a, b) {
        final aTime = tz.TZDateTime.from(DateTime.parse(a['eventDate']!), limaTimeZone);
        final bTime = tz.TZDateTime.from(DateTime.parse(b['eventDate']!), limaTimeZone);
        return aTime.compareTo(bTime);
      });

      setState(() {
        patients = fetchedPatients;
        errorMessage = '';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching patients: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final limaTimeZone = tz.getLocation('America/Lima');
    final now = tz.TZDateTime.now(limaTimeZone);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text("Today's Patients"),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPatients,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final eventDate = tz.TZDateTime.from(DateTime.parse(patients[index]['eventDate']!), limaTimeZone);
                      final isPast = eventDate.isBefore(now);

                      // Agregar fecha actual a las horas para evitar errores de formato
                      final today = DateTime.now();
                      final startTime = DateTime.parse("${today.toIso8601String().split('T')[0]} ${patients[index]['time']!}");
                      final endTime = DateTime.parse("${today.toIso8601String().split('T')[0]} ${patients[index]['endTime']!}");

                      final formattedStartTime = "${startTime.hour % 12 == 0 ? 12 : startTime.hour % 12}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.hour >= 12 ? 'PM' : 'AM'}";
                      final formattedEndTime = "${endTime.hour % 12 == 0 ? 12 : endTime.hour % 12}:${endTime.minute.toString().padLeft(2, '0')} ${endTime.hour >= 12 ? 'PM' : 'AM'}";

                      return Card(
                        color: isPast ? Color(0xFFB0BEC5) : Color(0xFFD1C4E9), // Cambiar color de fondo
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(patients[index]['image']!),
                            backgroundColor: Color(0xFF9575CD), // Cambiar color del avatar
                          ),
                          title: Text(
                            patients[index]['name']!,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A148C)), // Cambiar color del texto
                          ),
                          subtitle: Text(
                            "${patients[index]['age']} years old",
                            style: TextStyle(color: Color(0xFF6A1B9A)),
                          ),
                          trailing: Text(
                            "$formattedStartTime - $formattedEndTime",
                            style: TextStyle(color: Color(0xFF4A148C), fontWeight: FontWeight.bold), // Mostrar hora inicio y fin
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final now = DateTime.now();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddAppointmentScreen(
                selectedDate: now,
              ),
            ),
          );

          if (result == true) {
            _fetchPatients();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF6A828D),
      ),
    );
  }
}