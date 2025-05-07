import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/iam/domain/services/auth_service.dart';

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

    try {
      // Paso 1: Registrar al usuario con ROLE_PATIENT
      final userResponse = await authService.signUp(username, password, 'ROLE_PATIENT');
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

      // Paso 3: Crear el perfil del paciente
      final patientResponse = await http.post(
        Uri.parse('$baseUrl/medical-record/patient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Usa el token del usuario
        },
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'gender': gender,
          'phoneNumber': phoneNumber,
          'image': image.isNotEmpty
              ? image
              : 'https://cdn.pixabay.com/photo/2018/11/08/23/52/man-3803551_1280.jpg', // Imagen por defecto
          'birthday': birthday,
          'userId': userId,
          'typeOfBlood': typeOfBlood,
          'personalHistory': '',
          'familyHistory': '',
          'doctorId': int.parse(doctorId),
        }),
      );

      if (patientResponse.statusCode != 201) {
        throw Exception('Error creating patient profile: ${patientResponse.body}');
      }
    } catch (e) {
      throw Exception('Error during patient sign-up: $e');
    }
  }
}