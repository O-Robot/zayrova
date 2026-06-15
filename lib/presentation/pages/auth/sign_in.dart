import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/auth/auth_components.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool showPassword = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const AuthHeader(
          title: 'Login Account',
          subtitle: 'Please login with registered account',
        ),
        const SizedBox(height: 38),
        AuthField(
          label: 'Email or Phone Number',
          hint: 'Enter your email or phone number',
          controller: email,
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
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
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => ZayRouter.goto(ZayRoutes.forgotPassword),
            style: TextButton.styleFrom(
              foregroundColor: ZayColors.primary,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Forgot Password?',
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 38),
        AuthPrimaryButton(
          action: () => ZayRouter.goto(ZayRoutes.home),
          text: 'Sign In',
        ),
        const SizedBox(height: 24),
        const AuthDividerLabel(text: 'Or using other method'),
        const SizedBox(height: 22),
        AuthSocialButton(
          assetPath: ZayAssets.googleIcon,
          text: 'Sign In with Google',
        ),
        const SizedBox(height: 16),
        AuthSocialButton(
          assetPath: ZayAssets.facebookIcon,
          text: 'Sign In with Facebook',
        ),
        const SizedBox(height: 34),
        AuthFooterLink(
          prefix: "Don't have an account? ",
          actionText: 'Sign Up',
          onTap: () => ZayRouter.goto(ZayRoutes.register),
        ),
      ],
    );
  }
}
