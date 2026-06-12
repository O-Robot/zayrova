import 'package:flutter/gestures.dart';
// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to all controllers to check if button should be enabled
    for (var controller in otpControllers) {
      controller.addListener(_checkIfComplete);
    }

    // Focus on first field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(focusNodes[0]);
      }
    });
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // Check if all fields are filled
  void _checkIfComplete() {
    final allFilled = otpControllers.every(
      (controller) => controller.text.isNotEmpty,
    );
    if (allFilled != isButtonEnabled) {
      setState(() {
        isButtonEnabled = allFilled;
      });
    }
  }

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
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 40,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (KeyEvent event) {
                        if (event is KeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.backspace &&
                            otpControllers[index].text.isEmpty &&
                            index > 0) {
                          otpControllers[index - 1].clear();
                          FocusScope.of(
                            context,
                          ).requestFocus(focusNodes[index - 1]);
                        }
                      },
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: focusNodes[index],
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
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: ZayColors.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            FocusScope.of(
                              context,
                            ).requestFocus(focusNodes[index + 1]);
                          }
                        },
                        // Enable paste functionality
                        enableInteractiveSelection: true,
                      ),
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
                  isDisabled: !isButtonEnabled,
                  action: () {
                    final code = otpControllers.map((e) => e.text).join();
                    ZayRouter.goto(ZayRoutes.completeProfile);
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
