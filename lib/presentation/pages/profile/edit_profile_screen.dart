import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/pages/profile/profile_components.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).currentUser;
    nameController = TextEditingController(text: user?.displayName ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _showDeferredSaveMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile saving will be connected with profile APIs.'),
        backgroundColor: ZayColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).currentUser;

    if (user == null) {
      return const ProfilePageShell(
        title: 'Edit Profile',
        children: [
          SizedBox(height: 120),
          EmptyStateWidget(
            icon: Icons.person_outline,
            title: 'No profile loaded',
            message: 'Sign in before editing profile details.',
          ),
        ],
      );
    }

    return ProfilePageShell(
      title: 'Edit Profile',
      bottom: _SaveBar(onSave: _showDeferredSaveMessage),
      children: [
        Center(
          child: ProfileAvatar(
            imageUrl: user.avatarUrl,
            size: 104,
            showEditBadge: true,
          ),
        ),
        const SizedBox(height: 34),
        ProfileTextField(
          label: 'Username',
          hint: 'Enter your username',
          controller: nameController,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 24),
        ProfileTextField(
          label: 'Email or Phone Number',
          hint: 'Enter your email or phone number',
          controller: emailController,
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        ProfileSectionTitle(title: 'Account Linked With'),
        const SizedBox(height: 12),
        ProfileActionRow(
          title: 'Google',
          icon: Icons.g_mobiledata,
          trailingText: '',
          onTap: () {},
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
      decoration: BoxDecoration(
        color: ZayColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ZayButton.primary(
          action: onSave,
          text: 'Save Changes',
          fullWidth: true,
        ),
      ),
    );
  }
}
