// widgets/profile_image_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends StatefulWidget {
  final void Function(File? pickedImage) onImagePicked;

  const ProfileImagePicker({super.key, required this.onImagePicked});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      widget.onImagePicked(_selectedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              _selectedImage != null ? FileImage(_selectedImage!) : null,
          child:
              _selectedImage == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: InkWell(
            onTap: _pickImage,
            child: const CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white,
              child: Icon(Icons.edit, size: 15, color: Color(0xFF41644A)),
            ),
          ),
        ),
      ],
    );
  }
}
