import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
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
        ),
        const SizedBox(height: 48),
        AuthPrimaryButton(
          action: () {},
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
