import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/cart_entity.dart';
import 'package:zayrova/domain/entities/cart_item_entity.dart';
import 'package:zayrova/presentation/components/top_navigation.dart';
import 'package:zayrova/presentation/providers/feature/cart_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const double _deliveryFeePlaceholder = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCartIfNeeded());
  }

  Future<void> _loadCartIfNeeded() async {
    final cartState = ref.read(cartControllerProvider);
    if (cartState.hasLoadedUserCart || cartState.isLoading) {
      return;
    }

    await ref
        .read(cartControllerProvider.notifier)
        .loadUserCart(temporaryDummyJsonCartUserId);
  }

  Future<void> _reloadCart() {
    return ref
        .read(cartControllerProvider.notifier)
        .loadUserCart(temporaryDummyJsonCartUserId);
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final cart = cartState.userCart;

    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TopNavigation(text: 'Payment'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _CheckoutBody(
                state: cartState,
                cart: cart,
                deliveryFee: _deliveryFeePlaceholder,
                onRetry: _reloadCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutBody extends StatelessWidget {
  const _CheckoutBody({
    required this.state,
    required this.cart,
    required this.deliveryFee,
    required this.onRetry,
  });

  final CartState state;
  final Cart? cart;
  final double deliveryFee;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasLoadedUserCart) {
      return const _CheckoutLoadingState();
    }

    if (state.hasError && !state.hasLoadedUserCart) {
      return _CheckoutErrorState(
        message: state.errorMessage ?? 'Unable to load checkout.',
        onRetry: onRetry,
      );
    }

    final checkoutCart = cart;

    if (checkoutCart == null || checkoutCart.isEmpty) {
      return const _CheckoutMessageState(
        icon: Icons.shopping_cart_outlined,
        message: 'Your cart is empty.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasError)
            _InlineCheckoutError(
              message: state.errorMessage ?? 'Unable to refresh checkout.',
              onRetry: onRetry,
            ),
          _CheckoutSection(
            title: 'Cart Summary',
            actionText: '${checkoutCart.totalQuantity} items',
            child: Column(
              children: checkoutCart.items.map((item) {
                return _CheckoutItemSummary(item: item);
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _CheckoutNavigationTile(
            icon: Icons.location_on_outlined,
            title: 'Delivery Address',
            subtitle: 'Select a delivery address',
            onTap: () => ZayRouter.goto(ZayRoutes.address),
          ),
          const SizedBox(height: 12),
          _CheckoutNavigationTile(
            icon: Icons.credit_card_outlined,
            title: 'Payment Method',
            subtitle: 'Choose a payment method',
            onTap: () => ZayRouter.goto(ZayRoutes.changePaymentMethod),
          ),
          const SizedBox(height: 16),
          _CheckoutTotals(cart: checkoutCart, deliveryFee: deliveryFee),
          const SizedBox(height: 20),
          Center(
            child: ZayButton.primary(
              // Temporary UI-only flow until order creation and payment gateway
              // integration are connected.
              action: () => ZayRouter.goto(ZayRoutes.paymentSuccess),
              text: 'Pay Now',
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => ZayRouter.goto(ZayRoutes.paymentFailed),
              child: Text(
                'Preview failed payment',
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutSection extends StatelessWidget {
  const _CheckoutSection({
    required this.title,
    required this.child,
    this.actionText,
  });

  final String title;
  final String? actionText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZayColors.white,
        border: Border.all(color: ZayColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actionText != null)
                Text(
                  actionText!,
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _CheckoutItemSummary extends StatelessWidget {
  const _CheckoutItemSummary({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.product.thumbnailUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 56,
              height: 56,
              child: imageUrl == null || imageUrl.isEmpty
                  ? const _CheckoutImageFallback()
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const _CheckoutImageFallback();
                      },
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty ${item.quantity}',
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutNavigationTile extends StatelessWidget {
  const _CheckoutNavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ZayColors.cancel,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: ZayColors.primary, size: 24),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: ZayTheme.lightTheme.textTheme.displayMedium
                        ?.copyWith(color: ZayColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: ZayColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutTotals extends StatelessWidget {
  const _CheckoutTotals({
    required this.cart,
    required this.deliveryFee,
  });

  final Cart cart;
  final double deliveryFee;

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        cart.discountedTotal > 0 && cart.discountedTotal < cart.total;
    final discount = hasDiscount ? cart.total - cart.discountedTotal : 0.0;
    final orderTotal =
        (hasDiscount ? cart.discountedTotal : cart.total) + deliveryFee;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZayColors.cancel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _TotalRow(label: 'Subtotal', value: cart.total),
          const SizedBox(height: 10),
          _TotalRow(label: 'Discount', value: discount),
          const SizedBox(height: 10),
          _TotalRow(label: 'Delivery Fee', value: deliveryFee),
          const Divider(height: 24, color: ZayColors.inputBorder),
          _TotalRow(
            label: 'Total',
            value: orderTotal,
            isEmphasized: true,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final double value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final textStyle = isEmphasized
        ? ZayTheme.lightTheme.textTheme.displayLarge
        : ZayTheme.lightTheme.textTheme.displayMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textStyle?.copyWith(
            color: isEmphasized
                ? ZayColors.textPrimary
                : ZayColors.textSecondary,
            fontWeight: isEmphasized ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: textStyle?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: isEmphasized ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InlineCheckoutError extends StatelessWidget {
  const _InlineCheckoutError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ZayColors.cancel,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => onRetry(),
              child: Text(
                'Retry',
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutLoadingState extends StatelessWidget {
  const _CheckoutLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: ZayColors.primary),
    );
  }
}

class _CheckoutErrorState extends StatelessWidget {
  const _CheckoutErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: ZayColors.primary,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayLarge,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => onRetry(),
              child: Text(
                'Retry',
                style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                  color: ZayColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutMessageState extends StatelessWidget {
  const _CheckoutMessageState({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: ZayColors.primary, size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutImageFallback extends StatelessWidget {
  const _CheckoutImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ZayColors.cancel,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: ZayColors.textSecondary,
        ),
      ),
    );
  }
}
