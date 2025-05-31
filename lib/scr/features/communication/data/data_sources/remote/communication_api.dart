import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';

class CommunicationApi {
  static const String _baseUrl = 'http://localhost:8080/api/v1';

  // Obtener conversaciones por del usuario
  Future<List<Map<String, dynamic>>> getConversationsByUserId(int userId) async {
    try {
      final token = await JwtStorage.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching conversations: $e');
      throw Exception('Error fetching conversations: $e');
    }
  }

  // Obtener conversación por ID
  Future<Map<String, dynamic>> getConversationById(int conversationId) async {
    try {
      final token = await JwtStorage.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations/$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching conversation: $e');
      throw Exception('Error fetching conversation: $e');
    }
  }

  // Obtener mensajes de una conversación
  Future<List<Map<String, dynamic>>> getMessagesByConversationId(
    int conversationId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final token = await JwtStorage.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/Messages/conversations/$conversationId/messages?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
      throw Exception('Error fetching messages: $e');
    }
  }

  // Enviar mensaje
  Future<int> sendMessage({
    required int conversationId,
    required int senderProfileId,
    required int receiverProfileId,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final token = await JwtStorage.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/Messages/conversations/$conversationId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'senderProfileId': senderProfileId,
          'receiverProfileId': receiverProfileId,
          'text': text,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 201) {
        return int.parse(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Error sending message: $e');
    }
  }

  // Crear conversación
  Future<Map<String, dynamic>> createConversation(List<int> participantIds) async {
    try {
      final token = await JwtStorage.getToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/conversations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'participantIds': participantIds,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create conversation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating conversation: $e');
      throw Exception('Error creating conversation: $e');
    }
  }

  // Marcar mensaje como leído
  Future<List<Map<String, dynamic>>> getUnreadMessages(int userId) async {
    try {
      final token = await JwtStorage.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/Messages/users/$userId/messages/unread'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load unread messages: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching unread messages: $e');
      throw Exception('Error fetching unread messages: $e');
    }
  }
}