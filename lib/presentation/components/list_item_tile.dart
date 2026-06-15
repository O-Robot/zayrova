import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';

class ZayListItemTile extends StatelessWidget {
  const ZayListItemTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.showChevron = true,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? ZayColors.cancel : ZayColors.white,
          border: Border.all(
            color: isSelected ? ZayColors.primary : ZayColors.inputBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, color: ZayColors.primary, size: 24),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: ZayTheme.lightTheme.textTheme.displayMedium
                          ?.copyWith(color: ZayColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && showChevron)
              const Icon(Icons.chevron_right, color: ZayColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class ProfileSettingsRow extends StatelessWidget {
  const ProfileSettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ZayListItemTile(
      title: title,
      subtitle: subtitle,
      leadingIcon: icon,
      onTap: onTap,
    );
  }
}

class AddressRow extends StatelessWidget {
  const AddressRow({
    super.key,
    required this.title,
    required this.address,
    this.isSelected = false,
    this.onTap,
  });

  final String title;
  final String address;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ZayListItemTile(
      title: title,
      subtitle: address,
      leadingIcon: Icons.location_on_outlined,
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? ZayColors.primary : ZayColors.textSecondary,
      ),
      onTap: onTap,
      isSelected: isSelected,
      showChevron: false,
    );
  }
}

class PaymentMethodRow extends StatelessWidget {
  const PaymentMethodRow({
    super.key,
    required this.title,
    required this.maskedNumber,
    this.isSelected = false,
    this.onTap,
  });

  final String title;
  final String maskedNumber;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ZayListItemTile(
      title: title,
      subtitle: maskedNumber,
      leadingIcon: Icons.credit_card_outlined,
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? ZayColors.primary : ZayColors.textSecondary,
      ),
      onTap: onTap,
      isSelected: isSelected,
      showChevron: false,
    );
  }
}
