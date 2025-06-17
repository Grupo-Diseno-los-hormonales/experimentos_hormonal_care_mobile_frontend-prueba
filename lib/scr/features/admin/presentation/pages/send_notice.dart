import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/notice_manager.dart';

class SendNoticeScreen extends StatefulWidget {
  @override
  _SendNoticeScreenState createState() => _SendNoticeScreenState();
}

class _SendNoticeScreenState extends State<SendNoticeScreen> {
  String _selectedAudience = 'Todos';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendNotice() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa título y mensaje.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simula un envío (puedes poner await a tu API aquí)
    await Future.delayed(const Duration(seconds: 1));

    NoticeManager.setNotice({'title': title, 'body': body, 'audience': _selectedAudience});

    setState(() => _isLoading = false);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFE5DDE6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Aviso enviado', style: TextStyle(color: Color(0xFF8F7193), fontWeight: FontWeight.bold)),
        content: const Text('El aviso fue enviado exitosamente.', style: TextStyle(color: Color(0xFF4B006E))),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _titleController.clear();
              _bodyController.clear();
              setState(() {});
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFF8F7193))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Enviar Avisos', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF8F7193),
            centerTitle: true,
          ),
          body: Container(
            color: const Color(0xFFE5DDE6),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selecciona el destinatario:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8F7193))),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedAudience,
                        items: const [
                          DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                          DropdownMenuItem(value: 'Pacientes', child: Text('Pacientes')),
                          DropdownMenuItem(value: 'Doctores', child: Text('Doctores')),
                        ],
                        onChanged: (value) => setState(() => _selectedAudience = value!),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFA78AAB)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Título del aviso:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8F7193))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Título del aviso',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFA78AAB)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Cuerpo del mensaje:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF8F7193))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _bodyController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Escribe tu mensaje aquí...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFA78AAB)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendNotice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8F7193),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Enviar', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.2),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8F7193)),
              ),
            ),
          ),
      ],
    );
  }
}