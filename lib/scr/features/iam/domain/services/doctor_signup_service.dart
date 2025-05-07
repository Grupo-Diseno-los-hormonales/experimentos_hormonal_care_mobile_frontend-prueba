import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorSignUpService {
  static final String baseUrl = 'http://localhost:8080/swagger-ui/index.html#/api/v1';

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
        try {
      print('Paso 1: Registrando usuario...');
      final signUpResponse = await http.post(
        Uri.parse('$baseUrl/authentication/sign-up'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'roles': ['ROLE_DOCTOR'],
        }),
      );
    
      if (signUpResponse.statusCode != 201) {
        print('Error durante el registro: ${signUpResponse.body}');
        throw Exception('Error during sign-up: ${signUpResponse.body}');
      }
    
      print('Usuario registrado exitosamente.');
    
      final signUpData = json.decode(signUpResponse.body);
      final userId = signUpData['id'];
    
      if (userId == null) {
        throw Exception('Error: User ID not returned after sign-up');
      }
    
      print('Paso 2: Iniciando sesión...');
      final loginResponse = await http.post(
        Uri.parse('$baseUrl/authentication/sign-in'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
    
      if (loginResponse.statusCode != 200) {
        print('Error durante el inicio de sesión: ${loginResponse.body}');
        throw Exception('Error during login: ${loginResponse.body}');
      }
    
      print('Sesión iniciada exitosamente.');
    
      final loginData = json.decode(loginResponse.body);
      final token = loginData['token'];
    
      if (token == null) {
        throw Exception('Error: Token not returned after login');
      }
    
      print('Paso 3: Creando perfil del doctor...');
      final doctorResponse = await http.post(
        Uri.parse('$baseUrl/doctor/doctor'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'firstName': firstName,
          'lastName': lastName,
          'gender': gender,
          'phoneNumber': phoneNumber,
          'image': image.isNotEmpty
              ? image
              : 'https://hips.hearstapps.com/hmg-prod/images/portrait-of-a-happy-young-doctor-in-his-clinic-royalty-free-image-1661432441.jpg?crop=0.66698xw:1xh;center,top&resize=1200:*',
          'birthday': birthday,
          'userId': userId,
          'professionalIdentificationNumber': professionalIdentificationNumber,
          'subSpecialty': subSpecialty,
        }),
      );
    
      if (doctorResponse.statusCode != 201) {
        print('Error creando perfil del doctor: ${doctorResponse.body}');
        throw Exception('Error creating doctor profile: ${doctorResponse.body}');
      }
    
      print('Perfil del doctor creado exitosamente.');
    } catch (e) {
      print('Error durante el proceso de registro: $e');
      throw Exception('Error during doctor sign-up: $e');
    }
  }
}