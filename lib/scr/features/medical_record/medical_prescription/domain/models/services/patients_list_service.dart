import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabajo_moviles_ninjacode/scr/core/utils/usecases/jwt_storage.dart';
import 'package:trabajo_moviles_ninjacode/scr/features/iam/domain/services/auth_service.dart';
import '../patient_model.dart';
import '../profile_model.dart';

class PatientsListService {
  final String baseUrl = 'http://localhost:8080/api/v1/medical-record/patient';
  final String profileBaseUrl = 'http://localhost:8080/api/v1/profile/profile';
  final String doctorBaseUrl = 'http://localhost:8080/api/v1/doctor/doctor';

  Future<List<Patient>> getPatients() async {
    final token = await JwtStorage.getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final authService = AuthService();
    final userId = await authService.getUserId();
    final profileResponse = await http.get(Uri.parse('$profileBaseUrl/userId/$userId'), headers: headers);
    if (profileResponse.statusCode != 200) {
      throw Exception('Error fetching profile for user id $userId');
    }
    final profileData = json.decode(profileResponse.body);
    final profileId = profileData['id'];

    final doctorResponse = await http.get(Uri.parse('$doctorBaseUrl/profile/$profileId'), headers: headers);
    if (doctorResponse.statusCode != 200) {
      throw Exception('Error fetching doctor for profile id $profileId');
    }
    final doctorData = json.decode(doctorResponse.body);
    final doctorId = doctorData['id'];

    final patientsResponse = await http.get(Uri.parse('$baseUrl/doctor/$doctorId'), headers: headers);
    if (patientsResponse.statusCode != 200) {
      throw Exception('Error fetching patients for doctor id $doctorId');
    }
    final patientsData = json.decode(patientsResponse.body) as List;

    List<Patient> patients = [];
    for (var patientData in patientsData) {
      final patient = Patient.fromJson(patientData);

      // Fetch the profile for each patient
      final profileResponse = await http.get(Uri.parse('$profileBaseUrl/${patient.profileId}'), headers: headers);
      if (profileResponse.statusCode == 200) {
        final profileData = json.decode(profileResponse.body);
        patient.profile = Profile.fromJson(profileData);
      }

      patients.add(patient);
    }
    return patients;
  }
}