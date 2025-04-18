import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_field_widget.dart';
import '../widgets/logout_button_widget.dart';
import '../widgets/edit_mode_doctor_widget.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/sign_in.dart';

class DoctorProfileScreen extends StatefulWidget {
  @override
  _DoctorProfileScreenState createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool isEditing = false;
  Future<Map<String, dynamic>>? _doctorProfileDetails;
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  int? _doctorId;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfileDetails();
  }

  Future<void> _loadDoctorProfileDetails() async {
  final profileId = await JwtStorage.getProfileId();

  if (profileId != null) {
    final profileDetails = await _profileService.fetchProfileDetails(profileId);
    final doctorProfessionalDetails = await _profileService.fetchDoctorProfessionalDetails(profileId);

    final combinedDetails = {
      ...profileDetails,
      ...doctorProfessionalDetails,
    };

    setState(() {
      _doctorProfileDetails = Future.value(combinedDetails);
      _doctorId = doctorProfessionalDetails['id'];
    });
  } else {
    // Maneja el caso en que no se encuentra el profile ID
    print('Profile ID not found');
  }
}

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignIn()),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDoctorProfileDetails(Map<String, dynamic> updatedDoctorProfile) async {
    if (_doctorId != null) {
      try {
        await _profileService.updateDoctorProfile(_doctorId!, updatedDoctorProfile);
        print('Doctor profile updated successfully');
        toggleEditMode();
        _loadDoctorProfileDetails();
      } catch (e) {
        print('Error updating doctor profile: $e');
      }
    } else {
      print('Doctor ID not found');
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFF6A828D),
      title: Text('Doctor Profile'),
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile picture, edit button, and logout button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: const Color.fromARGB(255, 0, 0, 0)),
                onPressed: toggleEditMode,
              ),
              SizedBox(width: 8.0), // Reduce the space between the edit button and the profile picture
              FutureBuilder<Map<String, dynamic>>(
                future: _doctorProfileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Icon(Icons.error);
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Icon(Icons.person);
                  } else {
                    final doctorProfile = snapshot.data!;
                    final imageUrl = doctorProfile['image'] as String?;
                    return ProfilePictureWidget(
                      isEditing: isEditing,
                      toggleEditMode: toggleEditMode,
                      imageUrl: imageUrl,
                    );
                  }
                },
              ),
              SizedBox(width: 8.0), // Reduce the space between the profile picture and the logout button
              IconButton(
                icon: Icon(Icons.logout, color: const Color.fromARGB(255, 0, 0, 0)),
                onPressed: _showLogoutDialog,
              ),
            ],
          ),

          SizedBox(height: 20.0),

          // Display fields or editable fields based on edit mode
          if (!isEditing) ...[
            FutureBuilder<Map<String, dynamic>>(
              future: _doctorProfileDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data found'));
                } else {
                  final doctorProfile = snapshot.data!;
                  final fullName = doctorProfile['fullName'] ?? '';
                  final nameParts = fullName.split(' ');
                  final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
                  final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                  return Column(
                    children: [
                      ProfileFieldWidget(label: "First Name", value: firstName),
                      ProfileFieldWidget(label: "Last Name", value: lastName),
                      ProfileFieldWidget(label: "Gender", value: doctorProfile['gender'] ?? ''),
                      ProfileFieldWidget(label: "Phone Number", value: doctorProfile['phoneNumber'] ?? ''),
                      ProfileFieldWidget(label: "Birthday", value: doctorProfile['birthday'] ?? ''),
                      ProfileFieldWidget(label: "Professional ID Number", value: doctorProfile['professionalIdentificationNumber']?.toString() ?? ''),
                      ProfileFieldWidget(label: "SubSpecialty", value: doctorProfile['subSpecialty'] ?? ''),
                      // Add more fields as needed
                    ],
                  );
                }
              },
            ),
          ] else ...[
            FutureBuilder<Map<String, dynamic>>(
              future: _doctorProfileDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data found'));
                } else {
                  return EditModeDoctorWidget(
                    doctorProfile: snapshot.data!,
                    onCancel: toggleEditMode,
                    onSave: (updatedDoctorProfile) {
                      _saveDoctorProfileDetails(updatedDoctorProfile);
                    },
                  );
                }
              },
            ),
          ],
        ],
      ),
    ),
  );
}}