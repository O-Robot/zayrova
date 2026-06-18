import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PaymentResultScaffold(
      title: 'Order Successfully',
      message:
          'Your order will be packed and prepared for delivery. Tracking will become available once order creation is connected.',
      referenceLabel: 'Temporary reference: pending order creation',
      visual: _PaymentResultVisual.success(),
      primaryText: 'View Order',
      secondaryText: 'Continue Shopping',
      primaryRoute: ZayRoutes.orders,
      secondaryRoute: ZayRoutes.home,
    );
  }
}

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PaymentResultScaffold(
      title: 'Payment Failed',
      message:
          'We could not complete your payment. Please check your payment method and try again.',
      referenceLabel: 'Temporary reference: no order created',
      visual: _PaymentResultVisual.failed(),
      primaryText: 'Retry Payment',
      secondaryText: 'Continue Shopping',
      primaryRoute: ZayRoutes.checkout,
      secondaryRoute: ZayRoutes.home,
    );
  }
}

class _PaymentResultScaffold extends StatelessWidget {
  const _PaymentResultScaffold({
    required this.title,
    required this.message,
    required this.referenceLabel,
    required this.visual,
    required this.primaryText,
    required this.secondaryText,
    required this.primaryRoute,
    required this.secondaryRoute,
  });

  final String title;
  final String message;
  final String referenceLabel;
  final Widget visual;
  final String primaryText;
  final String secondaryText;
  final String primaryRoute;
  final String secondaryRoute;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E9),
      body: SafeArea(
        child: Column(
          children: [
            const _PaymentResultHeader(),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 560),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  decoration: const BoxDecoration(
                    color: ZayColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(36),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE4E6EE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 70),
                        visual,
                        const SizedBox(height: 42),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: ZayTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            color: ZayColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: ZayTheme.lightTheme.textTheme.displayLarge
                              ?.copyWith(
                            color: ZayColors.textSecondary,
                            height: 1.65,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Temporary until checkout creates a persisted order
                        // and backend transaction reference.
                        _ReferencePill(label: referenceLabel),
                        const SizedBox(height: 58),
                        ZayButton.primary(
                          action: () => ZayRouter.goto(primaryRoute),
                          text: primaryText,
                          fullWidth: true,
                        ),
                        const SizedBox(height: 14),
                        ZayButton.outline(
                          action: () => ZayRouter.goto(secondaryRoute),
                          text: secondaryText,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentResultHeader extends StatelessWidget {
  const _PaymentResultHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ZayRouter.goBack(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.chevron_left,
                  color: ZayColors.textPrimary,
                  size: 36,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Payment',
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }
}

class _PaymentResultVisual extends StatelessWidget {
  const _PaymentResultVisual.success()
      : icon = Icons.check,
        iconColor = ZayColors.white,
        backgroundColor = const Color(0xFF12D86E),
        haloColor = const Color(0xFFDDFBEA);

  const _PaymentResultVisual.failed()
      : icon = Icons.close,
        iconColor = ZayColors.white,
        backgroundColor = const Color(0xFFE53935),
        haloColor = const Color(0xFFFFE5E5);

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color haloColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176,
      height: 176,
      decoration: BoxDecoration(
        color: haloColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 58),
        ),
      ),
    );
  }
}

class _ReferencePill extends StatelessWidget {
  const _ReferencePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFD),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEEF4)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
          color: ZayColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
