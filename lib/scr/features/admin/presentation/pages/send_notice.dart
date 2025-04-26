import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/notice_manager.dart';

class SendNoticeScreen extends StatefulWidget {
  @override
  _SendNoticeScreenState createState() => _SendNoticeScreenState();
}

class _SendNoticeScreenState extends State<SendNoticeScreen> {
  String _selectedAudience = 'Todos'; // Por defecto, enviar a todos
  final TextEditingController _noticeController = TextEditingController();

  void _sendNotice() {
    final noticeText = _noticeController.text.trim();
    if (noticeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un mensaje.')),
      );
      return;
    }

    // Guarda el aviso en NoticeManager
    NoticeManager.setNotice(noticeText);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aviso enviado exitosamente.')),
    );

    // Limpia el campo de texto
    _noticeController.clear();
    Navigator.pop(context); // Regresa a la pantalla anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enviar Avisos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8F7193), // Morado oscuro
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFE5DDE6), // Fondo morado claro
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona el destinatario:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8F7193), // Morado oscuro
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedAudience,
                        items: const [
                          DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                          DropdownMenuItem(value: 'Pacientes', child: Text('Pacientes')),
                          DropdownMenuItem(value: 'Doctores', child: Text('Doctores')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAudience = value!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFA78AAB)), // Morado intermedio
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Escribe el mensaje:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8F7193), // Morado oscuro
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _noticeController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Escribe tu mensaje aquí...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFA78AAB)), // Morado intermedio
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _sendNotice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8F7193), // Morado oscuro
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Enviar',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}