import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/pages/home_screen_patient.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/screens/add_appointment.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/screens/appointment_detail.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/custom_bottom_navigation_bar.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/treatment_tracker/presentation/pages/treatment_tracker_screen.dart';

class AppointmentScreenPatient extends StatefulWidget {
  const AppointmentScreenPatient({Key? key}) : super(key: key);

  @override
  _AppointmentScreenPatientState createState() => _AppointmentScreenPatientState();
}

class _AppointmentScreenPatientState extends State<AppointmentScreenPatient> {
  final List<Meeting> _meetings = <Meeting>[];
  final MedicalAppointmentApi _appointmentService = MedicalAppointmentApi();
  late MeetingDataSource calendarDataSource;
  CalendarView _calendarView = CalendarView.week;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPatientAppointments();
    calendarDataSource = MeetingDataSource(_meetings);
  }

  Future<void> _loadPatientAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Usar el nuevo método para obtener solo las citas del paciente
      final appointments = await _appointmentService.fetchAppointmentsByPatientId();
      final List<Meeting> loadedMeetings = appointments.map<Meeting>((appointment) {
        final startTime = DateTime.parse('${appointment['eventDate']}T${appointment['startTime']}:00');
        final endTime = DateTime.parse('${appointment['eventDate']}T${appointment['endTime']}:00');
        final colorValue = appointment['color'] ?? '0xFF039BE5';
        final color = Color(int.parse(colorValue.startsWith('0x') ? colorValue : '0x$colorValue'));

        return Meeting(
          appointment['title'],
          startTime,
          endTime,
          color,
          false,
          appointment['description'],
          appointment['id'].toString(),
        );
      }).toList();

      setState(() {
        calendarDataSource.updateMeetings(loadedMeetings);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading patient appointments: $e');
      setState(() {
        _errorMessage = 'Failed to load appointments: $e';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    }
  }

  void _onCalendarViewChanged(CalendarView newView) {
    if (_calendarView != newView) {
      debugPrint('Changing view from $_calendarView to $newView');
      setState(() {
        _calendarView = newView;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Appointments',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFA78AAB),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatientAppointments,
            tooltip: 'Refresh appointments',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFA78AAB),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Calendar View',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select how to view your appointments',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.view_day),
              title: const Text('Day'),
              selected: _calendarView == CalendarView.day,
              selectedTileColor: const Color(0xFFE2D1F4),
              onTap: () {
                _onCalendarViewChanged(CalendarView.day);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_week),
              title: const Text('Week'),
              selected: _calendarView == CalendarView.week,
              selectedTileColor: const Color(0xFFE2D1F4),
              onTap: () {
                _onCalendarViewChanged(CalendarView.week);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.view_agenda),
              title: const Text('Month Agenda View'),
              selected: _calendarView == CalendarView.month,
              selectedTileColor: const Color(0xFFE2D1F4),
              onTap: () {
                _onCalendarViewChanged(CalendarView.month);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                _showHelpDialog();
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFA78AAB)))
          : _errorMessage.isNotEmpty && calendarDataSource.appointments!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No appointments found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You don\'t have any scheduled appointments',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadPatientAppointments,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA78AAB),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SfCalendar(
                    key: ValueKey(_calendarView),
                    view: _calendarView,
                    dataSource: calendarDataSource,
                    initialDisplayDate: DateTime.now(),
                    monthViewSettings: const MonthViewSettings(showAgenda: true),
                    onTap: _calendarTapped,
                    headerStyle: const CalendarHeaderStyle(
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA78AAB),
                      ),
                    ),
                    todayHighlightColor: const Color(0xFFA78AAB),
                    selectionDecoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: const Color(0xFFA78AAB), width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2, // Índice para la pantalla de citas
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreenPatient()),
              );
              break;
            case 1:
              // Implementar navegación a pantalla de búsqueda de doctores
              break;
            case 2:
              // Ya estamos en esta pantalla
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

  void _calendarTapped(CalendarTapDetails details) async {
    if (details.targetElement == CalendarElement.calendarCell) {
      // Los pacientes no pueden crear citas directamente
      // Podrías mostrar un mensaje o redirigir a una pantalla de solicitud de cita
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please contact your doctor to schedule a new appointment'),
          backgroundColor: Color(0xFFA78AAB),
        ),
      );
    } else if (details.targetElement == CalendarElement.appointment) {
      final appointment = details.appointments!.first;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentDetail(
            appointmentId: int.parse(appointment.id) // Pasar un flag para indicar que es vista de paciente
          ),
        ),
      );

      if (result == true) {
        _loadPatientAppointments();
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to use the calendar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('• View your scheduled appointments in the calendar'),
            SizedBox(height: 8),
            Text('• Tap on an appointment to see details'),
            SizedBox(height: 8),
            Text('• Change the calendar view using the menu'),
            SizedBox(height: 8),
            Text('• Contact your doctor to schedule new appointments'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  void updateMeetings(List<Meeting> newMeetings) {
    // Notifica la eliminación de las citas anteriores
    notifyListeners(CalendarDataSourceAction.remove, appointments!);

    // Actualiza las citas
    appointments!.clear();
    appointments!.addAll(newMeetings);

    // Notifica la adición de las nuevas citas
    notifyListeners(CalendarDataSourceAction.add, appointments!);
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String getNotes(int index) {
    return appointments![index].description;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay, this.description, this.id);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String description;
  String id;
}