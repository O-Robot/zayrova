import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/auth/auth_components.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool showPassword = false;
  bool acceptsTerms = true;
  String? formError;

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void _createAccount() {
    final hasRequiredFields =
        firstName.text.trim().isNotEmpty &&
        lastName.text.trim().isNotEmpty &&
        email.text.trim().isNotEmpty &&
        password.text.isNotEmpty;

    if (!hasRequiredFields) {
      setState(() => formError = 'Complete all required fields to continue.');
      return;
    }

    if (!acceptsTerms) {
      setState(
        () => formError = 'Accept the terms and conditions to continue.',
      );
      return;
    }

    setState(() => formError = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Account creation is unavailable right now. Please sign in with an existing account.',
        ),
        backgroundColor: ZayColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const AuthHeader(
          title: 'Create Account',
          subtitle: 'Fill in all information to create your account',
        ),
        const SizedBox(height: 38),
        Row(
          children: [
            Expanded(
              child: AuthField(
                label: 'First Name',
                hint: 'First name',
                controller: firstName,
                icon: Icons.person_outline,
                onChanged: (_) {
                  if (formError != null) {
                    setState(() => formError = null);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AuthField(
                label: 'Last Name',
                hint: 'Last name',
                controller: lastName,
                icon: Icons.person_outline,
                onChanged: (_) {
                  if (formError != null) {
                    setState(() => formError = null);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        AuthField(
          label: 'Email',
          hint: 'Enter your email',
          controller: email,
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) {
            if (formError != null) {
              setState(() => formError = null);
            }
          },
        ),
        const SizedBox(height: 26),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: acceptsTerms,
              fillColor: const WidgetStatePropertyAll(ZayColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (value) {
                setState(() => acceptsTerms = value ?? acceptsTerms);
              },
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Agree with ',
                      style: ZayTheme.lightTheme.textTheme.displayMedium
                          ?.copyWith(color: ZayColors.textSecondary),
                    ),
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: ZayTheme.lightTheme.textTheme.displayMedium
                          ?.copyWith(
                            color: ZayColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (formError != null) ...[
          const SizedBox(height: 12),
          Text(
            formError!,
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: const Color(0xFFE53935),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 30),
        AuthPrimaryButton(action: _createAccount, text: 'Create Account'),
        const SizedBox(height: 24),
        const AuthDividerLabel(text: 'Or using other method'),
        const SizedBox(height: 22),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthSocialButton(
              assetPath: ZayAssets.googleIcon,
              text: 'Sign In with Google',
            ),
            const SizedBox(width: 16),

            AuthSocialButton(
              assetPath: ZayAssets.facebookIcon,
              text: 'Sign In with Facebook',
            ),
            const SizedBox(width: 16),
            AuthSocialButton(
              assetPath: ZayAssets.appleIcon,
              text: 'Sign In with Apple',
            ),
          ],
        ),
        const SizedBox(height: 22),
        AuthFooterLink(
          prefix: 'Already have an account? ',
          actionText: 'Sign In',
          onTap: () => ZayRouter.goto(ZayRoutes.login),
        ),
      ],
    );
  }
}
