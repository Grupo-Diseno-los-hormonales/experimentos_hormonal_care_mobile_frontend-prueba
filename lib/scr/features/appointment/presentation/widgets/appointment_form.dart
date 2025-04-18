import 'dart:math'; // Importa Random para JitsiMeetingLinkGenerator
import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/data/repositories/medical_appointment_repository.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/widgets/custom_buttons.dart';
import 'package:confetti/confetti.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class JitsiMeetingLinkGenerator {
  static const String _baseUrl = 'https://meet.jit.si/';

  static String generateMeetingLink({String? roomPrefix}) {
    final String randomString = _generateRandomString(10);
    final String roomName = roomPrefix != null ? '$roomPrefix-$randomString' : randomString;
    return '$_baseUrl$roomName';
  }

  static String _generateRandomString(int length) {
    const String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
}

class AppointmentForm extends StatefulWidget {
  final int patientId;

  AppointmentForm({required this.patientId});

  @override
  _AppointmentFormState createState() => _AppointmentFormState();
}

class _AppointmentFormState extends State<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ConfettiController _confettiController = ConfettiController();

  DateTime? _selectedDate;

  final MedicalAppointmentRepository repository = MedicalAppointmentRepository(MedicalAppointmentApi());

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  void _clearFields() {
    _dateController.clear();
    _fromTimeController.clear();
    _toTimeController.clear();
    _titleController.clear();
    _selectedDate = null;
  }

  Future<bool> _isTimeSlotAvailable(String startTime, String endTime) async {
    final userId = await JwtStorage.getUserId();
    final role = await JwtStorage.getRole();

    if (role != 'ROLE_DOCTOR') {
      throw Exception('Only doctors can create appointments');
    }

    final existingAppointments = await repository.fetchAppointmentsForToday();
    final newStart = DateTime.parse("${_selectedDate!.toIso8601String().split('T')[0]} $startTime:00");
    final newEnd = DateTime.parse("${_selectedDate!.toIso8601String().split('T')[0]} $endTime:00");

    for (var appointment in existingAppointments) {
      final existingStart = DateTime.parse("${appointment['eventDate']} ${appointment['startTime']}:00");
      final existingEnd = DateTime.parse("${appointment['eventDate']} ${appointment['endTime']}:00");

      if (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      final startTime = _fromTimeController.text;
      final endTime = _toTimeController.text;

      if (!await _isTimeSlotAvailable(startTime, endTime)) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('The selected time slot is not available.')));
        return;
      }

      final userId = await JwtStorage.getUserId();

      final appointmentData = {
        'eventDate': _selectedDate!.toIso8601String().split('T')[0],
        'startTime': startTime,
        'endTime': endTime,
        'title': _titleController.text,
        'description': JitsiMeetingLinkGenerator.generateMeetingLink(roomPrefix: _titleController.text),
        'doctorId': userId,
        'patientId': widget.patientId,
        'color': '0xFF039BE5', // Default color
      };

      final success = await repository.createMedicalAppointment(appointmentData);
      if (success) {
        Navigator.pop(context);
        _confettiController.play();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Medical appointment created successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create medical appointment.')));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  String? _validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a time';
    }
    final timeRegExp = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    if (!timeRegExp.hasMatch(value)) {
      return 'Please enter a valid time in 24-hour format (HH:mm)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final limaTimeZone = tz.getLocation('America/Lima');
    final now = tz.TZDateTime.now(limaTimeZone);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6, // Ajusta el valor según sea necesario
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Field: Meeting Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Title of the meeting',
                    prefixIcon: Icon(Icons.title),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the title of the meeting';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),

                // Field: Date
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    hintText: 'Day',
                    prefixIcon: Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  style: TextStyle(fontSize: 14),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    if (_selectedDate != null) {
                      final selectedDateInLima = tz.TZDateTime.from(_selectedDate!, limaTimeZone);
                      final nowInLima = tz.TZDateTime.now(limaTimeZone);
                      if (selectedDateInLima.isBefore(nowInLima.subtract(Duration(days: 1)))) {
                        return 'The date cannot be in the past';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),

                // Field: Time "From"
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _fromTimeController,
                        decoration: InputDecoration(
                          labelText: 'From',
                          hintText: 'Hour',
                          prefixIcon: Icon(Icons.access_time),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        style: TextStyle(fontSize: 14),
                        validator: _validateTime,
                      ),
                    ),
                    SizedBox(width: 12),

                    // Field: Time "To"
                    Expanded(
                      child: TextFormField(
                        controller: _toTimeController,
                        decoration: InputDecoration(
                          labelText: 'To',
                          hintText: 'Hour',
                          prefixIcon: Icon(Icons.access_time),
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        style: TextStyle(fontSize: 14),
                        validator: (value) {
                          final error = _validateTime(value);
                          if (error != null) return error;
                          if (_fromTimeController.text.isNotEmpty && value != null) {
                            final fromTime = _fromTimeController.text.split(':').map(int.parse).toList();
                            final toTime = value.split(':').map(int.parse).toList();
                            final from = DateTime(0, 0, 0, fromTime[0], fromTime[1]);
                            final to = DateTime(0, 0, 0, toTime[0], toTime[1]);
                            if (to.isBefore(from)) {
                              return 'End time must be after start time';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Custom buttons (Clear and Create event)
                CustomButtons(
                  onClear: _clearFields,
                  onCreate: _createEvent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}