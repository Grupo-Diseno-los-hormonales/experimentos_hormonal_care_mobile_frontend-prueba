import 'package:flutter/material.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_field_widget.dart';
import '../widgets/logout_button_widget.dart';
import '../widgets/edit_mode_widget.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/presentation/pages/sign_in.dart';

class PatientProfileScreen extends StatefulWidget {
  @override
  _PatientProfileScreenState createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool isEditing = false;
  Future<Map<String, dynamic>>? _profileDetails;
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadProfileDetails();
  }

  Future<void> _loadProfileDetails() async {
    final userId = await JwtStorage.getUserId();

    if (userId != null) {
      setState(() {
        _profileDetails = _profileService.fetchProfileDetails(userId);
      });
    } else {
      // Maneja el caso en que no se encuentra el user ID
      print('User ID not found');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF6A828D),
        title: Text('Patient Profile'),
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
                  future: _profileDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error);
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Icon(Icons.person);
                    } else {
                      final profile = snapshot.data!;
                      final imageUrl = profile['image'] as String?;
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
                  onPressed: _logout,
                ),
              ],
            ),

            SizedBox(height: 20.0),

            // Display fields or editable fields based on edit mode
            if (!isEditing) ...[
              FutureBuilder<Map<String, dynamic>>(
                future: _profileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    final profile = snapshot.data!;
                    final fullName = profile['fullName'] ?? '';
                    final nameParts = fullName.split(' ');
                    final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
                    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

                    return Column(
                      children: [
                        ProfileFieldWidget(label: "First Name", value: firstName),
                        ProfileFieldWidget(label: "Last Name", value: lastName),
                        ProfileFieldWidget(label: "Gender", value: profile['gender'] ?? ''),
                        ProfileFieldWidget(label: "Phone Number", value: profile['phoneNumber'] ?? ''),
                        ProfileFieldWidget(label: "Birthday", value: profile['birthday'] ?? ''),
                        // Add more fields as needed
                      ],
                    );
                  }
                },
              ),
            ] else ...[
              FutureBuilder<Map<String, dynamic>>(
                future: _profileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    return EditModeWidget(
                      profile: snapshot.data!,
                      onCancel: toggleEditMode,
                      onSave: (updatedProfile) {
                        _profileService.updateProfile(updatedProfile['id'], updatedProfile);
                        _loadProfileDetails();
                        toggleEditMode();
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
  }
}