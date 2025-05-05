import 'package:flutter/material.dart';

class AppointmentScreenPatient extends StatelessWidget {
  const AppointmentScreenPatient({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Processing Appointment"),
        backgroundColor: const Color(0xFFC0A0C3),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF8F7193),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your appointment is being processed...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Please wait a moment.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}