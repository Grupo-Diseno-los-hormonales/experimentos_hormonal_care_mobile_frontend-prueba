import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/pages/support_chat_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/widgets/admin_chat_section.dart';
import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/profile/data/data_sources/remote/profile_service.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/auth_service.dart';
import '../widgets/profile_picture_widget.dart';
import '../widgets/profile_field_widget.dart';
import '../widgets/edit_mode_doctor_widget.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/presentation/pages/sign_in.dart';

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
  String? _role;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfileDetails();
    _loadRole();
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
      print('Profile ID not found');
    }
  }

  Future<void> _loadRole() async {
    final role = await _authService.getRole();
    setState(() {
      _role = role;
      _loadingRole = false;
    });
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
          title: const Text(
            'Confirm Logout',
            style: TextStyle(color: Color(0xFF8F7193)),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Color(0xFFA788AB)),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8F7193)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Yes',
                style: TextStyle(color: Color(0xFF8F7193)),
              ),
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

void _openSupportChat() {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const SupportChatScreen(),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8F7193),
        title: const Text(
          'Doctor Profile',
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
                  icon: const Icon(Icons.edit, color: Color(0xFFA788AB)),
                  onPressed: toggleEditMode,
                ),
                const SizedBox(width: 8.0),
                FutureBuilder<Map<String, dynamic>>(
                  future: _doctorProfileDetails,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Color(0xFF8F7193),
                      );
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error, color: Color(0xFF8F7193));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Icon(Icons.person, color: Color(0xFF8F7193));
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
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFFA788AB)),
                  onPressed: _showLogoutDialog,
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // Botón de soporte solo si NO es admin
            if (!_loadingRole && _role != 'ROLE_ADMIN')
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F7193),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.support_agent, color: Colors.white),
                  label: const Text(
                    'Support Chat',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: _openSupportChat,
                ),
              ),
            if (!isEditing) ...[
              FutureBuilder<Map<String, dynamic>>(
                future: _doctorProfileDetails,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8F7193),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error loading profile',
                        style: TextStyle(color: Color(0xFF8F7193)),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No data found',
                        style: TextStyle(color: Color(0xFF8F7193)),
                      ),
                    );
                  } else {
                    final doctorProfile = snapshot.data!;
                    return Column(
                      children: [
                        Card(
                          color: const Color(0xFFDFCAE1),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ProfileFieldWidget(label: "First Name", value: doctorProfile['fullName'] ?? ''),
                                ProfileFieldWidget(label: "Last Name", value: doctorProfile['lastName'] ?? ''),
                                ProfileFieldWidget(label: "Gender", value: doctorProfile['gender'] ?? ''),
                                ProfileFieldWidget(label: "Phone Number", value: doctorProfile['phoneNumber'] ?? ''),
                                ProfileFieldWidget(label: "Birthday", value: doctorProfile['birthday'] ?? ''),
                                ProfileFieldWidget(label: "Professional ID Number", value: doctorProfile['professionalIdentificationNumber']?.toString() ?? ''),
                                ProfileFieldWidget(label: "SubSpecialty", value: doctorProfile['subSpecialty'] ?? ''),
                              ],
                            ),
                          ),
                        ),
                      ],
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