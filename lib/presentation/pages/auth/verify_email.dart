import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';
import 'package:zayrova/presentation/widgets/input.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              // Back Button
              GestureDetector(
                onTap: () => ZayRouter.goBack(),
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

              const SizedBox(height: 30),

              // Title and Subtitle
              Center(
                child: Column(
                  children: [
                    Text(
                      'Verify Code',
                      style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: ZayColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Please enter the code we just sent to your email',
                      textAlign: TextAlign.center,
                      style: ZayTheme.lightTheme.textTheme.displayMedium
                          ?.copyWith(color: ZayColors.textSecondary),
                    ),
                    Text(
                      'example@email.com',
                      style: ZayTheme.lightTheme.textTheme.displayMedium
                          ?.copyWith(color: ZayColors.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // OTP Inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 60,
                    child: TextField(
                      controller: otpControllers[index],
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          FocusScope.of(context).nextFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),

              // Resend Code
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Didn't receive OTP? ",
                        style: ZayTheme.lightTheme.textTheme.displayLarge,
                      ),
                      TextSpan(
                        text: "Resend code",
                        style: ZayTheme.lightTheme.textTheme.displayLarge
                            ?.copyWith(color: ZayColors.primary),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                // Handle resend OTP
                              },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ZayButton.primary(
                  text: 'Verify',
                  action: () {
                    // Combine OTP and verify
                    final code = otpControllers.map((e) => e.text).join();
                    // Handle verification
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
