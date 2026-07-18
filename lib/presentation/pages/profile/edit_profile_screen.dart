import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/pages/auth/auth_components.dart';
import 'package:zayrova/presentation/pages/profile/profile_components.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  String? selectedAvatarPath;
  String? formError;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).currentUser;
    firstNameController = TextEditingController(text: user?.firstName ?? '');
    lastNameController = TextEditingController(text: user?.lastName ?? '');
    usernameController = TextEditingController(text: user?.username ?? '');
    emailController = TextEditingController(text: user?.email ?? '');
    selectedAvatarPath = user?.avatarUrl;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = ref.read(authControllerProvider).currentUser;
    if (user == null) {
      setState(() => formError = 'Sign in before editing profile details.');
      return;
    }

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        email.isEmpty) {
      setState(
        () =>
            formError =
                'First name, last name, username, and email are required.',
      );
      return;
    }

    setState(() => formError = null);

    final fullName = '$firstName $lastName'.trim();
    final updatedUser = user.copyWith(
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      username: username,
      email: email,
      avatarUrl: selectedAvatarPath,
    );

    await ref
        .read(authControllerProvider.notifier)
        .updateLocalProfile(updatedUser);

    if (!mounted) {
      return;
    }

    final error = ref.read(authControllerProvider).errorMessage;
    if (error != null && error.isNotEmpty) {
      setState(() => formError = error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: ZayColors.primary),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated for this session.'),
        backgroundColor: ZayColors.primary,
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final user = ref.read(authControllerProvider).currentUser;
    if (user == null) {
      setState(() => formError = 'Sign in before editing profile details.');
      return;
    }

    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) {
      return;
    }

    final updatedUser = user.copyWith(avatarUrl: pickedFile.path);

    setState(() {
      selectedAvatarPath = pickedFile.path;
      formError = null;
    });

    await ref
        .read(authControllerProvider.notifier)
        .updateLocalProfile(updatedUser);

    if (!mounted) {
      return;
    }

    final error = ref.read(authControllerProvider).errorMessage;
    if (error != null && error.isNotEmpty) {
      setState(() => formError = error);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture updated for this session.'),
        backgroundColor: ZayColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.currentUser;

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
      bottom: _SaveBar(onSave: _saveProfile, isSaving: authState.isLoading),
      children: [
        Center(
          child: ProfileAvatar(
            imageUrl: selectedAvatarPath ?? user.avatarUrl,
            size: 104,
            showEditBadge: true,
            onTap: _pickProfileImage,
          ),
        ),
        const SizedBox(height: 34),
        AuthField(
          label: 'First Name',
          hint: 'Enter your first name',
          controller: firstNameController,
          icon: Icons.person_outline,
          onChanged: (_) {
            if (formError != null) {
              setState(() => formError = null);
            }
          },
        ),
        const SizedBox(height: 24),
        AuthField(
          label: 'Last Name',
          hint: 'Enter your last name',
          controller: lastNameController,
          icon: Icons.person_outline,
          onChanged: (_) {
            if (formError != null) {
              setState(() => formError = null);
            }
          },
        ),
        const SizedBox(height: 24),
        AuthField(
          label: 'Username',
          hint: 'Enter your username',
          controller: usernameController,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.text,
          onChanged: (_) {
            if (formError != null) {
              setState(() => formError = null);
            }
          },
        ),
        const SizedBox(height: 24),
        AuthField(
          label: 'Email',
          hint: 'Enter your email',
          controller: emailController,
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) {
            if (formError != null) {
              setState(() => formError = null);
            }
          },
        ),
        if (formError != null) ...[
          const SizedBox(height: 12),
          Text(
            formError!,
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: const Color(0xFFE53935),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 24),
        ProfileSectionTitle(title: 'Account Linked With'),
        const SizedBox(height: 12),
        ProfileActionRow(
          title: 'Google',
          icon: Icons.g_mobiledata,
          trailingText: '',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Social account linking is unavailable right now.',
                ),
                backgroundColor: ZayColors.primary,
              ),
            );
          },
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.onSave, required this.isSaving});

  final VoidCallback onSave;
  final bool isSaving;

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
          isLoading: isSaving,
        ),
      ),
    );
  }
}
