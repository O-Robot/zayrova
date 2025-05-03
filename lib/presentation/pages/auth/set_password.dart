import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';
import 'package:zayrova/presentation/widgets/input.dart';

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
                    'New Password',
                    style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: ZayColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    'Your new password must be different from previously used passwords',
                    textAlign: TextAlign.center,
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(color: ZayColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 40),

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

                const SizedBox(height: 5),
                ZayTextInput.primary(
                  "Confirm Password",
                  controller: confirmPassword,
                  password: !showConfirmPassword,
                  margin: EdgeInsets.only(bottom: 2),
                  trailingIcon:
                      showConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                  onTrailingIconTap: () {
                    setState(() {
                      showConfirmPassword = !showConfirmPassword;
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: ZayButton.primary(
                    action: () {},
                    text: 'Create New Password',
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
                              text: "Remembered Password? ",
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
