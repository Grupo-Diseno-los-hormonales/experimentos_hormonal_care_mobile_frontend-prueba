import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/patient_signup_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

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
        final role = await JwtStorage.getRole();
        if (role == 'ROLE_PATIENT') {
          await PatientSignUpService.signUpPatient(
            _usernameController.text,
            _passwordController.text,
            _firstNameController.text,
            _lastNameController.text,
            _genderController.text,
            _phoneNumberController.text,
            _image,
            _birthdayController.text,
            _typeOfBloodController.text,
            _doctorIdController.text,
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
      appBar: AppBar(
        title: Text("Patient's Sign Up"),
        backgroundColor: Color(0xFF6A828D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                      child: _image.isEmpty ? Icon(Icons.camera_alt, size: 50) : null,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildTextField(_firstNameController, 'First Name'),
                  _buildTextField(_lastNameController, 'Last Name'),
                  _buildDropdownField(_genderController, 'Gender', ['Male', 'Female']),
                  _buildTextField(_birthdayController, 'Birthday'),
                  _buildTextField(_phoneNumberController, 'Phone Number'),
                  _buildTextField(_usernameController, 'Username'),
                  _buildTextField(_passwordController, 'Password', obscureText: true),
                  _buildDropdownField(_typeOfBloodController, 'Type of Blood', ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-']),
                  _buildTextField(_doctorIdController, 'Doctor\'s ID'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text('Sign Up'),
                  ),
                ],
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
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

  Widget _buildDropdownField(TextEditingController controller, String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
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
}