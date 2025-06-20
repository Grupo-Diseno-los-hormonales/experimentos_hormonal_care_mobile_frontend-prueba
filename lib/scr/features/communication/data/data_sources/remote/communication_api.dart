import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';

class CommunicationApi {
  static const String _baseUrl = 'http://localhost:8080/api/v1';

  Future<String?> _getToken() async {
    final token = await JwtStorage.getToken();
    if (token == null || token.isEmpty) {
      print("⚠️ No token found!");
      throw Exception('No token found');
    }
    return token;
  }


  Future<int?> _getCurrentUserId() async {
    return await JwtStorage.getProfileId();
  }

  // NUEVO: Buscar conversation_id real en la base de datos
  Future<int?> _findRealConversationId(int currentUserId, int doctorId) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      print('🔍 === BUSCANDO CONVERSATION_ID REAL ===');
      print('Current User: $currentUserId, Doctor: $doctorId');

      // Obtener todas las conversaciones
      final conversations = await getMyConversations();
      
      for (var conversation in conversations) {
        final participants = conversation['participants'] as List<dynamic>? ?? [];
        
        // Verificar si esta conversación tiene exactamente estos dos usuarios
        Set<int> participantIds = {};
        for (var participant in participants) {
          final userId = participant['userId'];
          if (userId != null) participantIds.add(userId);
        }
        
        if (participantIds.contains(currentUserId) && 
            participantIds.contains(doctorId) && 
            participantIds.length == 2) {
          
          // Intentar obtener el conversation_id real usando los participant IDs
          final participantId = participants[0]['id']; // ID del primer participante
          
          if (participantId != null) {
            final realId = await _queryConversationIdByParticipant(participantId);
            if (realId != null) {
              print('✅ Conversation ID real encontrado: $realId');
              return realId;
            }
          }
        }
      }
      
      print('❌ No se encontró conversation_id real');
      return null;
    } catch (e) {
      print('❌ Error buscando conversation_id real: $e');
      return null;
    }
  }

  // NUEVO: Query directo para obtener conversation_id por participant
  Future<int?> _queryConversationIdByParticipant(int participantId) async {
    final token = await _getToken();
    if (token == null) return null;

    try {
      // Intentar endpoint personalizado para obtener conversation_id
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations/by-participant/$participantId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['conversationId'];
      }
    } catch (e) {
      print('⚠️ Endpoint personalizado no disponible: $e');
    }

    return null;
  }

  // Crear o encontrar conversación entre dos usuarios - MEJORADO
  Future<Map<String, dynamic>> getOrCreateConversation(int doctorId) async {
    final token = await _getToken();
    final currentUserId = await _getCurrentUserId();
    
    print('🔍 === INICIANDO getOrCreateConversation MEJORADO ===');
    print('Current User ID: $currentUserId');
    print('Doctor ID: $doctorId');
    
    if (token == null || currentUserId == null) {
      throw Exception('Authentication required');
    }

    try {
      // Buscar conversación existente
      final conversations = await getMyConversations();
      print('📋 Conversaciones encontradas: ${conversations.length}');
      
      for (int i = 0; i < conversations.length; i++) {
        final conversation = conversations[i];
        final participants = conversation['participants'] as List<dynamic>? ?? [];
        
        bool hasCurrentUser = false;
        bool hasDoctor = false;
        
        for (var participant in participants) {
          final userId = participant['userId'];
          if (userId == currentUserId) hasCurrentUser = true;
          if (userId == doctorId) hasDoctor = true;
        }
        
        if (hasCurrentUser && hasDoctor && participants.length == 2) {
          print('✅ Conversación existente encontrada');
          
          // MEJORADO: Buscar el conversation_id real
          final realConversationId = await _findRealConversationId(currentUserId, doctorId);
          
          if (realConversationId != null) {
            conversation['realConversationId'] = realConversationId;
            print('🎯 Conversation ID real asignado: $realConversationId');
          } else {
            // Fallback: usar participant ID como antes
            final tempId = _generateTempConversationId(conversation);
            conversation['tempId'] = tempId;
            print('🔧 Usando ID temporal como fallback: $tempId');
          }
          
          return conversation;
        }
      }
      
      // Si no existe, crear nueva conversación
      print('➕ Creando nueva conversación...');
      final newConversation = await createConversation([currentUserId, doctorId]);
      
      // Intentar obtener el ID real de la nueva conversación
      await Future.delayed(Duration(milliseconds: 500)); // Esperar un poco
      final realId = await _findRealConversationId(currentUserId, doctorId);
      
      if (realId != null) {
        newConversation['realConversationId'] = realId;
        print('🎯 Nueva conversación con ID real: $realId');
      } else {
        final tempId = _generateTempConversationId(newConversation);
        newConversation['tempId'] = tempId;
        print('🔧 Nueva conversación con ID temporal: $tempId');
      }
      
      return newConversation;
      
    } catch (e) {
      print('❌ Error en getOrCreateConversation: $e');
      throw Exception('Error managing conversation: $e');
    }
  }

  // Generar ID temporal basado en los participantes
  int _generateTempConversationId(Map<String, dynamic> conversation) {
    final participants = conversation['participants'] as List<dynamic>? ?? [];
    
    if (participants.length >= 2) {
      final userId1 = participants[0]['userId'] ?? 0;
      final userId2 = participants[1]['userId'] ?? 0;
      
      final minId = userId1 < userId2 ? userId1 : userId2;
      final maxId = userId1 > userId2 ? userId1 : userId2;
      
      final tempId = (minId * 1000) + maxId;
      return tempId;
    }
    
    return DateTime.now().millisecondsSinceEpoch % 100000;
  }

  // Crear nueva conversación
  Future<Map<String, dynamic>> createConversation(List<int> participantIds) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    print('➕ === CREANDO NUEVA CONVERSACIÓN ===');
    print('Participantes: $participantIds');

    final requestBody = {'participantIds': participantIds};

    final response = await http.post(
      Uri.parse('$_baseUrl/conversations'),
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      final result = jsonDecode(response.body);
      print('✅ Conversación creada exitosamente');
      return result;
    } else {
      throw Exception('Failed to create conversation: ${response.statusCode} - ${response.body}');
    }
  }

  // Obtener conversaciones del usuario actual
  Future<List<Map<String, dynamic>>> getMyConversations() async {
    final token = await _getToken();
    final currentUserId = await _getCurrentUserId();
    
    if (token == null || currentUserId == null) {
      throw Exception('Authentication required');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/conversations/user/$currentUserId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final conversations = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      return conversations;
    } else {
      throw Exception('Failed to load conversations: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required int conversationId,
    required int senderProfileId,
    required int receiverProfileId,
    required String text,
    String? imageUrl,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final requestBody = {
      'senderProfileId': senderProfileId, // ID del perfil del remitente
      'receiverProfileId': receiverProfileId, // ID del perfil del doctor
      'text': text, // El contenido del mensaje
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
    };

    print("Request body: $requestBody"); // Imprime el cuerpo de la solicitud para ver si todo está bien

    final response = await http.post(
      Uri.parse('$_baseUrl/messages/conversations/$conversationId/messages'),
      headers: {
        'Authorization': 'Bearer $token', // Asegúrate de que el token esté en el encabezado
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody), // Convierte el cuerpo a JSON
    );

    print("Response status: ${response.statusCode}"); // Imprime el código de estado de la respuesta
    print("Response body: ${response.body}"); // Imprime el cuerpo de la respuesta

    if (response.statusCode == 201) {
      return jsonDecode(response.body); // Si el mensaje se envió exitosamente, decodifica la respuesta
    } else {
      throw Exception('Error al enviar mensaje: ${response.statusCode} - ${response.body}');
    }
  }



  // MEJORADO: Obtener mensajes usando conversation_id real
  Future<List<Map<String, dynamic>>> getMessages({
    required Map<String, dynamic> conversation,
    int page = 0,
    int size = 50,
  }) async {
    final token = await _getToken();
    final currentUserId = await _getCurrentUserId();
    
    if (token == null || currentUserId == null) {
      throw Exception('Authentication required');
    }

    print('📨 === OBTENIENDO MENSAJES MEJORADO ===');

    // Lista de IDs para probar, priorizando el real
    List<int> conversationIdsToTry = [];
    
    if (conversation['id'] != null) {
      conversationIdsToTry.add(conversation['id']);
      print('📌 Probando con conversation["id"]: ${conversation["id"]}');
    }
    
    if (conversation['tempId'] != null) {
      conversationIdsToTry.add(conversation['tempId']);
      print('🔧 Fallback con temp ID: ${conversation['tempId']}');
    }

    // También probar con participant IDs
    final participants = conversation['participants'] as List<dynamic>? ?? [];
    for (var participant in participants) {
      final participantId = participant['id'];
      if (participantId != null) {
        conversationIdsToTry.add(participantId);
        print('👥 Fallback con participant ID: $participantId');
      }
    }

    // Probar cada ID hasta que uno funcione
    for (int conversationId in conversationIdsToTry) {
      try {
        final uri = Uri.parse('$_baseUrl/messages/conversations/$conversationId/messages')
            .replace(queryParameters: {
          'userId': currentUserId.toString(),
          'page': page.toString(),
          'size': size.toString(),
        });

        print('🔄 Probando endpoint: $uri');

        final response = await http.get(
          uri,
          headers: {'Authorization': 'Bearer $token'},
        );

        print('Response status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final messages = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          print('✅ Mensajes obtenidos con conversation ID $conversationId: ${messages.length}');
          return messages;
        } else {
          print('❌ Falló con conversation ID $conversationId: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error con conversation ID $conversationId: $e');
      }
    }

    print('⚠️ No se pudieron obtener mensajes con ningún ID, devolviendo lista vacía');
    return [];
  }


  Future<List<Map<String, dynamic>>> getRawConversations() async {
    final token = await JwtStorage.getToken();
    final userId = await JwtStorage.getProfileId();

    final response = await http.get(
      Uri.parse('http://localhost:8080/api/v1/conversations/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('🧾 RESPONSE BODY: ${response.body}');

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch raw conversations');
    }
  }

  Future<void> sendMessageWithId({
    required int conversationId,
    required int senderId,
    required int receiverId,
    required String text,
  }) async {
    final token = await JwtStorage.getToken();

    final response = await http.post(
      Uri.parse('http://localhost:8080/api/v1/messages/conversations/$conversationId/messages'),
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'senderProfileId': senderId,
        'receiverProfileId': receiverId,
        'text': text,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Error al enviar mensaje: ${response.statusCode}');
    }
  }


  Future<List<Map<String, dynamic>>> getMessagesByConversationId(int conversationId, int userId) async {
    final token = await _getToken();
      if (token == null) throw Exception('Token no encontrado');

      try {
        // Crear la URL con el conversationId y el userId (profileId)
        final uri = Uri.parse('$_baseUrl/messages/conversations/$conversationId/messages')
            .replace(queryParameters: {
          'userId': userId.toString(), // Pasar el userId (profileId)
        });

        // Realizar la solicitud GET al servidor
        final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

        // Verificar si la respuesta es exitosa (código 200)
        if (response.statusCode == 200) {
          final messages = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          return messages; // Retornar los mensajes obtenidos
        } else {
          throw Exception('Error al obtener los mensajes: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error al obtener los mensajes: $e');
        throw Exception('Error al obtener los mensajes');
      }
  }

  Future<List<Map<String, dynamic>>> getConversationsByUserId(int userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token no encontrado');

    try {
      final uri = Uri.parse('$_baseUrl/conversations/user/$userId');  // Pasar el userId en la URL
      final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        final conversations = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        return conversations;  // Retornar la lista de conversaciones
      } else {
        throw Exception('Error al obtener las conversaciones: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al obtener las conversaciones: $e');
      throw Exception('Error al obtener las conversaciones');
    }
  }

  Future<void> markMessageAsRead(int conversationId, int messageId, int userId) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final uri = Uri.parse('$_baseUrl/conversations/$conversationId/messages/$messageId/read?userId=$userId');

    try {
      final response = await http.patch(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('✅ Mensaje marcado como leído');
      } else {
        throw Exception('Error al marcar mensaje como leído: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al marcar mensaje como leído: $e');
      throw Exception('Error al marcar mensaje como leído');
    }
  }


}
