import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/profile_image_picker.dart';
import 'package:zayrova/presentation/pages/auth/auth_components.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/input.dart';

class CompleteProfile extends ConsumerStatefulWidget {
  const CompleteProfile({super.key});

  @override
  ConsumerState<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends ConsumerState<CompleteProfile> {
  final phoneNumber = TextEditingController();
  String? selectedGender;
  XFile? pickedImage;
  String? formError;

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

  Future<void> _completeProfile() async {
    if (phoneNumber.text.trim().isEmpty || selectedGender == null) {
      setState(() => formError = 'Add your phone number and gender.');
      return;
    }

    final user = ref.read(authControllerProvider).currentUser;
    if (user == null) {
      setState(() {
        formError = 'Sign in first to complete your profile.';
      });
      return;
    }

    setState(() => formError = null);
    await ref.read(authControllerProvider.notifier).updateLocalProfile(
          user.copyWith(
            phoneNumber: phoneNumber.text.trim(),
            gender: selectedGender,
            avatarUrl: pickedImage?.path ?? user.avatarUrl,
          ),
        );

    if (!mounted) {
      return;
    }

    final error = ref.read(authControllerProvider).errorMessage;
    if (error != null && error.isNotEmpty) {
      setState(() => formError = error);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated.'),
        backgroundColor: ZayColors.primary,
      ),
    );
    ZayRouter.goto(ZayRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

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
          onChanged: (_) {
            if (formError != null) {
              setState(() => formError = null);
            }
          },
        ),
        const SizedBox(height: 26),
        _ProfileDropdown(
          value: selectedGender,
          onChanged: (value) {
            setState(() {
              selectedGender = value;
              formError = null;
            });
          },
        ),
        if (formError != null) ...[
          const SizedBox(height: 14),
          Text(
            formError!,
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: const Color(0xFFE53935),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 48),
        AuthPrimaryButton(
          action: _completeProfile,
          text: 'Complete Profile',
          isLoading: authState.isLoading,
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
