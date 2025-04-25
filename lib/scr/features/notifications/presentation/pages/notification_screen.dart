import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/notifications/data/data_sources/remote/notifications_service.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  final int doctorId;

  NotificationScreen({required this.doctorId});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<Map<String, dynamic>> _appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      List<Map<String, dynamic>> appointments = await _notificationService.fetchDoctorAppointments(widget.doctorId);
      DateTime now = DateTime.now();
      DateTime nowPlus30 = now.add(Duration(minutes: 30));

      for (var appointment in appointments) {
        final patientId = appointment['patientId'];
        final patientProfile = await _notificationService.fetchPatientProfile(patientId);
        final patientName = patientProfile['fullName'];
        appointment['patientName'] = patientName;
      }

      setState(() {
        _appointments = appointments.where((appointment) {
          DateTime eventDate = DateFormat('yyyy-MM-dd').parse(appointment['eventDate']);
          TimeOfDay startTime = TimeOfDay(
            hour: int.parse(appointment['startTime'].split(':')[0]),
            minute: int.parse(appointment['startTime'].split(':')[1]),
          );
          DateTime appointmentStart = DateTime(eventDate.year, eventDate.month, eventDate.day, startTime.hour, startTime.minute);
          return appointmentStart.isAfter(now) && appointmentStart.isBefore(nowPlus30);
        }).toList();
      });
    } catch (e) {
      // Manejo de errores
    }
  }

  void _removeAppointment(int appointmentId) {
    setState(() {
      _appointments.removeWhere((appointment) => appointment['id'] == appointmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8F7193), // Fondo morado oscuro
      ),
      body: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              color: const Color(0xFFDFCAE1), // Fondo morado claro
              child: ListTile(
                title: Text(
                  'Next Appointment: ${appointment['title']}',
                  style: const TextStyle(color: Color(0xFF8F7193)), // Texto morado oscuro
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['patientName'],
                      style: const TextStyle(color: Color(0xFFA788AB)), // Texto morado intermedio
                    ),
                    Text(
                      '${appointment['startTime']} - ${appointment['endTime']}',
                      style: const TextStyle(color: Color(0xFFA788AB)), // Texto morado intermedio
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFF8F7193)), // Icono morado oscuro
                  onPressed: () => _removeAppointment(appointment['id']),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}