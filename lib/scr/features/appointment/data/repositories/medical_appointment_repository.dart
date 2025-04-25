import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';

class MedicalAppointmentRepository {
  final MedicalAppointmentApi api;

  MedicalAppointmentRepository(this.api);

  Future<bool> createMedicalAppointment(Map<String, dynamic> appointmentData) async {
    return await api.createMedicalAppointment(appointmentData);
  }

  Future<List<Map<String, dynamic>>> fetchAppointmentsForToday() async {
    return await api.fetchAppointmentsForToday();
  }
}