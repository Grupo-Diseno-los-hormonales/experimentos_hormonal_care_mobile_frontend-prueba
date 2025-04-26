import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/auth_service.dart';

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

    try {
      // Paso 1: Registrar al usuario con ROLE_DOCTOR
      final userResponse = await authService.signUp(username, password, 'ROLE_DOCTOR');
      final userId = userResponse['id'];

      if (userId == null) {
        throw Exception('Error: User ID not returned after sign-up');
      }

      // Paso 2: Realizar login para obtener el token
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/authentication/sign-in'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      if (loginResponse.statusCode != 200) {
        throw Exception('Error during login: ${loginResponse.body}');
      }

      final loginData = json.decode(loginResponse.body);
      final token = loginData['token'];

      if (token == null) {
        throw Exception('Error: Token not returned after login');
      }

      // Paso 3: Crear el perfil del doctor
      final doctorResponse = await http.post(
        Uri.parse('$baseUrl/doctor/doctor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Usa el token del usuario
        },
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
        throw Exception('Error creating doctor profile: ${doctorResponse.body}');
      }
    } catch (e) {
      throw Exception('Error during doctor sign-up: $e');
    }
  }
}