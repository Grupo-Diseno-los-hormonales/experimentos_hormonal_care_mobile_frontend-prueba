import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAdminGlobalChatApi {
  static const String _chatKey = 'admin_global_chat';

  static Future<List<Map<String, dynamic>>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_chatKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> addMessage(Map<String, dynamic> message) async {
    final prefs = await SharedPreferences.getInstance();
    final messages = await getMessages();
    messages.add(message);
    await prefs.setString(_chatKey, json.encode(messages));
  }

  static Future<void> addDivider() async {
    await addMessage({'type': 'divider', 'timestamp': DateTime.now().toIso8601String()});
  }

  // NUEVO: Limpiar todos los mensajes del chat
  static Future<void> clearChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatKey);
  }
  
  static Future<void> clearChatForUser(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final messages = await getMessages();
  messages.removeWhere((msg) => msg['userId'] == userId);
  await prefs.setString(_chatKey, json.encode(messages));
}
}