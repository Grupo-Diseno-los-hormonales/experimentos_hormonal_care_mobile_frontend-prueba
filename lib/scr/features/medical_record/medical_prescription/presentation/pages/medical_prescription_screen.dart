import 'package:flutter/material.dart';

class MedicalRecordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFA788AB),
        title: Text('Historial Médico'),
      ),
      body: Center(
        child: Text('Pantalla de Historial Médico'),
      ),
    );
  }
}
