import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';

class DoctorService {
  final String baseUrl = 'http://localhost:8080/api/v1/doctor/{doctorId}';

  Future<Map<String, dynamic>> fetchDoctorDetails(int doctorId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$doctorId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load patient details');
    }
  }

  static DoctorService fromJson(Map<String, dynamic> json) {
    return DoctorService();
  }
}