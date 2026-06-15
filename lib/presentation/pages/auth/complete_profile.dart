import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/profile_image_picker.dart';
import 'package:zayrova/presentation/pages/auth/auth_components.dart';
import 'package:zayrova/presentation/widgets/input.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final phoneNumber = TextEditingController();
  String? selectedGender;
  XFile? pickedImage;

  @override
  void dispose() {
    phoneNumber.dispose();
    super.dispose();
  }

  void _handleImagePicked(XFile? image) {
    setState(() {
      if (image != null) {
        pickedImage = image;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      children: [
        const AuthCenteredHeader(
          title: 'Complete Your Profile',
          subtitle:
              'Only you can see your personal data. Add a few details to continue.',
        ),
        const SizedBox(height: 30),
        Center(
          child: ProfileImagePicker(onImagePicked: _handleImagePicked),
        ),
        const SizedBox(height: 30),
        AuthField(
          label: 'Phone Number',
          hint: 'Enter your phone number',
          controller: phoneNumber,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 26),
        _ProfileDropdown(
          value: selectedGender,
          onChanged: (value) {
            setState(() => selectedGender = value);
          },
        ),
        const SizedBox(height: 48),
        AuthPrimaryButton(
          action: () {},
          text: 'Complete Profile',
        ),
      ],
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ZayTextInput.dropdown(
          'Select gender',
          value: value,
          items: const ['Male', 'Female', 'Other'],
          onChanged: onChanged,
          height: 58,
          context: context,
        ),
      ],
    );
  }
}
