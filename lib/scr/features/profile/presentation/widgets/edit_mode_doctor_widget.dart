import 'package:flutter/material.dart';

class EditModeDoctorWidget extends StatefulWidget {
  final Map<String, dynamic> doctorProfile;
  final Function onCancel;
  final Function(Map<String, dynamic>) onSave;

  const EditModeDoctorWidget({Key? key, required this.doctorProfile, required this.onCancel, required this.onSave}) : super(key: key);

  @override
  _EditModeDoctorWidgetState createState() => _EditModeDoctorWidgetState();
}

class _EditModeDoctorWidgetState extends State<EditModeDoctorWidget> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController genderController;
  late TextEditingController birthdayController;
  late TextEditingController phoneNumberController;
  late TextEditingController professionalIdentificationNumberController;
  late TextEditingController subSpecialtyController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.doctorProfile['firstName'] ?? '');
    lastNameController = TextEditingController(text: widget.doctorProfile['lastName'] ?? '');
    genderController = TextEditingController(text: widget.doctorProfile['gender'] ?? '');
    birthdayController = TextEditingController(text: widget.doctorProfile['birthday'] ?? '');
    phoneNumberController = TextEditingController(text: widget.doctorProfile['phoneNumber'] ?? '');
    professionalIdentificationNumberController = TextEditingController(text: widget.doctorProfile['professionalIdentificationNumber']?.toString() ?? '');
    subSpecialtyController = TextEditingController(text: widget.doctorProfile['subSpecialty'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildEditableField("First name", firstNameController),
        _buildEditableField("Last name", lastNameController),
        _buildEditableField("Gender", genderController),
        _buildEditableField("Birthday", birthdayController),
        _buildEditableField("Phone number", phoneNumberController),
        _buildEditableField("Professional ID Number", professionalIdentificationNumberController),
        _buildEditableField("SubSpecialty", subSpecialtyController),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                widget.onCancel();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedDoctorProfile = {
                  "firstName": firstNameController.text,
                  "lastName": lastNameController.text,
                  "gender": genderController.text,
                  "phoneNumber": phoneNumberController.text,
                  "birthday": birthdayController.text,
                  "professionalIdentificationNumber": int.tryParse(professionalIdentificationNumberController.text) ?? 0,
                  "subSpecialty": subSpecialtyController.text,
                };
                widget.onSave(updatedDoctorProfile);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        controller: controller,
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    birthdayController.dispose();
    phoneNumberController.dispose();
    professionalIdentificationNumberController.dispose();
    subSpecialtyController.dispose();
    super.dispose();
  }
}