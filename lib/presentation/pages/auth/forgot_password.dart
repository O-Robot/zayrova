import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/auth/auth_components.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController email = TextEditingController();
  String? formError;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (email.text.trim().isEmpty) {
      setState(() => formError = 'Enter your email or phone number.');
      return;
    }

    setState(() => formError = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'If this account exists, a recovery code will be sent shortly.',
        ),
        backgroundColor: ZayColors.primary,
      ),
    );
    ZayRouter.goto(ZayRoutes.verifyEmail);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      children: [
        const AuthHeader(
          title: 'Forgot Password',
          subtitle: 'Enter your email or phone number',
        ),
        const SizedBox(height: 38),
        AuthField(
          label: 'Email or Phone Number',
          hint: 'Enter your email or phone number',
          controller: email,
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
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
        const SizedBox(height: 42),
        AuthPrimaryButton(
          action: _sendCode,
          text: 'Send Code',
        ),
        const SizedBox(height: 30),
        AuthFooterLink(
          prefix: 'Remembered password? ',
          actionText: 'Sign In',
          onTap: () => ZayRouter.goto(ZayRoutes.login),
        ),
        const SizedBox(height: 24),
        Text(
          'You will receive a verification code if the account exists.',
          textAlign: TextAlign.center,
          style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
            color: ZayColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
