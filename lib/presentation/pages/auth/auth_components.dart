import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.showBackButton = false,
    this.centerContent = false,
  });

  final List<Widget> children;
  final bool showBackButton;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).vertical -
                  52,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: centerContent
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (showBackButton) ...[
                  const AuthBackButton(),
                  const SizedBox(height: 34),
                ] else
                  const SizedBox(height: 28),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ZayRouter.goBack(),
      behavior: HitTestBehavior.opaque,
      child: const SizedBox(
        width: 42,
        height: 42,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.arrow_back,
            color: ZayColors.textPrimary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class AuthCenteredHeader extends StatelessWidget {
  const AuthCenteredHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 12),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
            color: ZayColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.icon,
    this.trailingIcon,
    this.onTrailingTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: const Color(0xFFA8B0C6),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: icon == null
                ? null
                : Icon(icon, color: ZayColors.primary, size: 24),
            suffixIcon: trailingIcon == null
                ? null
                : IconButton(
                    onPressed: onTrailingTap,
                    icon: Icon(
                      trailingIcon,
                      color: const Color(0xFFA8B0C6),
                      size: 24,
                    ),
                  ),
            filled: true,
            fillColor: const Color(0xFFFBFBFD),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFF0F1F6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: ZayColors.primary,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.action,
    this.isDisabled = false,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback action;
  final bool isDisabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ZayButton.primary(
      action: action,
      text: text,
      fullWidth: true,
      isDisabled: isDisabled,
      isLoading: isLoading,
    );
  }
}

class AuthSocialButton extends StatelessWidget {
  const AuthSocialButton({
    super.key,
    required this.assetPath,
    required this.text,
    this.onTap,
  });

  final String assetPath;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Social authentication is coming soon.'),
                backgroundColor: ZayColors.primary,
              ),
            );
          },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: ZayColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFEDEEF4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(assetPath, width: 26, height: 26),
            const SizedBox(width: 14),
            Text(
              text,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthDividerLabel extends StatelessWidget {
  const AuthDividerLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
          color: ZayColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prefix,
    required this.actionText,
    required this.onTap,
  });

  final String prefix;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: prefix,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textSecondary,
              ),
            ),
            TextSpan(
              text: actionText,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.primary,
                fontWeight: FontWeight.w800,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class AuthVerificationIcon extends StatelessWidget {
  const AuthVerificationIcon({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: ZayColors.primary.withAlpha(24),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: ZayColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ZayColors.white, size: 38),
          ),
        ),
      ),
    );
  }
}
