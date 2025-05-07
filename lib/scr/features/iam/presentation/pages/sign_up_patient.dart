import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/auth_service.dart';
import 'package:http/http.dart' as http;

class SignUpPatient extends StatefulWidget {
  @override
  _SignUpPatientState createState() => _SignUpPatientState();
}

class _SignUpPatientState extends State<SignUpPatient> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _typeOfBloodController = TextEditingController();
  final TextEditingController _doctorIdController = TextEditingController();
  String _image = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authService = AuthService();

        // Paso 1: Registrar al usuario con ROLE_PATIENT
        final userResponse = await authService.signUp(
          _usernameController.text,
          _passwordController.text,
          'ROLE_PATIENT',
        );
        final userId = userResponse['id'];

        if (userId == null) {
          throw Exception('Error: User ID not returned after sign-up');
        }

        // Paso 2: Realizar login para obtener el token
        final loginResponse = await http.post(
          Uri.parse('http://localhost:8080/api/v1/authentication/sign-in'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'username': _usernameController.text,
            'password': _passwordController.text,
          }),
        );

        if (loginResponse.statusCode != 200) {
          throw Exception('Error during login: ${loginResponse.body}');
        }

        final loginData = json.decode(loginResponse.body);
        final token = loginData['token'];

        if (token == null) {
          throw Exception('Error: Token not returned after login');
        }

        // Paso 3: Crear el perfil del paciente
        final patientResponse = await http.post(
          Uri.parse('http://localhost:8080/api/v1/patient/patient'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Usa el token del usuario
          },
          body: json.encode({
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'gender': _genderController.text,
            'phoneNumber': _phoneNumberController.text,
            'image': _image.isNotEmpty
                ? _image
                : 'https://cdn.pixabay.com/photo/2018/11/08/23/52/man-3803551_1280.jpg', // Imagen por defecto
            'birthday': '${_birthdayController.text}T00:00:00.000Z',
            'userId': userId,
            'typeOfBlood': _typeOfBloodController.text,
            'personalHistory': '',
            'familyHistory': '',
            'doctorId': int.parse(_doctorIdController.text),
          }),
        );

        if (patientResponse.statusCode != 201) {
          throw Exception('Error creating patient profile: ${patientResponse.body}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient registered successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDE6), // Fondo de la pantalla
      appBar: AppBar(
        backgroundColor: const Color(0xFFC0A0C3), // Fondo morado del AppBar
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFC0A0C3), // Fondo morado claro del formulario
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
                    _firstNameController,
                    'Enter your name',
                    validator: (value) => _validateOnlyLetters(value, 'Name'),
                  ),
                  _buildTextField(
                    _lastNameController,
                    'Enter your last name',
                    validator: (value) => _validateOnlyLetters(value, 'Last Name'),
                  ),
                  _buildDropdownField(
                    _genderController,
                    'Gender',
                    ['Male', 'Female'],
                  ),
                  _buildTextField(
                    _birthdayController,
                    'Enter your birthday (YYYY-MM-DD)',
                    validator: _validateDate,
                  ),
                  _buildTextField(
                    _phoneNumberController,
                    'Enter your phone number (XXX-XXX-XXXX)',
                    validator: _validatePhoneNumber,
                  ),
                  _buildTextField(
                    _usernameController,
                    'Enter your email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
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
                  _buildDropdownField(
                    _typeOfBloodController,
                    'Type of Blood',
                    ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'],
                  ),
                  _buildTextField(
                    _doctorIdController,
                    'Enter your doctor\'s ID',
                    keyboardType: TextInputType.number,
                    validator: (value) => _validateNumber(value, 'Doctor ID'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8F7193), // Fondo morado del botón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.black, // Texto negro
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
      ),
    );
  }

  Widget _buildDropdownField(
    TextEditingController controller,
    String label,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFE5DDE6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        value: controller.text.isNotEmpty ? controller.text : null,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            controller.text = newValue!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select $label';
          }
          return null;
        },
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

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter your $fieldName';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName must be a number';
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