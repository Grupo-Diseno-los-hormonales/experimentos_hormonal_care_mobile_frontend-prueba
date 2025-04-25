import 'package:flutter/material.dart';

class UserInfoSection extends StatelessWidget {
  const UserInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF8F7193), // Fondo morado oscuro
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/images/user_avatar.png'), // Replace with actual image path
            backgroundColor: Color(0xFFA788AB), // Fondo morado intermedio
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFDFCAE1), // Texto morado claro
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Age: 30',
            style: TextStyle(
              fontSize: 16.0,
              color: Color(0xFFDFCAE1), // Texto morado claro
            ),
          ),
        ],
      ),
    );
  }
}