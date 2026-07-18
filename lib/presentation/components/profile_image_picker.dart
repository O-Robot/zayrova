import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/presentation/pages/profile/profile_components.dart';

class ProfileImagePicker extends StatefulWidget {
  final void Function(XFile? pickedImage) onImagePicked;

  const ProfileImagePicker({super.key, required this.onImagePicked});

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
      widget.onImagePicked(_selectedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = profileImageProvider(_selectedImage?.path);

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],
          backgroundImage: imageProvider,
          child:
              imageProvider == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
        ),
        Positioned(
          bottom: 2,
          right: 0,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: _pickImage,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ZayColors.primary,
                  border: Border.all(color: ZayColors.white, width: 3),
                ),
                child: Center(
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: Image.asset(
                      ZayIcons.editIcon,
                      color: Colors.white,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
