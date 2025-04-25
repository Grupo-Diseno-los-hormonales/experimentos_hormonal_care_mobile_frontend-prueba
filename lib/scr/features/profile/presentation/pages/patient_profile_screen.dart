import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/auth_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_field_widget.dart';
import '../widgets/logout_button_widget.dart';
import '../widgets/edit_mode_widget.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';

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
        backgroundColor: const Color(0xFF8F7193), // Fondo morado oscuro
        title: const Text(
          'Patient Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFFA788AB)), // Icono morado intermedio
                  onPressed: toggleEditMode,
                ),
                const SizedBox(width: 8.0),
                FutureBuilder<Map<String, dynamic>>(
                  future: _profileDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Color(0xFF8F7193), // Indicador morado oscuro
                      );
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error, color: Color(0xFF8F7193)); // Icono morado oscuro
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Icon(Icons.person, color: Color(0xFF8F7193)); // Icono morado oscuro
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
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFFA788AB)), // Icono morado intermedio
                  onPressed: _logout,
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            if (!isEditing) ...[
              FutureBuilder<Map<String, dynamic>>(
                future: _profileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8F7193), // Indicador morado oscuro
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Color(0xFF8F7193)), // Texto morado oscuro
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No data found',
                        style: TextStyle(color: Color(0xFF8F7193)), // Texto morado oscuro
                      ),
                    );
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
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8F7193), // Indicador morado oscuro
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Color(0xFF8F7193)), // Texto morado oscuro
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No data found',
                        style: TextStyle(color: Color(0xFF8F7193)), // Texto morado oscuro
                      ),
                    );
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