import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NoticeManager {
  static Map<String, dynamic>? currentNotice;

  static Future<void> setNotice(Map<String, dynamic> notice) async {
    currentNotice = notice;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentNotice', jsonEncode(notice));
  }

  static Future<void> loadNotice() async {
    final prefs = await SharedPreferences.getInstance();
    final noticeStr = prefs.getString('currentNotice');
    if (noticeStr != null) {
      currentNotice = jsonDecode(noticeStr);
    } else {
      currentNotice = null;
    }
  }

  static Future<void> clearNotice() async {
    currentNotice = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentNotice');
  }

  static Map<String, dynamic>? getNotice() {
    return currentNotice;
  }
}