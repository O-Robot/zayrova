import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/payment_method_entity.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/providers/feature/payment_method_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class PaymentMethodListScreen extends ConsumerWidget {
  const PaymentMethodListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentState = ref.watch(paymentMethodControllerProvider);
    final methods = paymentState.methods;

    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopNavigation(text: 'Payment Method'),
              const SizedBox(height: 24),
              Expanded(
                child: methods.isEmpty
                    ? const _PaymentEmptyState()
                    : ListView.separated(
                        itemCount: methods.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final method = methods[index];
                          final isSelected =
                              paymentState.selectedMethod?.id == method.id;

                          return _PaymentMethodCard(
                            method: method,
                            isSelected: isSelected,
                            onSelect: () {
                              ref
                                  .read(
                                    paymentMethodControllerProvider.notifier,
                                  )
                                  .selectMethod(method.id);
                              ZayRouter.goBack();
                            },
                            onMakeDefault: () {
                              ref
                                  .read(
                                    paymentMethodControllerProvider.notifier,
                                  )
                                  .setDefaultMethod(method.id);
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ZayButton.primary(
                  action: () => ZayRouter.goto(ZayRoutes.addPaymentMethod),
                  text: 'Add New Card',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.isSelected,
    required this.onSelect,
    required this.onMakeDefault,
  });

  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onMakeDefault;

  @override
  Widget build(BuildContext context) {
    final lastFour = method.lastFourDigits ?? '----';
    final expiry = method.expiryMonth != null && method.expiryYear != null
        ? '${method.expiryMonth.toString().padLeft(2, '0')}/${method.expiryYear}'
        : method.subtitle;

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
                          method.cardBrand ?? method.title,
                          style: ZayTheme.lightTheme.textTheme.displayLarge
                              ?.copyWith(
                            color: ZayColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (method.isDefault)
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
                    '•••• •••• •••• $lastFour',
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(color: ZayColors.textPrimary),
                  ),
                  if (expiry != null && expiry.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Expires $expiry',
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
                          'Use Card',
                          style: ZayTheme.lightTheme.textTheme.displayMedium
                              ?.copyWith(
                            color: ZayColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!method.isDefault)
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
            const SizedBox(width: 8),
            const Icon(Icons.credit_card, color: ZayColors.primary),
          ],
        ),
      ),
    );
  }
}

class _PaymentEmptyState extends StatelessWidget {
  const _PaymentEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.credit_card_outlined,
              color: ZayColors.primary,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              'No payment method saved yet.',
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a card to use during checkout.',
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
