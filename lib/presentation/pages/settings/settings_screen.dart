import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/presentation/pages/profile/profile_components.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: ZayColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Are you sure you want to\nlogout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ZayColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 28),
                ZayButton.primary(
                  action: () => Navigator.of(context).pop(),
                  text: 'Cancel',
                  fullWidth: true,
                  compact: true,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await ref.read(authControllerProvider.notifier).logout();

                    if (context.mounted) {
                      final error =
                          ref.read(authControllerProvider).errorMessage;

                      if (error != null && error.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: ZayColors.primary,
                          ),
                        );
                      }
                    }

                    ZayRouter.exit(ZayRoutes.login);
                  },
                  child: const Text(
                    'Log Out',
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProfilePageShell(
      title: 'Settings',
      children: [
        const ProfileSectionTitle(title: 'General'),
        const SizedBox(height: 18),
        ProfileActionRow(
          title: 'Edit Profile',
          icon: Icons.person_outline,
          onTap: () => ZayRouter.goto(ZayRoutes.editProfile),
        ),
        const SizedBox(height: 14),
        ProfileActionRow(
          title: 'Change Password',
          icon: Icons.lock_outline,
          onTap: () => ZayRouter.goto(ZayRoutes.changePassword),
        ),
        const SizedBox(height: 14),
        ProfileActionRow(
          title: 'Notifications',
          icon: Icons.notifications_none,
          onTap: () => ZayRouter.goto(ZayRoutes.notifications),
        ),
        const SizedBox(height: 14),
        ProfileActionRow(
          title: 'Security',
          icon: Icons.security_outlined,
          onTap: () => ZayRouter.goto(ZayRoutes.security),
        ),
        const SizedBox(height: 14),
        ProfileActionRow(
          title: 'Language',
          icon: Icons.language,
          trailingText: 'English',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Language settings are unavailable right now.'),
              ),
            );
          },
        ),
        const SizedBox(height: 28),
        const ProfileSectionTitle(title: 'Preferences'),
        const SizedBox(height: 18),
        ProfileActionRow(
          title: 'Legal and Policies',
          icon: Icons.shield_outlined,
          onTap: () => ZayRouter.goto(ZayRoutes.legalAndPolicies),
        ),
        const SizedBox(height: 14),
        ProfileActionRow(
          title: 'Help & Support',
          icon: Icons.help_outline,
          onTap: () => ZayRouter.goto(ZayRoutes.helpSupport),
        ),
        const SizedBox(height: 14),
        ProfileActionRow(
          title: 'Logout',
          icon: Icons.logout,
          isDestructive: true,
          onTap: () => _showLogoutDialog(context, ref),
        ),
      ],
    );
  }
}
