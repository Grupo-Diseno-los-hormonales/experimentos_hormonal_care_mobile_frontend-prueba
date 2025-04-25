import 'package:flutter/material.dart';

class CustomButtons extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onCreate;
  final Color clearButtonColor;
  final Color createButtonColor;
  final Color textColor;

  const CustomButtons({
    Key? key,
    required this.onClear,
    required this.onCreate,
    this.clearButtonColor = Colors.grey, // Valor predeterminado
    this.createButtonColor = Colors.blue, // Valor predeterminado
    this.textColor = Colors.white, // Valor predeterminado
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onClear,
            style: ElevatedButton.styleFrom(
              backgroundColor: clearButtonColor, // Color del botón "Clear"
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: Text(
              'Clear',
              style: TextStyle(color: textColor), // Color del texto
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: createButtonColor, // Color del botón "Create"
              padding: EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: Text(
              'Create',
              style: TextStyle(color: textColor), // Color del texto
            ),
          ),
        ),
      ],
    );
  }
}