import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onCreate;

  const CustomButtons({
    Key? key,
    required this.onClear,
    required this.onCreate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onClear,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFAEBBC3), // Botón "Clear" con color gris
            ),
            child: Text('Clear', style: TextStyle(color: Colors.black)),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF40535B), // Botón "Create event" con el color principal
            ),
            child: Text('Create event', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
          ),
        ),
      ],
    );
  }
}