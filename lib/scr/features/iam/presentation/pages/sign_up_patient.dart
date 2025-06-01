import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/patient_signup_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/puzzle_captcha_dialog.dart';
import 'package:flutter/gestures.dart';

class SignUpPatient extends StatefulWidget {
  @override
  _SignUpPatientState createState() => _SignUpPatientState();
}

class _SignUpPatientState extends State<SignUpPatient> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _typeOfBloodController = TextEditingController();
  final TextEditingController _doctorIdController = TextEditingController();
  String _image = '';
  String? _gender; // No se inicializa con un valor predeterminado
  bool _captchaVerified = false;
  bool _termsAccepted = false;


   void _showTermsDialog() async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxHeight: 500, maxWidth: 400),
          child: Column(
            children: [
              const Text(
                'Términos y Condiciones',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF8F7193),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '''
HormonalCare 2025 5.2.4 Acuerdo de Servicio - SaaS

El presente Acuerdo de Servicio (el "Acuerdo") establece los términos y condiciones bajo los cuales los usuarios podrán acceder y utilizar la plataforma HormonalCare como parte del servicio SaaS (Software as a Service) proporcionado por Los Hormonales. Este Acuerdo es aplicable a todos los usuarios que utilicen el servicio, ya sea de manera gratuita o mediante suscripción.

1. Definiciones
"Plataforma": Se refiere al servicio en línea proporcionado por Los Hormonales para la gestión de enfermedades hormonales, disponible a través de la web y la aplicación móvil HormonalCare.
"Usuario": Cualquier persona que acceda a la plataforma HormonalCare para utilizar los servicios ofrecidos.
"Servicios": Los servicios proporcionados por la plataforma HormonalCare, incluyendo acceso a consultas médicas, seguimiento de tratamientos, gestión de citas médicas, entre otros.

2. Derechos y Obligaciones del Usuario
El usuario tiene el derecho de utilizar la plataforma HormonalCare de acuerdo con las funcionalidades proporcionadas.
El usuario es responsable de proporcionar información precisa y actualizada al registrarse y utilizar el servicio.
El usuario se compromete a utilizar la plataforma únicamente para fines legales y en conformidad con los términos del presente Acuerdo.
El usuario deberá cumplir con las políticas de privacidad y seguridad aplicables, protegiendo su cuenta de acceso.

3. Licencia de Uso
Los Hormonales concede al usuario una licencia no exclusiva, intransferible y limitada para acceder y utilizar la plataforma HormonalCare durante el período de validez del servicio contratado.

4. Obligaciones de Los Hormonales
Los Hormonales se comprometen a garantizar la disponibilidad y accesibilidad del servicio, sujeto a mantenimiento programado y circunstancias fuera de su control.
Los Hormonales garantizan que los datos del usuario serán tratados conforme a su Política de Privacidad y las normativas aplicables en materia de protección de datos.

5. Limitaciones de Responsabilidad
Los Hormonales no serán responsables por daños directos, indirectos, incidentales, especiales o consecuentes derivados del uso o la imposibilidad de uso de la plataforma HormonalCare, incluyendo, pero no limitado a, la pérdida de datos o interrupciones en el servicio.

6. Suspensión o Terminación de Servicios
Los Hormonales se reservan el derecho de suspender o terminar el acceso de un usuario a la plataforma HormonalCare en caso de violaciones de este Acuerdo, incluyendo el uso inapropiado de la plataforma, o el incumplimiento de las políticas establecidas.
El usuario puede cancelar su cuenta en cualquier momento, sujeto a los términos de cancelación aplicables.

7. Confidencialidad
Ambas partes se comprometen a mantener la confidencialidad de cualquier información confidencial intercambiada durante la duración del Acuerdo, y a no divulgar dicha información sin el consentimiento expreso de la otra parte, excepto cuando lo exija la ley.

8. Modificaciones del Acuerdo
Los Hormonales se reservan el derecho de modificar este Acuerdo en cualquier momento. Las modificaciones se publicarán en la sección de "Términos y Condiciones" de la plataforma HormonalCare, y el usuario será notificado de las actualizaciones.

9. Cumplimiento Normativo
El uso de la plataforma HormonalCare debe cumplir con todas las leyes y regulaciones aplicables, incluidas aquellas relacionadas con la protección de datos personales, propiedad intelectual y otros derechos de propiedad.

10. Resolución de Conflictos
En caso de controversias derivadas del uso de la plataforma HormonalCare, ambas partes acuerdan resolver los conflictos mediante un proceso de mediación antes de recurrir a procedimientos legales.

11. Vigencia
Este Acuerdo entrará en vigencia desde el momento en que el usuario acceda por primera vez a la plataforma HormonalCare y continuará en vigor hasta que sea terminado por cualquiera de las partes, conforme a las disposiciones del Acuerdo.
                    ''',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8F7193),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Aceptar términos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: Color(0xFF8F7193),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (accepted == true) {
      setState(() {
        _termsAccepted = true;
      });
    }
  }
  
 Future<void> _verifyCaptcha() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PuzzleCaptchaDialog(),
    );
    if (result == true) {
      setState(() {
        _captchaVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.verified, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  '¡CAPTCHA verificado!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      setState(() {
        _captchaVerified = false;
      });
    }
  }

 void _submit() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes aceptar los Términos y Condiciones')),
      );
      return;
    }
    if (_formKey.currentState!.validate() && _captchaVerified) {
      try {
        final doctorId = int.parse(_doctorIdController.text);
        if (doctorId < 1 || doctorId > 100) {
          throw Exception('Doctor ID must be between 1 and 100');
        }

        final imageUrl = _image.isNotEmpty
            ? _image
            : 'https://cdn.pixabay.com/photo/2018/11/08/23/52/man-3803551_1280.jpg';

        await PatientSignUpService.signUpPatient(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          _gender!,
          _phoneNumberController.text.trim(),
          imageUrl,
          _birthdayController.text.trim(),
          _typeOfBloodController.text.trim(),
          doctorId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient registered successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else if (!_captchaVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify the CAPTCHA')),
      );
    }
  }



 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFC0A0C3),
        title: const Text("Patient's Sign Up"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFC0A0C3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Implement image picker here
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _image.isNotEmpty ? NetworkImage(_image) : null,
                      child: _image.isEmpty ? const Icon(Icons.camera_alt, size: 50) : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    _usernameController,
                    'Enter your username',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    _passwordController,
                    'Enter your password',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    _firstNameController,
                    'Enter your first name',
                    validator: (value) => _validateOnlyLetters(value, 'First Name'),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  ),
                  _buildTextField(
                    _lastNameController,
                    'Enter your last name',
                    validator: (value) => _validateOnlyLetters(value, 'Last Name'),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  ),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: InputDecoration(
                      labelText: 'Select your gender',
                      filled: true,
                      fillColor: const Color(0xFFE5DDE6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['Male', 'Female']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _phoneNumberController,
                    'Enter your phone number (XXX-XXX-XXXX)',
                    validator: _validatePhoneNumber,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _birthdayController,
                    'Enter your birthday (YYYY-MM-DD)',
                    validator: _validateDate,
                  ),
                  const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _typeOfBloodController.text.isNotEmpty ? _typeOfBloodController.text : null,
                  decoration: InputDecoration(
                    labelText: 'Select your blood type',
                    filled: true,
                    fillColor: const Color(0xFFE5DDE6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
                  ].map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _typeOfBloodController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your blood type';
                    }
                    return null;
                  },
                ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _doctorIdController,
                    'Enter your doctor ID',
                    keyboardType: TextInputType.number,
                    validator: _validateDoctorId,
                  ),
                  const SizedBox(height: 20),
                     // Checkbox de términos y condiciones
                  Row(
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        activeColor: const Color(0xFF8F7193),
                        onChanged: (value) {
                          if (!_termsAccepted) {
                            _showTermsDialog();
                          }
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'Acepto los ',
                            style: const TextStyle(color: Colors.black, fontSize: 15),
                            children: [
                              TextSpan(
                                text: 'Términos y Condiciones',
                                style: const TextStyle(
                                  color: Color(0xFF8F7193),
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _showTermsDialog,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _verifyCaptcha,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F7193),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Verify CAPTCHA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F7193),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFE5DDE6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        inputFormatters: inputFormatters,
      ),
    );
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your birthday';
    }
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Invalid date format. Use YYYY-MM-DD';
    }
    try {
      DateTime.parse(value);
    } catch (_) {
      return 'Invalid date';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Invalid phone number format. Use XXX-XXX-XXXX';
    }
    return null;
  }

  String? _validateDoctorId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your doctor ID';
    }
    final doctorId = int.tryParse(value);
    if (doctorId == null || doctorId < 1 || doctorId > 100) {
      return 'Doctor ID must be a number between 1 and 100';
    }
    return null;
  }

  String? _validateOnlyLetters(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    final lettersRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!lettersRegex.hasMatch(value)) {
      return '$fieldName must contain only letters';
    }
    return null;
  }
}