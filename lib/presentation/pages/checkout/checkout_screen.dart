import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/domain/entities/cart_entity.dart';
import 'package:zayrova/domain/entities/cart_item_entity.dart';
import 'package:zayrova/domain/entities/payment_method_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/components/zay_network_image.dart';
import 'package:zayrova/presentation/providers/feature/address_controller.dart';
import 'package:zayrova/presentation/providers/feature/cart_controller.dart';
import 'package:zayrova/presentation/providers/feature/order_controller.dart';
import 'package:zayrova/presentation/providers/feature/payment_method_controller.dart';
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

  Future<void> _placeOrder({
    required Cart cart,
    required Address? selectedAddress,
    required PaymentMethod? selectedPaymentMethod,
  }) async {
    if (cart.isEmpty) {
      _showCheckoutMessage('Add items to your cart before checking out.');
      return;
    }

    if (selectedAddress == null) {
      _showCheckoutMessage('Select a delivery address before placing order.');
      return;
    }

    if (selectedPaymentMethod == null) {
      _showCheckoutMessage('Select a payment method before placing order.');
      return;
    }

    final order = await ref.read(orderControllerProvider.notifier).createOrderFromCheckout(
          cart: cart,
          shippingAddress: selectedAddress,
          paymentMethod: selectedPaymentMethod,
          deliveryFee: _deliveryFeePlaceholder,
        );

    if (!mounted) {
      return;
    }

    if (order == null) {
      final message =
          ref.read(orderControllerProvider).errorMessage ?? 'Unable to create order.';
      _showCheckoutMessage(message);
      return;
    }

    ZayRouter.goto(ZayRoutes.paymentSuccess, {
      'orderId': order.id,
      'orderReference': order.orderNumber ?? order.id,
    });
  }

  void _showCheckoutMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: ZayColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final cart = cartState.userCart;
    final selectedAddress = ref.watch(addressControllerProvider).selectedAddress;
    final selectedPaymentMethod =
        ref.watch(paymentMethodControllerProvider).selectedMethod;
    final orderState = ref.watch(orderControllerProvider);

    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const _PaymentHeader(),
            Expanded(
              child: _CheckoutBody(
                state: cartState,
                cart: cart,
                selectedAddress: selectedAddress,
                selectedPaymentMethod: selectedPaymentMethod,
                deliveryFee: _deliveryFeePlaceholder,
                onRetry: _reloadCart,
                isPlacingOrder: orderState.isLoading,
                onPlaceOrder: (checkoutCart) => _placeOrder(
                  cart: checkoutCart,
                  selectedAddress: selectedAddress,
                  selectedPaymentMethod: selectedPaymentMethod,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentHeader extends StatelessWidget {
  const _PaymentHeader();

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
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }
}

class _CheckoutBody extends StatelessWidget {
  const _CheckoutBody({
    required this.state,
    required this.cart,
    required this.selectedAddress,
    required this.selectedPaymentMethod,
    required this.deliveryFee,
    required this.onRetry,
    required this.isPlacingOrder,
    required this.onPlaceOrder,
  });

  final CartState state;
  final Cart? cart;
  final Address? selectedAddress;
  final PaymentMethod? selectedPaymentMethod;
  final double deliveryFee;
  final Future<void> Function() onRetry;
  final bool isPlacingOrder;
  final ValueChanged<Cart> onPlaceOrder;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasLoadedUserCart) {
      return const LoadingStateWidget(message: 'Loading checkout...');
    }

    if (state.hasError && !state.hasLoadedUserCart) {
      return ErrorStateWidget(
        title: 'Checkout unavailable',
        message: state.errorMessage ?? 'Unable to load checkout.',
        onRetry: () => onRetry(),
      );
    }

    final checkoutCart = cart;

    if (checkoutCart == null || checkoutCart.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: 'Cart is empty',
        message: 'Add items to your cart before checking out.',
      );
    }

    final payableTotal = _payableTotal(checkoutCart, deliveryFee);

    return Stack(
      children: [
        RefreshIndicator(
          color: ZayColors.primary,
          onRefresh: onRetry,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.hasError)
                  _InlineCheckoutError(
                    message:
                        state.errorMessage ?? 'Unable to refresh checkout.',
                    onRetry: onRetry,
                  ),
                _AddressSection(address: selectedAddress),
                const SizedBox(height: 34),
                _ProductsSection(cart: checkoutCart),
                const SizedBox(height: 34),
                _PaymentMethodSection(method: selectedPaymentMethod),
                const SizedBox(height: 28),
                _OrderSummarySection(
                  cart: checkoutCart,
                  deliveryFee: deliveryFee,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _CheckoutActionBar(
            total: payableTotal,
            isLoading: isPlacingOrder,
            onCheckout: () => onPlaceOrder(checkoutCart),
          ),
        ),
      ],
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.address});

  final Address? address;

  @override
  Widget build(BuildContext context) {
    final hasAddress = address != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitleRow(
          title: 'Address',
          actionText: hasAddress ? 'Edit' : 'Add',
          onAction: () => ZayRouter.goto(
            hasAddress ? ZayRoutes.address : ZayRoutes.addAddress,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _MapPreview(),
            const SizedBox(width: 22),
            Expanded(
              child: hasAddress
                  ? _SelectedAddressDetails(address: address!)
                  : const _MissingAddressDetails(),
            ),
          ],
        ),
      ],
    );
  }
}

class _MapPreview extends StatelessWidget {
  const _MapPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F4),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _MapPreviewPainter(),
        child: Center(
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: ZayColors.white.withAlpha(220),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ZayColors.secondary.withAlpha(45),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.location_on,
              color: ZayColors.secondary,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = ZayColors.white.withAlpha(230)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = ZayColors.accent.withAlpha(120)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * .02, size.height * .82),
      Offset(size.width * .96, size.height * .24),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width * .14, size.height * .14),
      Offset(size.width * .92, size.height * .04),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * .12, size.height * .86),
      Offset(size.width * .78, size.height * .14),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * .4, size.height * .94),
      Offset(size.width * .98, size.height * .42),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * .04, size.height * .48),
      Offset(size.width * .58, size.height * .34),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SelectedAddressDetails extends StatelessWidget {
  const _SelectedAddressDetails({required this.address});

  final Address address;

  @override
  Widget build(BuildContext context) {
    final title = address.label.isEmpty ? 'Address' : address.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          address.formattedAddress,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textSecondary,
            fontWeight: FontWeight.w500,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _MissingAddressDetails extends StatelessWidget {
  const _MissingAddressDetails();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No address selected',
          style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Add or select a delivery address before payment.',
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textSecondary,
            fontWeight: FontWeight.w500,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Products (${cart.totalQuantity})',
          style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        ...cart.items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _CheckoutProductRow(item: item),
          );
        }),
      ],
    );
  }
}

class _CheckoutProductRow extends StatelessWidget {
  const _CheckoutProductRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final colorText = item.selectedColor ??
        (product.availableColors.isNotEmpty
            ? product.availableColors.first
            : null);

    return GestureDetector(
      onTap: () => ZayRouter.goto(ZayRoutes.productDetails, {
        'productId': product.id,
      }),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ZayNetworkImage(
            imageUrl: product.thumbnailUrl,
            width: 78,
            height: 78,
            borderRadius: BorderRadius.circular(12),
            placeholderIcon: Icons.shopping_bag_outlined,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  colorText == null || colorText.isEmpty
                      ? 'Qty: ${item.quantity}'
                      : 'Color: $colorText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color: ZayColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_currencySymbol(item.currencyCode ?? product.currencyCode)}${item.subtotal.toStringAsFixed(2)}',
            style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({required this.method});

  final PaymentMethod? method;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () => ZayRouter.goto(ZayRoutes.changePaymentMethod),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 20, 18, 20),
            decoration: BoxDecoration(
              color: ZayColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ZayColors.inputBorder),
            ),
            child: Row(
              children: [
                _PaymentBrandMark(method: method),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _paymentTitle(method),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                          color: ZayColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _paymentSubtitle(method),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                          color: ZayColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: ZayColors.textSecondary,
                  size: 34,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentBrandMark extends StatelessWidget {
  const _PaymentBrandMark({required this.method});

  final PaymentMethod? method;

  @override
  Widget build(BuildContext context) {
    final isCard = method == null || method!.type == PaymentMethodType.card;

    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F7),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCard
            ? const _CardCircles()
            : const Icon(
                Icons.account_balance_wallet_outlined,
                color: ZayColors.primary,
              ),
      ),
    );
  }
}

class _CardCircles extends StatelessWidget {
  const _CardCircles();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 22,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 2,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFFF1F1F),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: ZayColors.secondary.withAlpha(230),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummarySection extends StatelessWidget {
  const _OrderSummarySection({
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
    final total = _payableTotal(cart, deliveryFee);

    return Column(
      children: [
        _SummaryRow(label: 'Subtotal', value: _formatCurrency(cart.total)),
        const SizedBox(height: 12),
        _SummaryRow(label: 'Discount', value: '-${_formatCurrency(discount)}'),
        const SizedBox(height: 12),
        _SummaryRow(
          label: 'Delivery fee',
          value: _formatCurrency(deliveryFee),
        ),
        const SizedBox(height: 18),
        const Divider(height: 1, color: ZayColors.inputBorder),
        const SizedBox(height: 18),
        _SummaryRow(
          label: 'Total amount',
          value: _formatCurrency(total),
          isEmphasized: true,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final style = isEmphasized
        ? ZayTheme.lightTheme.textTheme.bodyLarge
        : ZayTheme.lightTheme.textTheme.displayLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: style?.copyWith(
              color: isEmphasized
                  ? ZayColors.textSecondary
                  : ZayColors.textSecondary,
              fontWeight: isEmphasized ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: style?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _CheckoutActionBar extends StatelessWidget {
  const _CheckoutActionBar({
    required this.total,
    required this.isLoading,
    required this.onCheckout,
  });

  final double total;
  final bool isLoading;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
      decoration: BoxDecoration(
        color: ZayColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(14),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total amount',
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color: ZayColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatCurrency(total),
                  style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            ZayButton.primary(
              action: onCheckout,
              text: 'Checkout Now',
              fullWidth: true,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  const _SectionTitleRow({
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  final String title;
  final String actionText;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: ZayColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            actionText,
            style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
              color: ZayColors.primary,
              fontWeight: FontWeight.w800,
            ),
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
      padding: const EdgeInsets.only(bottom: 18),
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

String _paymentTitle(PaymentMethod? method) {
  if (method == null) {
    return 'Select Payment Method';
  }

  return method.cardBrand ?? method.provider ?? method.title;
}

String _paymentSubtitle(PaymentMethod? method) {
  if (method == null) {
    return 'Choose a payment method';
  }

  final lastFour = method.lastFourDigits;
  if (lastFour == null || lastFour.isEmpty) {
    return method.subtitle ?? 'Selected payment method';
  }

  return '**** **** $lastFour';
}

double _payableTotal(Cart cart, double deliveryFee) {
  final hasDiscount =
      cart.discountedTotal > 0 && cart.discountedTotal < cart.total;
  return (hasDiscount ? cart.discountedTotal : cart.total) + deliveryFee;
}

String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)}';

String _currencySymbol(String currencyCode) {
  switch (currencyCode.toUpperCase()) {
    case 'USD':
      return r'$';
    default:
      return '$currencyCode ';
  }
}
