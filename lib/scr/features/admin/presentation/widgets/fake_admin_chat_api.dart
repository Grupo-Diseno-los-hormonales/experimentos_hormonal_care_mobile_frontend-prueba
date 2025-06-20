import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAdminChatApi {
  static String _chatKey(String userId) => 'admin_chat_$userId';

  static Future<List<Map<String, dynamic>>> getMessages(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _chatKey(userId);
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> addMessage(String userId, Map<String, dynamic> message) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _chatKey(userId);
    final messages = await getMessages(userId);
    messages.add(message);
    await prefs.setString(key, json.encode(messages));
  }
}