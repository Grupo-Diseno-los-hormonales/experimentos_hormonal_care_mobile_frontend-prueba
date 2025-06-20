import 'package:experimentos_hormonal_care_mobile_frontend/scr/features/admin/presentation/pages/support_chat_section_state.dart';
import 'package:flutter/material.dart';

class SupportChatScreen extends StatelessWidget {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Chat'),
        backgroundColor: Color(0xFF8F7193),
        centerTitle: true,
      ),
      body: const SupportUserChatSection(),
    );
  }
}