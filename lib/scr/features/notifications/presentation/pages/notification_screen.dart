import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/notifications/data/data_sources/remote/notifications_service.dart';
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
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF40535B),
      ),
      body: ListView.builder(
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              color: const Color(0xFF6A828D),
              child: ListTile(
                title: Text(
                  'Next Appointment: ${appointment['title']}',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['patientName'],
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '${appointment['startTime']} - ${appointment['endTime']}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
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