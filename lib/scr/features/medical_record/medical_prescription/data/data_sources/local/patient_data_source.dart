import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/medical_prescription/domain/models/patient_model.dart';
import '../../../domain/models/services/patients_list_service.dart';

class PatientsDataSource {
  final PatientsListService _patientsListService = PatientsListService();

  Future<List<Patient>> getPatients() async {
    try {
      return await _patientsListService.getPatients();
    } catch (e) {
      throw Exception('Error fetching patients: $e');
    }
  }
}
