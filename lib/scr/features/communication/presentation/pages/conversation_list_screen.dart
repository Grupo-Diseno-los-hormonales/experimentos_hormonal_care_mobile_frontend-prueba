import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/appointment/presentation/pages/doctor_chat_screen.dart';
import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/communication/data/data_sources/remote/communication_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({Key? key}) : super(key: key);

  @override
  _ConversationListScreenState createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final CommunicationApi _communicationService = CommunicationApi();
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final conversations = await _communicationService.getMyConversations();
      
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mensajes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFA78AAB),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFA78AAB)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Error cargando conversaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadConversations,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA78AAB),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay conversaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Inicia una conversación con un doctor',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: const Color(0xFFA78AAB),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _buildConversationCard(conversation);
        },
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conversation) {
    final participants = conversation['participants'] as List<dynamic>? ?? [];
    final lastActivity = DateTime.parse(conversation['lastActivityAt'] ?? DateTime.now().toIso8601String());
    
    // Encontrar el otro participante (asumiendo que es el doctor)
    final otherParticipant = participants.isNotEmpty ? participants.first : null;
    final participantType = otherParticipant?['type'] ?? 'Doctor';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToChat(conversation),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFA78AAB),
                child: Text(
                  participantType[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$participantType Chat',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatTime(lastActivity),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    Text(
                      'Conversación activa',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  void _navigateToChat(Map<String, dynamic> conversation) {
    // Extraer información del doctor de los participantes
    final participants = conversation['participants'] as List<dynamic>? ?? [];
    final doctorParticipant = participants.isNotEmpty ? participants.first : null;
    
    if (doctorParticipant != null) {
      final doctorData = {
        'id': doctorParticipant['userId'],
        'fullName': 'Doctor ${doctorParticipant['type']}',
        'specialty': doctorParticipant['type'],
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorChatScreen(
            doctor: doctorData,
            currentUserId: conversation['participants']
                .firstWhere((p) => p['userId'] != doctorParticipant['userId'])['userId'],
          ),
        ),
      ).then((_) {
        _loadConversations();
      });
    }
  }
}
