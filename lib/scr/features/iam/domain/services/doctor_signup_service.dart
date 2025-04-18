import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';

class DoctorSignUpService {
  static final String baseUrl = 'http://localhost:8080/api/v1';

  static Future<void> signUpDoctor(
    String username,
    String password,
    String firstName,
    String lastName,
    String gender,
    String phoneNumber,
    String image,
    String birthday,
    int professionalIdentificationNumber,
    String subSpecialty,
  ) async {
    final authService = AuthService();

    // Sign up user
    final userResponse = await authService.signUp(username, password, 'ROLE_DOCTOR');
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

    // Create doctor profile
    final doctorResponse = await http.post(
      Uri.parse('$baseUrl/doctor/doctor'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'phoneNumber': phoneNumber,
        'image': image,
        'birthday': birthday,
        'userId': userId,
        'professionalIdentificationNumber': professionalIdentificationNumber,
        'subSpecialty': subSpecialty,
      }),
    );

    if (doctorResponse.statusCode != 201) {
      throw Exception('Error creating doctor profile');
    }
  }
}