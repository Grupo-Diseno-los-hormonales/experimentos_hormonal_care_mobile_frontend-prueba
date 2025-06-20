import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FakeChatApi {
  static String _chatKey(int doctorId, int patientId) =>
      'chat_${doctorId}_$patientId';

  static Future<List<Map<String, dynamic>>> getMessages(
      int doctorId, int patientId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _chatKey(doctorId, patientId);
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> addMessage(
      int doctorId, int patientId, Map<String, dynamic> message) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _chatKey(doctorId, patientId);
    final messages = await getMessages(doctorId, patientId);
    messages.add(message);
    await prefs.setString(key, json.encode(messages));
  }
}