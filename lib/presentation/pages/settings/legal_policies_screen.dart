import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/pages/profile/profile_components.dart';

class LegalPoliciesScreen extends StatelessWidget {
  const LegalPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfilePageShell(
      title: 'Legal and Policies',
      showMenu: false,
      children: [
        _LegalSection(
          title: 'Terms',
          body:
              'These terms describe how customers may use Zayrova commerce experiences, manage account details, browse products, and place orders. Availability, pricing, and checkout services may change over time.',
        ),
        const SizedBox(height: 22),
        _LegalSection(
          title: 'Changes to the Service and/or Terms:',
          body:
              'Zayrova may update screens, features, payment options, profile settings, and legal text as the service evolves. Continued use of the app after changes means the updated terms apply.',
        ),
        const SizedBox(height: 22),
        _LegalSection(
          title: 'Privacy',
          body:
              'Profile, address, payment method, order, and notification data should be handled with care and protected through appropriate account and payment safeguards.',
        ),
      ],
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          body,
          style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
            color: ZayColors.textSecondary,
            height: 1.75,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
