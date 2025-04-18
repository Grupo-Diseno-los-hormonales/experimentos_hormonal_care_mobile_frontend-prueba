import 'package:flutter/material.dart';

class MedicalRecordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Historial Médico'),
      ),
      body: Center(
        child: Text('Pantalla de Historial Médico'),
      ),
    );
  }
}
