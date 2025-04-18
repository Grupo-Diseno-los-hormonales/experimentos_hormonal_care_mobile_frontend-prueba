import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final bool isEditing;
  final VoidCallback toggleEditMode;
  final String? imageUrl;

  ProfilePictureWidget({required this.isEditing, required this.toggleEditMode, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleEditMode,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
            ? NetworkImage(imageUrl!)
            : null,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Icon(Icons.person, size: 50)
            : null,
      ),
    );
  }
}