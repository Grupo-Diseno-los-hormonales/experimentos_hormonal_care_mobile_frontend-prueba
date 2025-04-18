import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/pages/patients_list_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/presentation/pages/patients_list_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/medical_record/medical_prescription/presentation/pages/medical_prescription_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/appointment/presentation/pages/appointment_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/notifications/presentation/pages/notification_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/presentation/pages/doctor_profile_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/presentation/pages/patient_profile_screen.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? role;
  int? doctorId;

  List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
    _loadRoleAndDoctorId();
  }

  Future<void> _loadRoleAndDoctorId() async {
    final storedRole = await JwtStorage.getRole();
    final storedDoctorId = await JwtStorage.getDoctorId();

    setState(() {
      role = storedRole;
      doctorId = storedDoctorId;

      _widgetOptions = [
        HomePatientsScreen(doctorId: doctorId ?? 0),
        PatientsListScreen(),
        AppointmentScreen(),
        NotificationScreen(doctorId: doctorId ?? 0),
        role == 'ROLE_DOCTOR' ? DoctorProfileScreen() : PatientProfileScreen(),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.isNotEmpty
          ? _widgetOptions[_selectedIndex]
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6A828D),
        unselectedItemColor: const Color(0xFF40535B),
        onTap: _onItemTapped,

      ),
    );
  }
}