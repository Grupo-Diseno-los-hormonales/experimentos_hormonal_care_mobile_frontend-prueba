import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/medical_prescription/domain/models/patient_model.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/medical_record/medical_prescription/data/data_sources/local/patient_data_source.dart';

class GetPatientsUseCase {
  final PatientsDataSource dataSource = PatientsDataSource();

  Future<List<Patient>> execute() async {
    return await dataSource.getPatients();
  }
}