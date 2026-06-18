import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/auth/auth_components.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

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
    for (final controller in otpControllers) {
      controller.addListener(_checkIfComplete);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(focusNodes[0]);
      }
    });
  }

  @override
  void dispose() {
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _checkIfComplete() {
    final allFilled = otpControllers.every(
      (controller) => controller.text.isNotEmpty,
    );
    if (allFilled != isButtonEnabled) {
      setState(() => isButtonEnabled = allFilled);
    }
  }

  void _submitCode() {
    if (!isButtonEnabled) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Code accepted. Continue by setting a new password.',
        ),
        backgroundColor: ZayColors.primary,
      ),
    );
    ZayRouter.goto(ZayRoutes.setPassword);
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A new code will be sent if the account is eligible.'),
        backgroundColor: ZayColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      children: [
        const AuthVerificationIcon(icon: Icons.mark_email_unread_outlined),
        const SizedBox(height: 34),
        const AuthCenteredHeader(
          title: 'Verification Code',
          subtitle: 'We have sent the code verification to\nexample@email.com',
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(otpControllers.length, (index) {
            return _OtpField(
              controller: otpControllers[index],
              focusNode: focusNodes[index],
              onChanged: (value) {
                if (value.isNotEmpty && index < focusNodes.length - 1) {
                  FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                }
                if (value.isEmpty && index > 0) {
                  FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                }
              },
            );
          }),
        ),
        const SizedBox(height: 50),
        AuthPrimaryButton(
          text: 'Submit',
          isDisabled: !isButtonEnabled,
          action: _submitCode,
        ),
        const SizedBox(height: 24),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Didn't receive the code? ",
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.textSecondary,
                  ),
                ),
                TextSpan(
                  text: 'Resend',
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _resendCode,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpField extends StatelessWidget {
  const _OtpField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 70,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
          color: ZayColors.textPrimary,
          fontWeight: FontWeight.w900,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFFBFBFD),
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF0F1F6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: ZayColors.primary, width: 1.2),
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        enableInteractiveSelection: true,
      ),
    );
  }
}
