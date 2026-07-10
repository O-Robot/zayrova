import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/user_profile_entity.dart';
import 'package:zayrova/presentation/components/bottom_navigation.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/pages/profile/profile_components.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: ZayColors.white,
        body: LoadingStateWidget(message: 'Loading profile...'),
        bottomNavigationBar: BottomNavigation(),
      );
    }

    if (authState.hasError && authState.currentUser == null) {
      return Scaffold(
        backgroundColor: ZayColors.white,
        body: ErrorStateWidget(
          title: 'Profile unavailable',
          message: authState.errorMessage ?? 'Unable to load profile.',
        ),
        bottomNavigationBar: const BottomNavigation(),
      );
    }

    final user = authState.currentUser;

    return Scaffold(
      backgroundColor: ZayColors.white,
      bottomNavigationBar: const BottomNavigation(),
      body: SafeArea(
        child: user == null ? const _SignedOutProfile() : _ProfileBody(user: user),
      ),
    );
  }
}

class _SignedOutProfile extends StatelessWidget {
  const _SignedOutProfile();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProfileHeader(
          title: 'My Profile',
          showBack: false,
          showMenu: false,
        ),
        Expanded(
          child: EmptyStateWidget(
            icon: Icons.person_outline,
            title: 'No profile loaded',
            message: 'Sign in to view your account details and settings.',
            actionText: 'Sign In',
            onAction: () => ZayRouter.goto(ZayRoutes.login),
          ),
        ),
      ],
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProfileHeader(
          title: 'My Profile',
          showBack: false,
          showMenu: false,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
            child: Column(
              children: [
                ProfileAvatar(imageUrl: user.avatarUrl, size: 116),
                const SizedBox(height: 18),
                Text(
                  user.displayName,
                  textAlign: TextAlign.center,
                  style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email ?? user.phoneNumber ?? 'Account details unavailable',
                  textAlign: TextAlign.center,
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                ProfileActionRow(
                  title: 'Edit Profile',
                  icon: Icons.person_outline,
                  onTap: () => ZayRouter.goto(ZayRoutes.editProfile),
                ),
                const SizedBox(height: 14),
                ProfileActionRow(
                  title: 'My Order',
                  assetIcon: ZayIcons.orderIcon,
                  onTap: () => ZayRouter.goto(ZayRoutes.orders),
                ),
                const SizedBox(height: 14),
                ProfileActionRow(
                  title: 'Address',
                  icon: Icons.location_on_outlined,
                  onTap: () => ZayRouter.goto(ZayRoutes.address),
                ),
                const SizedBox(height: 14),
                ProfileActionRow(
                  title: 'Payment Method',
                  icon: Icons.credit_card_outlined,
                  onTap: () => ZayRouter.goto(ZayRoutes.changePaymentMethod),
                ),
                const SizedBox(height: 14),
                ProfileActionRow(
                  title: 'Notifications',
                  icon: Icons.notifications_none,
                  onTap: () => ZayRouter.goto(ZayRoutes.notifications),
                ),
                const SizedBox(height: 14),
                ProfileActionRow(
                  title: 'Messages',
                  icon: Icons.chat_bubble_outline,
                  onTap: () => ZayRouter.goto(ZayRoutes.messages),
                ),
                const SizedBox(height: 14),
                ProfileActionRow(
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  onTap: () => ZayRouter.goto(ZayRoutes.settings),
                ),
                const SizedBox(height: 14),
                ProfileActionRow(
                  title: 'Help & Support',
                  icon: Icons.help_outline,
                  onTap: () => ZayRouter.goto(ZayRoutes.helpSupport),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
