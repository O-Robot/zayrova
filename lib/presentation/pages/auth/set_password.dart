import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/auth/auth_components.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class SetPassword extends StatefulWidget {
  const SetPassword({super.key});

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  bool showPassword = false;
  bool showConfirmPassword = false;
  String? formError;

  @override
  void dispose() {
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (password.text.isEmpty || confirmPassword.text.isEmpty) {
      setState(() => formError = 'Enter and confirm your new password.');
      return;
    }

    if (password.text != confirmPassword.text) {
      setState(() => formError = 'Passwords do not match.');
      return;
    }

    setState(() => formError = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password reset needs backend support before it can update your account.',
        ),
        backgroundColor: ZayColors.primary,
      ),
    );
    ZayRouter.goto(ZayRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      children: [
        const AuthHeader(
          title: 'Create New Password',
          subtitle: 'Enter your new password',
        ),
        const SizedBox(height: 38),
        AuthField(
          label: 'Password',
          hint: 'Create your password',
          controller: password,
          icon: Icons.lock_outline,
          obscureText: !showPassword,
          trailingIcon: showPassword ? Icons.visibility : Icons.visibility_off,
          onTrailingTap: () {
            setState(() => showPassword = !showPassword);
          },
          onChanged: (_) {
            if (formError != null) {
              setState(() => formError = null);
            }
          },
        ),
        const SizedBox(height: 26),
        AuthField(
          label: 'Confirm Password',
          hint: 'Confirm your password',
          controller: confirmPassword,
          icon: Icons.lock_outline,
          obscureText: !showConfirmPassword,
          trailingIcon:
              showConfirmPassword ? Icons.visibility : Icons.visibility_off,
          onTrailingTap: () {
            setState(() => showConfirmPassword = !showConfirmPassword);
          },
          onChanged: (_) {
            if (formError != null) {
              setState(() => formError = null);
            }
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
          action: _changePassword,
          text: 'Change Password',
        ),
        const SizedBox(height: 30),
        AuthFooterLink(
          prefix: 'Remembered password? ',
          actionText: 'Sign In',
          onTap: () => ZayRouter.goto(ZayRoutes.login),
        ),
      ],
    );
  }
}
