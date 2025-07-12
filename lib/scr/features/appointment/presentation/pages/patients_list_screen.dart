import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/widgets/language_button.dart';
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
        final patientDetails =
            await _patientService.fetchPatientDetails(appointment['patientId']);
        final profileDetails =
            await _profileService.fetchProfileDetails(patientDetails['profileId']);
        final age = _calculateAge(profileDetails['birthday']); // Calcular edad
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
          'age': age.toString(), // Agregar edad al mapa
        });
      }

      fetchedPatients.sort((a, b) {
        final aTime =
            tz.TZDateTime.from(DateTime.parse(a['eventDate']!), limaTimeZone);
        final bTime =
            tz.TZDateTime.from(DateTime.parse(b['eventDate']!), limaTimeZone);
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

  int _calculateAge(String? birthday) {
    if (birthday == null) return 0;
    final birthDate = DateTime.parse(birthday);
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
@override
Widget build(BuildContext context) {
  final limaTimeZone = tz.getLocation('America/Lima');
  final now = tz.TZDateTime.now(limaTimeZone);    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8F7193), // Fondo morado del AppBar
        title: Text(AppLocalizations.of(context)?.todayPatientsTitle ?? "Today's Patients"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    body: Column(
      children: [
        // Espaciado entre el encabezado y el cuadro morado
        SizedBox(height: 16.0),
        // Cuadro morado con la lista de pacientes
        Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0), // Márgenes laterales
            decoration: BoxDecoration(
              color: Color(0xFFA788AB), // Fondo morado
              borderRadius: BorderRadius.circular(16), // Bordes redondeados
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajustar el tamaño al contenido
              children: [
                // Encabezado con "Name" y "Date" con fondo diferente
                Container(
                  margin: EdgeInsets.all(16.0),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF8F7193), // Fondo del encabezado
                    borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)?.nameColumnHeader ?? 'Name',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)?.dateColumnHeader ?? 'Date',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de pacientes
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: RefreshIndicator(
                      onRefresh: _fetchPatients,
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : errorMessage.isNotEmpty
                              ? Center(child: Text(errorMessage))
                              : ListView.builder(
                                  shrinkWrap: true, // Ajustar al contenido
                                  padding: EdgeInsets.zero,
                                  itemCount: patients.length,
                                  itemBuilder: (context, index) {
                                    final eventDate = tz.TZDateTime.from(
                                        DateTime.parse(patients[index]['eventDate']!),
                                        limaTimeZone);
                                    final isPast = eventDate.isBefore(now);

                                    final today = DateTime.now();
                                    final startTime = DateTime.parse(
                                        "${today.toIso8601String().split('T')[0]} ${patients[index]['time']!}");
                                    final endTime = DateTime.parse(
                                        "${today.toIso8601String().split('T')[0]} ${patients[index]['endTime']!}");

                                    final formattedStartTime =
                                        "${startTime.hour % 12 == 0 ? 12 : startTime.hour % 12}:${startTime.minute.toString().padLeft(2, '0')} ${startTime.hour >= 12 ? 'PM' : 'AM'}";
                                    final formattedEndTime =
                                        "${endTime.hour % 12 == 0 ? 12 : endTime.hour % 12}:${endTime.minute.toString().padLeft(2, '0')} ${endTime.hour >= 12 ? 'PM' : 'AM'}";

                                    return Card(
                                      margin: EdgeInsets.symmetric(vertical: 8.0),
                                      color: Color(0xFFE5DDE6),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(patients[index]['image']!),
                                          backgroundColor: Color(0xFFA788AB),
                                        ),
                                        title: Text(
                                          patients[index]['name']!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF000000),
                                          ),
                                        ),
                                        subtitle: Text(
                                          "${patients[index]['age']} years old",
                                          style: TextStyle(color: Color(0xFF4A4A4A)),
                                        ),
                                        trailing: Text(
                                          "$formattedStartTime\n$formattedEndTime",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Color(0xFF000000),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Botón "Reassign date" fuera del cuadro morado
        Spacer(),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8F7193),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(vertical: 13),
            ),
            child: Text(
              AppLocalizations.of(context)?.reassignDateButton ?? 'Reassign date',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    ),
    floatingActionButton: LanguageButton(),
  );
}
}