import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';

class NotificationService {
  final String baseUrl = 'http://localhost:8080/api/v1';

  Future<List<Map<String, dynamic>>> fetchDoctorAppointments(int doctorId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/medicalAppointment/medicalAppointments/doctor/$doctorId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> appointments = json.decode(response.body);
      return appointments.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load appointments');
    }
  }

  Future<Map<String, dynamic>> fetchPatientProfile(int patientId) async {
    final token = await JwtStorage.getToken();
    final patientResponse = await http.get(
      Uri.parse('$baseUrl/medical-record/patient/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (patientResponse.statusCode == 200) {
      final patientData = json.decode(patientResponse.body);
      final profileId = patientData['profileId'];

      final profileResponse = await http.get(
        Uri.parse('$baseUrl/profile/profile/$profileId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (profileResponse.statusCode == 200) {
        return json.decode(profileResponse.body);
      } else {
        throw Exception('Failed to load patient profile');
      }
    } else {
      throw Exception('Failed to load patient data');
    }
  }

  Future<void> deleteAppointment(int appointmentId) async {
    final token = await JwtStorage.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/medicalAppointment/$appointmentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete appointment');
    }
  }
}