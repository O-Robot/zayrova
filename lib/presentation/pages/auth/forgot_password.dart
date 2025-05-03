import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';
import 'package:zayrova/presentation/widgets/input.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController email = TextEditingController();

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
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ZayRouter.goBack();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ZayColors.textSecondary),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: ZayColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                Center(
                  child: Text(
                    'Forgot Password',
                    style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: ZayColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    'Please enter the  email connected to your account to receive reset information',
                    textAlign: TextAlign.center,
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(color: ZayColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 40),

                // Email Input
                ZayTextInput.primary("Email", controller: email),

                const SizedBox(height: 20),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ZayButton.primary(
                    action: () {
                      ZayRouter.goto(ZayRoutes.verifyEmail);
                    },
                    text: 'Send Email',
                  ),
                ),
                const SizedBox(height: 30),

                // Sign In Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Remembered password? ",
                              style: ZayTheme.lightTheme.textTheme.displayLarge,
                            ),
                            TextSpan(
                              text: "Sign In",
                              style: ZayTheme.lightTheme.textTheme.displayLarge
                                  ?.copyWith(color: ZayColors.primary),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      ZayRouter.goto(ZayRoutes.login);
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
}
