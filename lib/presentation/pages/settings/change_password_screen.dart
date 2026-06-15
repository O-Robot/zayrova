import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/presentation/pages/profile/profile_components.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showDeferredChangeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password update will be connected with auth APIs.'),
        backgroundColor: ZayColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Change Password',
      bottom: _ChangePasswordBar(onChange: _showDeferredChangeMessage),
      children: [
        ProfileTextField(
          label: 'New Password',
          hint: 'Enter new password',
          controller: newPasswordController,
          icon: Icons.lock_outline,
          obscureText: !showNewPassword,
          trailingIcon:
              showNewPassword ? Icons.visibility : Icons.visibility_off,
          onTrailingTap: () {
            setState(() => showNewPassword = !showNewPassword);
          },
        ),
        const SizedBox(height: 24),
        ProfileTextField(
          label: 'Confirm Password',
          hint: 'Confirm your new password',
          controller: confirmPasswordController,
          icon: Icons.lock_outline,
          obscureText: !showConfirmPassword,
          trailingIcon:
              showConfirmPassword ? Icons.visibility : Icons.visibility_off,
          onTrailingTap: () {
            setState(() => showConfirmPassword = !showConfirmPassword);
          },
        ),
      ],
    );
  }
}

class _ChangePasswordBar extends StatelessWidget {
  const _ChangePasswordBar({required this.onChange});

  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
      color: ZayColors.white,
      child: SafeArea(
        top: false,
        child: ZayButton.primary(
          action: onChange,
          text: 'Change Now',
          fullWidth: true,
        ),
      ),
    );
  }
}
