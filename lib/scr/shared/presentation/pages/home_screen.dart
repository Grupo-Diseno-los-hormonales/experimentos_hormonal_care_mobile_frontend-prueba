import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/patients_list_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/medical_prescription/presentation/pages/patients_list_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/medical_prescription/presentation/pages/medical_prescription_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/appointment_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/notifications/presentation/pages/notification_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/presentation/pages/doctor_profile_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/presentation/pages/patient_profile_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/notice_manager.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';

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

      // Carga las pantallas funcionales en lugar de textos estáticos
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
      body: Column(
        children: [
          if (NoticeManager.currentNotice != null)
            Container(
              color: const Color(0xFFFFF3CD), // Fondo amarillo claro
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      NoticeManager.currentNotice!,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        NoticeManager.clearNotice(); // Limpia el aviso
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: _widgetOptions.isNotEmpty
                ? _widgetOptions[_selectedIndex]
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
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
        selectedItemColor: const Color(0xFFA788AB),
        unselectedItemColor: const Color(0xFF8F7193),
        onTap: _onItemTapped,
      ),
    );
  }
}