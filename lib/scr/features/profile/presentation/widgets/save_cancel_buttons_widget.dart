import 'package:flutter/material.dart';

class SaveCancelButtonsWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const SaveCancelButtonsWidget({
    Key? key,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: onCancel,
           style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAEBBC3), // Botón "Create event" con el color principal
                  ),
                  child: Text('Cancel', style: TextStyle(color: Colors.black)),
                ),
        ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF40535B), // Botón "Create event" con el color principal
                  ),
                  child: Text('Save', style: TextStyle(color: Colors.white)),
                ),
      ],
    );
  }
}