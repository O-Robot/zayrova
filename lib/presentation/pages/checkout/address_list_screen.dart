import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/providers/feature/address_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressControllerProvider);
    final addresses = addressState.addresses;

    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopNavigation(text: 'Address'),
              const SizedBox(height: 24),
              Expanded(
                child: addresses.isEmpty
                    ? const _AddressEmptyState()
                    : ListView.separated(
                        itemCount: addresses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          final isSelected =
                              addressState.selectedAddress?.id == address.id;

                          return _AddressCard(
                            address: address,
                            isSelected: isSelected,
                            onSelect: () {
                              ref
                                  .read(addressControllerProvider.notifier)
                                  .selectAddress(address.id);
                              ZayRouter.goBack();
                            },
                            onMakeDefault: () {
                              ref
                                  .read(addressControllerProvider.notifier)
                                  .setDefaultAddress(address.id);
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ZayButton.primary(
                  action: () => ZayRouter.goto(ZayRoutes.addAddress),
                  text: 'Add New Address',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isSelected,
    required this.onSelect,
    required this.onMakeDefault,
  });

  final Address address;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onMakeDefault;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? ZayColors.primary : ZayColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          address.recipientName ?? address.label,
                          style: ZayTheme.lightTheme.textTheme.displayLarge
                              ?.copyWith(
                                color: ZayColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (address.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ZayColors.primary.withAlpha(24),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Default',
                            style: ZayTheme.lightTheme.textTheme.displayMedium
                                ?.copyWith(color: ZayColors.primary),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    address.formattedAddress,
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(color: ZayColors.textSecondary),
                  ),
                  if (address.phoneNumber != null &&
                      address.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      address.phoneNumber!,
                      style: ZayTheme.lightTheme.textTheme.displayMedium
                          ?.copyWith(color: ZayColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton(
                        onPressed: onSelect,
                        child: Text(
                          'Use Address',
                          style: ZayTheme.lightTheme.textTheme.displayMedium
                              ?.copyWith(
                                color: ZayColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (!address.isDefault)
                        TextButton(
                          onPressed: onMakeDefault,
                          child: Text(
                            'Set Default',
                            style: ZayTheme.lightTheme.textTheme.displayMedium
                                ?.copyWith(color: ZayColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressEmptyState extends StatelessWidget {
  const _AddressEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: ZayColors.primary,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              'No address saved yet.',
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a delivery address to use during checkout.',
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
