import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';

class ProfilePageShell extends StatelessWidget {
  const ProfilePageShell({
    super.key,
    required this.title,
    required this.children,
    this.showMenu = true,
    this.bottom,
  });

  final String title;
  final List<Widget> children;
  final bool showMenu;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZayColors.white,
      bottomNavigationBar: bottom,
      body: SafeArea(
        child: Column(
          children: [
            ProfileHeader(title: title, showMenu: showMenu),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.title,
    this.showMenu = true,
    this.showBack = true,
  });

  final String title;
  final bool showMenu;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: ZayColors.white,
        border: Border(bottom: BorderSide(color: ZayColors.cancel)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child:
                showBack
                    ? GestureDetector(
                      onTap: () => ZayRouter.goBack(),
                      behavior: HitTestBehavior.opaque,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.arrow_back,
                          color: ZayColors.textPrimary,
                          size: 24,
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            width: 42,
            height: 42,
            child:
                showMenu
                    ? const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.more_vert,
                        color: ZayColors.textPrimary,
                        size: 24,
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        color: ZayColors.textPrimary,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class ProfileActionRow extends StatelessWidget {
  const ProfileActionRow({
    super.key,
    required this.title,
    this.icon,
    this.assetIcon,
    this.subtitle,
    this.trailingText,
    this.onTap,
    this.isDestructive = false,
  }) : assert(
         icon != null || assetIcon != null,
         'Either icon or assetIcon must be provided.',
       );

  final String title;
  final IconData? icon;
  final String? assetIcon;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? const Color(0xFFE53935) : ZayColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: ZayColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            assetIcon != null
                ? SizedBox(
                  width: 24,
                  height: 24,
                  child: SvgPicture.asset(
                    assetIcon!,
                    colorFilter: ColorFilter.mode(
                      isDestructive ? color : ZayColors.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                )
                : Icon(
                  icon,
                  color: isDestructive ? color : ZayColors.textPrimary,
                ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(
                          color: isDestructive ? color : ZayColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: ZayTheme.lightTheme.textTheme.displaySmall
                          ?.copyWith(
                            color: ZayColors.textSecondary,
                            height: 1.35,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
            ],
            if (!isDestructive)
              const Icon(Icons.chevron_right, color: ZayColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 104,
    this.showEditBadge = false,
    this.onTap,
  });

  final String? imageUrl;
  final double size;
  final bool showEditBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageProvider = profileImageProvider(imageUrl);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: ZayColors.cancel,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child:
                imageProvider == null
                    ? Icon(
                      Icons.person,
                      color: ZayColors.textSecondary,
                      size: size * .46,
                    )
                    : Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Icon(
                          Icons.person,
                          color: ZayColors.textSecondary,
                          size: size * .46,
                        );
                      },
                    ),
          ),
          if (showEditBadge)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: ZayColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: ZayColors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

ImageProvider<Object>? profileImageProvider(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) {
    return null;
  }

  if (kIsWeb) {
    return NetworkImage(imageUrl);
  }

  final uri = Uri.tryParse(imageUrl);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return NetworkImage(imageUrl);
  }

  if (uri != null && uri.scheme == 'file') {
    return FileImage(File.fromUri(uri));
  }

  return FileImage(File(imageUrl));
}

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.icon,
    this.trailingIcon,
    this.onTrailingTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final bool obscureText;
  final TextInputType keyboardType;

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
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                icon == null
                    ? null
                    : Icon(icon, color: ZayColors.primary, size: 24),
            suffixIcon:
                trailingIcon == null
                    ? null
                    : IconButton(
                      onPressed: onTrailingTap,
                      icon: Icon(
                        trailingIcon,
                        color: ZayColors.textSecondary,
                        size: 24,
                      ),
                    ),
            filled: true,
            fillColor: ZayColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
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
