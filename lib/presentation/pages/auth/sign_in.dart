import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/auth/auth_components.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({super.key});

  @override
  ConsumerState<SignIn> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignIn> {
  final TextEditingController email = TextEditingController(text: 'emilys');
  final TextEditingController password = TextEditingController(
    text: 'emilyspass',
  );
  bool showPassword = false;
  String? formError;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final username = email.text.trim();
    final pass = password.text;

    if (username.isEmpty || pass.isEmpty) {
      setState(() => formError = 'Enter your username and password.');
      return;
    }

    setState(() => formError = null);

    await ref
        .read(authControllerProvider.notifier)
        .login(username: username, password: pass);

    if (!mounted) {
      return;
    }

    final authState = ref.read(authControllerProvider);
    if (authState.isAuthenticated) {
      ZayRouter.exit(ZayRoutes.home);
      return;
    }

    final message = authState.errorMessage ?? 'Unable to sign in.';
    setState(() => formError = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: ZayColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return AuthScaffold(
      children: [
        const AuthHeader(
          title: 'Login',
          subtitle: "Hi! Welcome back, you've been missed",
        ),
        const SizedBox(height: 38),
        AuthField(
          label: 'Username',
          hint: 'Enter your username',
          controller: email,
          icon: Icons.person_outline,
          keyboardType: TextInputType.text,
          onChanged: (_) {
            if (formError != null) {
              setState(() => formError = null);
            }
          },
        ),
        const SizedBox(height: 26),
        AuthField(
          label: 'Password',
          hint: 'Enter your password',
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
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => ZayRouter.goto(ZayRoutes.forgotPassword),
            style: TextButton.styleFrom(
              foregroundColor: ZayColors.primary,
              padding: EdgeInsets.only(left: 10, right: 10),
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
        const SizedBox(height: 38),
        AuthPrimaryButton(
          action: _signIn,
          text: 'Sign In',
          isLoading: authState.isLoading,
        ),
        const SizedBox(height: 24),
        const AuthDividerLabel(text: 'Or sign in with'),
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
          prefix: "Don't have an account? ",
          actionText: 'Sign Up',
          onTap: () => ZayRouter.goto(ZayRoutes.register),
        ),
      ],
    );
  }
}
