import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/patient_signup_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/shared/presentation/widgets/puzzle_captcha_dialog.dart';

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
                  _buildTextField(
                    _typeOfBloodController,
                    'Enter your blood type',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your blood type';
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