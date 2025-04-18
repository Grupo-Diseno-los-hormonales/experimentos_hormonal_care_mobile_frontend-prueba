import 'package:flutter/material.dart';

class EditModeWidget extends StatefulWidget {
  final Map<String, dynamic> profile;
  final Function onCancel;
  final Function(Map<String, dynamic>) onSave;

  const EditModeWidget({Key? key, required this.profile, required this.onCancel, required this.onSave}) : super(key: key);

  @override
  _EditModeWidgetState createState() => _EditModeWidgetState();
}

class _EditModeWidgetState extends State<EditModeWidget> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController genderController;
  late TextEditingController birthdayController;
  late TextEditingController phoneNumberController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.profile['firstName'] ?? '');
    lastNameController = TextEditingController(text: widget.profile['lastName'] ?? '');
    genderController = TextEditingController(text: widget.profile['gender'] ?? '');
    birthdayController = TextEditingController(text: widget.profile['birthday'] ?? '');
    phoneNumberController = TextEditingController(text: widget.profile['phoneNumber'] ?? '');
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
                final updatedProfile = {
                  "firstName": firstNameController.text,
                  "lastName": lastNameController.text,
                  "gender": genderController.text,
                  "phoneNumber": phoneNumberController.text,
                  "birthday": birthdayController.text,
                };
                widget.onSave(updatedProfile);
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
    super.dispose();
  }
}