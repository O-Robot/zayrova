import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';
import 'package:zayrova/presentation/widgets/input.dart';
import 'package:zayrova/presentation/widgets/social_buttons.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Text(
                    'Sign In',
                    style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: ZayColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Hi! Welcome back, you’ve been missed',
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(color: ZayColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 40),

                // Email Input
                ZayTextInput.primary("Email", controller: email),
                const SizedBox(height: 5),

                // Password Input
                ZayTextInput.primary(
                  "Password",
                  controller: password,
                  password: !showPassword,
                  margin: EdgeInsets.only(bottom: 2),
                  trailingIcon:
                      showPassword ? Icons.visibility : Icons.visibility_off,
                  onTrailingIconTap: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                ),
                const SizedBox(height: 2),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ZayRouter.goto(ZayRoutes.forgotPassword);
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: ZayColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: ZayButton.primary(
                    action: () {
                      ZayRouter.goto(ZayRoutes.home);
                    },
                    text: 'Sign In',
                  ),
                ),
                const SizedBox(height: 30),

                // Divider with OR
                Row(
                  children: [
                    Padding(padding: const EdgeInsets.only(left: 30)),
                    const Expanded(
                      child: Divider(color: ZayColors.textSecondary),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Or sign in with',
                        style: ZayTheme.lightTheme.textTheme.displayMedium
                            ?.copyWith(color: ZayColors.textSecondary),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: ZayColors.textSecondary),
                    ),
                    Padding(padding: const EdgeInsets.only(right: 30)),
                  ],
                ),
                const SizedBox(height: 30),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialButtons.primary(
                      ZayAssets.appleIcon,
                    ), // Replace with your asset
                    const SizedBox(width: 20),
                    SocialButtons.primary(ZayAssets.googleIcon),
                    const SizedBox(width: 20),
                    SocialButtons.primary(ZayAssets.facebookIcon),
                  ],
                ),
                const SizedBox(height: 30),

                // Sign Up Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don’t have an account? ",
                              style: ZayTheme.lightTheme.textTheme.displayLarge,
                            ),
                            TextSpan(
                              text: "Sign Up",
                              style: ZayTheme.lightTheme.textTheme.displayLarge
                                  ?.copyWith(color: ZayColors.primary),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      ZayRouter.goto(ZayRoutes.register);
                                    },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for social icons
}
