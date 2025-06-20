import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/doctor_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDoctorDetail extends StatefulWidget {
  final int appointmentId;
  const AppointmentDoctorDetail({super.key, required this.appointmentId});

  @override
  State<AppointmentDoctorDetail> createState() => _AppointmentDoctorDetailState();
}

class _AppointmentDoctorDetailState extends State<AppointmentDoctorDetail> {
  final MedicalAppointmentApi _appointmentService = MedicalAppointmentApi();
  final ProfileService _profileService = ProfileService();

  Map<String, dynamic>? _appointmentDetails;
  Map<String, dynamic>? _doctorDetails;
  Map<String, dynamic>? _doctorProfessionalDetails;
  late int _currentUserId;
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadAppointmentDetails();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = await JwtStorage.getUserId(); 
      if (userId != null) {
        setState(() {
          _currentUserId = userId;
        });
      } else {
        throw Exception('No se pudo obtener el ID del usuario');
      }
    } catch (e) {
      print('Error obteniendo userId: $e');
    }
  }

  Future<void> _loadAppointmentDetails() async {
  try {
    final appointmentDetails = await _appointmentService.fetchAppointmentDetails(widget.appointmentId);
    if (appointmentDetails['doctorId'] != null) {
      _doctorProfessionalDetails = await _profileService.fetchDoctorProfessionalDetails(appointmentDetails['doctorId']);
    }
    final doctorDetails = await _appointmentService.fetchDoctorProfileDetails(appointmentDetails['doctorId']);

    setState(() {
      _appointmentDetails = appointmentDetails;
      _doctorDetails = doctorDetails;
    });
  } catch (e) {
    print('Error loading appointment details: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load appointment details: $e')),
    );
  }
}

  String _formatDate(String date, String startTime, String endTime) {
    final DateTime parsedDate = DateTime.parse(date);
    final DateFormat dateFormatter = DateFormat('EEEE, d \'de\' MMM.', 'es_ES');
    final DateFormat timeFormatter = DateFormat('h:mm a', 'es_ES');
    final DateTime parsedStartTime = DateTime.parse('$date $startTime');
    final DateTime parsedEndTime = DateTime.parse('$date $endTime');
    return '${dateFormatter.format(parsedDate)} ${timeFormatter.format(parsedStartTime)} - ${timeFormatter.format(parsedEndTime)}';
  }
  
  void _navigateToChatScreen() {
    if (_doctorDetails != null && _appointmentDetails != null) {
      // Crear un mapa con la información del doctor necesaria para el chat
      final doctorInfo = {
        'fullName': _doctorDetails!['fullName'],
        'imageUrl': _doctorDetails!['image'],
        'specialty': _doctorProfessionalDetails != null ? _doctorProfessionalDetails!['specialty'] : 'Doctor',
        'doctorId': _appointmentDetails!['doctorId'],
        'id': _appointmentDetails!['doctorId'],
      };
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorChatScreen(doctor: doctorInfo, currentUserId: _currentUserId,),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor information not available')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_appointmentDetails == null || _doctorDetails == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFA78AAB),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Appointment Detail',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFA78AAB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Appointment Detail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Color(0xFF8F7193),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                width: MediaQuery.of(context).size.width * 0.8, // Adjust width to be 80% of screen width
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundImage: _doctorDetails!['image'] != null
                          ? NetworkImage(_doctorDetails!['image'])
                          : null,
                      radius: 20,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _doctorDetails!['fullName'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(int.parse(_appointmentDetails!['color'].startsWith('0x') ? _appointmentDetails!['color'] : '0x${_appointmentDetails!['color']}')),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _appointmentDetails!['title'],
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                _formatDate(_appointmentDetails!['eventDate'], _appointmentDetails!['startTime'], _appointmentDetails!['endTime']),
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _appointmentDetails!['description']));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Meeting link copied to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy, color: Colors.blue),
                      label: const Text(
                        'Copy Link',
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = _appointmentDetails!['description'];
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch $url')),
                          );
                        }
                      },
                      icon: const Icon(Icons.link, color: Colors.blue),
                      label: const Text(
                        'Join Meeting',
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Nuevo botón para ir al chat
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: ElevatedButton.icon(
                onPressed: _navigateToChatScreen,
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text(
                  'Chat with Doctor',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA78AAB),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}