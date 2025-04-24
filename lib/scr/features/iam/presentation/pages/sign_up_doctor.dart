import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/doctor_signup_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class SignUpDoctor extends StatefulWidget {
  @override
  _SignUpDoctorState createState() => _SignUpDoctorState();
}

class _SignUpDoctorState extends State<SignUpDoctor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _medicalLicenseNumberController = TextEditingController();
  final TextEditingController _subSpecialtyController = TextEditingController();
  String _image = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final role = await JwtStorage.getRole();
        if (role == 'ROLE_DOCTOR') {
          await DoctorSignUpService.signUpDoctor(
            _usernameController.text,
            _passwordController.text,
            _firstNameController.text,
            _lastNameController.text,
            _genderController.text,
            _phoneNumberController.text,
            _image,
            _birthdayController.text,
            int.parse(_medicalLicenseNumberController.text),
            _subSpecialtyController.text,
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid role')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
        title: const Text("Doctor's Sign Up"),
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                    // Image upload placeholder
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
                    _buildTextField(_firstNameController, 'Enter your name'),
                    _buildTextField(_lastNameController, 'Enter your last name'),
                    _buildTextField(_birthdayController, 'Enter your age'),
                    _buildTextField(_usernameController, 'Enter your email'),
                    _buildTextField(_passwordController, 'Enter your password', obscureText: true),
                    _buildTextField(_subSpecialtyController, 'Enter your qualifications'),
                    _buildTextField(_medicalLicenseNumberController, 'Enter your School Number'),
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFE5DDE6), // Fondo morado claro del campo de texto
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}