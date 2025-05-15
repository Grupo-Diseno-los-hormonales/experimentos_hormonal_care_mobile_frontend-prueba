import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/data/data_sources/remote/profile_service.dart';
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
  bool _isLoading = true;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _loadAppointmentDetails();
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
  
  @override
  Widget build(BuildContext context) {
    if (_appointmentDetails == null || _doctorDetails == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFA78AAB),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Appointment Detail',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFA78AAB),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
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
                      style: TextStyle(
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
                      icon: Icon(Icons.copy, color: Colors.blue),
                      label: Text(
                        'Copy Link',
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
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
                      icon: Icon(Icons.link, color: Colors.blue),
                      label: Text(
                        'Join Meeting',
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}