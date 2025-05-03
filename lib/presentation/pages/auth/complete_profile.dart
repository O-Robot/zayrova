import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/profile_image.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/widgets/button.dart';
import 'package:zayrova/presentation/widgets/input.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final phoneNumber = TextEditingController();
  String? selectedGender;
  File? _pickedImage;

  void _handleImagePicked(File? image) {
    setState(() {
      _pickedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ZayRouter.goBack();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ZayColors.textSecondary),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: ZayColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Complete Your Profile',
                    style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: ZayColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    'Don’t worry, only you can see your personal data. No one else will be able to see it',
                    textAlign: TextAlign.center,
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(color: ZayColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 30),

                // Reusable image picker
                Center(
                  child: ProfileImagePicker(onImagePicked: _handleImagePicked),
                ),

                const SizedBox(height: 20),
                ZayTextInput.primary(
                  "Phone Number",
                  controller: phoneNumber,
                  type: TextInputType.phone,
                ),
                const SizedBox(height: 5),
                ZayTextInput.dropdown(
                  "Gender",
                  items: ['Male', 'Female', 'Other'],
                  onChanged: (value) => selectedGender = value,
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ZayButton.primary(
                    action: () {},
                    text: 'Complete Profile',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
