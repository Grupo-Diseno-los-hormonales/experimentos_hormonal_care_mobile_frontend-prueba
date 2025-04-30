import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/doctor_signup_service.dart';

class SignUpDoctor extends StatefulWidget {
  @override
  _SignUpDoctorState createState() => _SignUpDoctorState();
}

class _SignUpDoctorState extends State<SignUpDoctor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _medicalLicenseNumberController = TextEditingController();
  final TextEditingController _subSpecialtyController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _birthdayFocusNode = FocusNode();
  final FocusNode _professionalIdFocusNode = FocusNode();
  String _image = '';
  String? _gender;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final imageUrl = _image.isNotEmpty
            ? _image
            : 'https://hips.hearstapps.com/hmg-prod/images/portrait-of-a-happy-young-doctor-in-his-clinic-royalty-free-image-1661432441.jpg?crop=0.66698xw:1xh;center,top&resize=1200:*';

        await DoctorSignUpService.signUpDoctor(
          _usernameController.text,
          _passwordController.text,
          _firstNameController.text,
          _lastNameController.text,
          _gender!,
          _phoneNumberController.text,
          imageUrl,
          _birthdayController.text,
          int.parse(_medicalLicenseNumberController.text),
          _subSpecialtyController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor registered successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
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

Widget _buildTextField(
  TextEditingController controller,
  String label, {
  bool obscureText = false,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  FocusNode? focusNode,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFE5DDE6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
    ),
  );
}


Widget _buildPhoneNumberField() {
  final TextEditingController _phoneNumberController = TextEditingController();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Phone Number:',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE5DDE6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black, width: 1), // Agregar borde negro
        ),
        child: TextFormField(
          controller: _phoneNumberController,
          decoration: const InputDecoration(
            hintText: 'XXX-XXX-XXXX',
            counterText: '',
            border: InputBorder.none,
          ),
          maxLength: 12, // Incluye los guiones
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _PhoneNumberInputFormatter(), // Formateador personalizado
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            final phoneRegex = RegExp(r'^\d{3}-\d{3}-\d{4}$');
            if (!phoneRegex.hasMatch(value)) {
              return 'Invalid phone number format. Use XXX-XXX-XXXX';
            }
            return null;
          },
        ),
      ),
    ],
  );
}

Widget _buildProfessionalIdField() {
  return _buildTextField(
    _medicalLicenseNumberController,
    'Enter your professional ID',
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter your professional ID';
      }
      if (int.tryParse(value) == null) {
        return 'Professional ID must be a number';
      }
      return null;
    },
  );
}

Widget _buildBirthdayField() {
  final TextEditingController _birthdayController = TextEditingController();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Birthday:',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE5DDE6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black, width: 1), // Agregar borde negro
        ),
        child: TextFormField(
          controller: _birthdayController,
          decoration: const InputDecoration(
            hintText: 'YYYY-MM-DD',
            counterText: '',
            border: InputBorder.none,
          ),
          maxLength: 10, // Incluye los guiones
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _DateInputFormatter(), // Formateador personalizado
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your birthday';
            }
            final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
            if (!dateRegex.hasMatch(value)) {
              return 'Invalid date format. Use YYYY-MM-DD';
            }
            try {
              final date = DateTime.parse(value);
              if (date.year < 1900 || date.year > DateTime.now().year) {
                return 'Enter a valid year (1900-${DateTime.now().year})';
              }
            } catch (_) {
              return 'Invalid date';
            }
            return null;
          },
        ),
      ),
    ],
  );
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFE5DDE6),
    appBar: AppBar(
      backgroundColor: const Color(0xFFC0A0C3),
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
              color: const Color(0xFFC0A0C3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  _buildTextField(
                    _subSpecialtyController,
                    'Enter your sub-specialty',
                    validator: (value) => _validateOnlyLetters(value, 'Sub-Specialty'),
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
                  _buildBirthdayField(),
                  const SizedBox(height: 10),
                  _buildPhoneNumberField(),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  _buildProfessionalIdField(),
                  const SizedBox(height: 20),
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
    ),
  );
}
}

class _PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('-', ''); // Eliminar guiones existentes
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      // Agregar guiones en las posiciones correctas
      if (i == 2 || i == 5) {
        buffer.write('-');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}


class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('-', ''); // Eliminar guiones existentes
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      // Agregar guiones en las posiciones correctas
      if (i == 3 || i == 5) {
        buffer.write('-');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
