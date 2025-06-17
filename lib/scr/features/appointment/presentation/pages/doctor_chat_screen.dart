import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/communication/data/data_sources/remote/communication_api.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/data/data_sources/remote/medical_appointment_api.dart';
import 'package:flutter/material.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/core/utils/usecases/jwt_storage.dart';
import 'package:intl/intl.dart';

class DoctorChatScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final int currentUserId;
  
  const DoctorChatScreen({
    Key? key, 
    required this.doctor,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _DoctorChatScreenState createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CommunicationApi _communicationApi = CommunicationApi();
  final MedicalAppointmentApi _medicalApi = MedicalAppointmentApi();
  final List<ChatMessage> _messages = [];
  
  bool _isLoading = true;
  bool _isSending = false;
  bool _isInitialized = false;
  int? _conversationId;
  int? _doctorProfileId;
  String _initializationError = '';
  Map<String, dynamic>? _doctorCompleteInfo;
  
  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeConversation() async {
    try {
      setState(() {
        _isLoading = true;
        _initializationError = '';
        _isInitialized = false;
      });
      
      final currentUserId = widget.currentUserId;
      
      // Paso 1: Preparar los datos del doctor
      final doctorData = Map<String, dynamic>.from(widget.doctor);
      _prepareDoctorData(doctorData);
      
      // Paso 2: Obtener el doctorId (el ID real del doctor en la base de datos)
      final doctorId = _extractDoctorId(doctorData);
      if (doctorId == null) {
        throw Exception('No se pudo obtener el ID del doctor de los datos proporcionados');
      }
      
      // Paso 3: Obtener el profileId del doctor (para las conversaciones)
      _doctorProfileId = _extractDoctorProfileId(doctorData);
      if (_doctorProfileId == null) {
        // Si no tenemos profileId directamente, intentar obtenerlo del servicio
        try {
          _doctorProfileId = await _medicalApi.getProfileIdByDoctorId(doctorId);
        } catch (e) {
          // Como fallback, usar el doctorId como profileId
          _doctorProfileId = doctorId;
        }
      }
      
      if (_doctorProfileId == null) {
        throw Exception('No se pudo obtener el Profile ID del doctor');
      }
      
      // Paso 4: Obtener información completa del doctor si es necesario
      try {
        _doctorCompleteInfo = await _medicalApi.fetchDoctorProfileDetails(doctorId);
      } catch (e) {
        // Usar los datos que ya tenemos
        _doctorCompleteInfo = doctorData;
      }

      // Paso 5: Validar que no sea el mismo usuario
      if (currentUserId == _doctorProfileId) {
        throw Exception('No puedes iniciar una conversación contigo mismo');
      }

      // Paso 6: Buscar o crear conversación
      await _findOrCreateConversation(currentUserId);
      
      // Paso 7: Cargar mensajes existentes (si los hay)
      await _loadMessages();
      
      // Paso 8: Marcar como inicializado
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _initializationError = e.toString();
        _isInitialized = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error iniciando chat: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Método que replica la lógica de _scheduleAppointment de DoctorListScreen
  void _prepareDoctorData(Map<String, dynamic> doctor) {
    
    // Aplicar la misma lógica que en DoctorListScreen._scheduleAppointment
    if (doctor['userId'] == null) {
      if (doctor['id'] != null) {
        doctor['userId'] = doctor['id'];
      } else if (doctor['profileId'] != null) {
        doctor['userId'] = doctor['profileId'];
      } else if (doctor['doctorId'] != null) {
        // Para casos donde viene desde AppointmentDoctorDetail
        doctor['userId'] = doctor['doctorId'];
        doctor['id'] = doctor['doctorId']; // También asignar como id
      }
    }
  }

  // Extraer el ID del doctor (para usar con el servicio médico)
  int? _extractDoctorId(Map<String, dynamic> doctor) {
    
    // Lista de posibles campos donde puede estar el ID del doctor
    final possibleFields = ['id', 'doctorId', 'userId', 'profileId'];
    
    for (String field in possibleFields) {
      final value = doctor[field];
      if (value != null && value is int && value > 0) {
        return value;
      }
    }
    return null;
  }

  // Extraer el Profile ID del doctor (para las conversaciones)
  // ¡CORRECCIÓN DEL BUG PRINCIPAL!
  int? _extractDoctorProfileId(Map<String, dynamic> doctor) {
    
    // Priorizar 'profileId' si está disponible
    final profileId = doctor['profileId'];
    if (profileId != null && profileId is int && profileId > 0) {
      return profileId;
    }
    
    // CORRECCIÓN: Cambiar 'Id' por 'userId'
    final userId = doctor['userId']; // ¡Era doctor['Id'] - error tipográfico!
    if (userId != null && userId is int && userId > 0) {
      return userId;
    }
    
    // Fallback adicional
    final id = doctor['id'];
    if (id != null && id is int && id > 0) {
      return id;
    }
    return null;
  }

  Future<void> _findOrCreateConversation(int currentUserId) async {
    
    try {
      final conversations = await _communicationApi.getConversationsByUserId(currentUserId);
      Map<String, dynamic>? existingConversation;
      
      for (var conversation in conversations) {
        final participants = conversation['participants'] as List<dynamic>? ?? [];
        
        bool doctorInConversation = participants.any((participant) {
          final participantUserId = participant['userId'];
          print('  Participante: $participantUserId, buscando: $_doctorProfileId');
          return participantUserId == _doctorProfileId;
        });
        
        if (doctorInConversation) {
          existingConversation = conversation;
          break;
        }
      }

      if (existingConversation != null) {
        _conversationId = existingConversation['id'];
      } else {
        final newConversation = await _communicationApi.createConversation([currentUserId, _doctorProfileId!]);
        _conversationId = newConversation['id'];
      }
    } catch (e) {
      throw Exception('Error al gestionar la conversación: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) {
      return;
    }

    try {
      final rawMessages = await _communicationApi.getMessagesByConversationId(
        _conversationId!, 
        widget.currentUserId
      );

      final loadedMessages = rawMessages.map((msg) {
        return ChatMessage(
          text: msg['text'] ?? '',
          timestamp: DateTime.parse(msg['sentAt']),
          senderName: msg['senderProfileId'] == widget.currentUserId ? 'You' : 'Doctor',
          senderId: msg['senderProfileId'],
        );
      }).toList();

      setState(() {
        _messages.clear();
        _messages.addAll(loadedMessages);
      });

      if (_messages.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      print('⚠️ Error cargando mensajes: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || 
        _conversationId == null || 
        _doctorProfileId == null ||
        !_isInitialized) {
      print('⚠️ No se puede enviar mensaje');
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      await _communicationApi.sendMessage(
        conversationId: _conversationId!,
        senderProfileId: widget.currentUserId,
        receiverProfileId: _doctorProfileId!,
        text: messageText,
      );

      await _loadMessages();
      _showMessageSentConfirmation();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando mensaje: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _retryInitialization() {
    _initializeConversation();
  }
  
  void _showMessageSentConfirmation() {
    final doctorName = _doctorCompleteInfo?['fullName']?.split(' ')[0] ?? 
                     widget.doctor['fullName']?.split(' ')[0] ?? 
                     'el doctor';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mensaje enviado a Dr. $doctorName'),
        backgroundColor: const Color(0xFFA78AAB),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool get _canSendMessages {
    return _isInitialized && 
           !_isSending && 
           _conversationId != null && 
           _doctorProfileId != null &&
           _initializationError.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final displayInfo = _doctorCompleteInfo ?? widget.doctor;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA78AAB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: displayInfo['imageUrl'] != null || displayInfo['image'] != null
                  ? NetworkImage(displayInfo['imageUrl'] ?? displayInfo['image'])
                  : null,
              backgroundColor: Colors.grey[200],
              child: (displayInfo['imageUrl'] == null && displayInfo['image'] == null)
                  ? const Icon(Icons.person, color: Color(0xFFA78AAB))
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayInfo['fullName'] ?? 'Doctor',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    displayInfo['specialty'] ?? 'Doctor',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => _showDoctorInfo(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicador de estado
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: _initializationError.isNotEmpty 
                ? Colors.red[100] 
                : _isInitialized 
                    ? Colors.green[100] 
                    : Colors.orange[100],
            child: Center(
              child: _initializationError.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error de inicialización',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        TextButton(
                          onPressed: _retryInitialization,
                          child: const Text('Reintentar', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    )
                  : _isInitialized
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Chat listo con Dr. ${displayInfo['fullName']?.split(' ')[0] ?? 'el doctor'}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange[700],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Inicializando chat...',
                              style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
            ),
          ),
          
          // Lista de mensajes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFA78AAB)))
                : _initializationError.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            const Text(
                              'Error al inicializar el chat',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _retryInitialization,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA78AAB),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : _messages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay mensajes aún',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Inicia la conversación con tu doctor',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageBubble(_messages[index]);
                            },
                          ),
          ),
          
          // Divisor
          const Divider(height: 1),
          
          // Campo de entrada de mensaje
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: _canSendMessages
                          ? 'Escribe un mensaje al doctor...'
                          : _initializationError.isNotEmpty
                              ? 'Error en la inicialización'
                              : 'Inicializando chat...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _canSendMessages ? Colors.grey[200] : Colors.grey[300],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    enabled: _canSendMessages,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: _canSendMessages
                      ? const Color(0xFFA78AAB) 
                      : Colors.grey,
                  onPressed: _canSendMessages ? _sendMessage : null,
                  child: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.senderId == widget.currentUserId;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFA78AAB),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFE2D1F4) : Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  
  void _showDoctorInfo() {
    final displayInfo = _doctorCompleteInfo ?? widget.doctor;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: displayInfo['imageUrl'] != null || displayInfo['image'] != null
                        ? NetworkImage(displayInfo['imageUrl'] ?? displayInfo['image'])
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: (displayInfo['imageUrl'] == null && displayInfo['image'] == null)
                        ? const Icon(Icons.person, size: 40, color: Color(0xFFA78AAB))
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayInfo['fullName'] ?? 'Unknown Doctor',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayInfo['specialty'] ?? 'General Medicine',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              const Text(
                'Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayInfo['experience'] ?? 'Not specified',
                style: const TextStyle(fontSize: 16),
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayInfo['about'] ?? 'No information available',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final DateTime timestamp;
  final String senderName;
  final int senderId;
  
  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.senderName,
    required this.senderId,
  });
}
