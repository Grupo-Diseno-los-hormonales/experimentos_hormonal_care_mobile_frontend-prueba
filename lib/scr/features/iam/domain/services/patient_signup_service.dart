import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';

class PatientSignUpService {
  static final String baseUrl = 'http://localhost:8080/api/v1';

  static Future<void> signUpPatient(
    String username,
    String password,
    String firstName,
    String lastName,
    String gender,
    String phoneNumber,
    String image,
    String birthday,
    String typeOfBlood,
    String doctorId,
  ) async {
    final authService = AuthService();

    // Sign up user
    final userResponse = await authService.signUp(username, password, 'ROLE_PATIENT');
    final userId = userResponse['id'];

    // Create profile
    final profileResponse = await http.post(
      Uri.parse('$baseUrl/profile/profile'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'phoneNumber': phoneNumber,
        'image': image,
        'birthday': birthday,
        'userId': userId,
      }),
    );

    if (profileResponse.statusCode != 201) {
      throw Exception('Error creating profile');
    }

    final profileData = json.decode(profileResponse.body);
    final profileId = profileData['id'];

    // Create patient profile
    final patientResponse = await http.post(
      Uri.parse('$baseUrl/medical-record/patient'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'phoneNumber': phoneNumber,
        'image': image,
        'birthday': birthday,
        'userId': userId,
        'typeOfBlood': typeOfBlood,
        'personalHistory': '',
        'familyHistory': '',
        'doctorId': int.parse(doctorId),
      }),
    );

    if (patientResponse.statusCode != 201) {
      throw Exception('Error creating patient profile');
    }
  }
}