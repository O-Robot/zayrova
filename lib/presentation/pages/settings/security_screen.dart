import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/profile/profile_components.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool faceId = true;
  bool rememberPassword = true;
  bool touchId = true;

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Security',
      showMenu: false,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: ZayColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ZayColors.inputBorder),
          ),
          child: Column(
            children: [
              _SecurityToggle(
                title: 'Face ID',
                value: faceId,
                onChanged: (value) => setState(() => faceId = value),
              ),
              const Divider(height: 1, color: ZayColors.cancel),
              _SecurityToggle(
                title: 'Remember Password',
                value: rememberPassword,
                onChanged: (value) {
                  setState(() => rememberPassword = value);
                },
              ),
              const Divider(height: 1, color: ZayColors.cancel),
              _SecurityToggle(
                title: 'Touch ID',
                value: touchId,
                onChanged: (value) => setState(() => touchId = value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SecurityToggle extends StatelessWidget {
  const _SecurityToggle({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: ZayColors.white,
            activeTrackColor: ZayColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
