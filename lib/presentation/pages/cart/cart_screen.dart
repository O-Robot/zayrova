import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/cart_entity.dart';
import 'package:zayrova/domain/entities/cart_item_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/components/zay_network_image.dart';
import 'package:zayrova/presentation/providers/feature/cart_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCart());
  }

  Future<void> _loadCart() {
    return ref.read(cartControllerProvider.notifier).loadCurrentUserCart();
  }

  Future<void> _updateItemQuantity(Cart cart, CartItem item, int quantity) {
    if (quantity < 1) {
      return _removeItem(cart, item);
    }

    return _syncCartItems(
      cart,
      cart.items.map((cartItem) {
        if (cartItem.id == item.id) {
          return cartItem.copyWith(quantity: quantity);
        }
        return cartItem;
      }).toList(),
    );
  }

  Future<void> _removeItem(Cart cart, CartItem item) {
    final remainingItems = cart.items
        .where((cartItem) => cartItem.id != item.id)
        .toList();

    if (remainingItems.isEmpty) {
      final cartId = int.tryParse(cart.id);
      if (cartId == null) {
        return Future.value();
      }
      return ref.read(cartControllerProvider.notifier).deleteCart(cartId);
    }

    return _syncCartItems(cart, remainingItems);
  }

  Future<void> _syncCartItems(Cart cart, List<CartItem> items) async {
    final cartId = int.tryParse(cart.id);
    if (cartId == null) {
      _showCartMessage('Unable to update this cart.');
      return;
    }

    final products = items
        .map((item) {
          final productId = int.tryParse(item.product.id);
          if (productId == null) {
            return null;
          }
          return {'id': productId, 'quantity': item.quantity};
        })
        .whereType<Map<String, dynamic>>()
        .toList();

    if (products.isEmpty) {
      _showCartMessage('Unable to update this cart item.');
      return;
    }

    await ref.read(cartControllerProvider.notifier).updateCart(
      cartId: cartId,
      products: products,
      merge: false,
    );

    final cartState = ref.read(cartControllerProvider);
    if (cartState.hasError) {
      _showCartMessage(cartState.errorMessage ?? 'Unable to update cart.');
    }
  }

  void _showCartMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ZayColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final cart = cartState.userCart;

    return Scaffold(
      appBar: null,
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CartHeader(),
            const SizedBox(height: 22),
            Expanded(
              child: _CartBody(
                state: cartState,
                cart: cart,
                onRetry: _loadCart,
                onIncrease: (item) {
                  if (cart != null) {
                    _updateItemQuantity(cart, item, item.quantity + 1);
                  }
                },
                onDecrease: (item) {
                  if (cart != null && item.quantity > 1) {
                    _updateItemQuantity(cart, item, item.quantity - 1);
                  }
                },
                onRemove: (item) {
                  if (cart != null) {
                    _removeItem(cart, item);
                  }
                },
                onCheckout: () => ZayRouter.goto(ZayRoutes.checkout),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
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
              'My Cart',
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => ZayRouter.goto(ZayRoutes.cart),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: ZayColors.textPrimary,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({
    required this.state,
    required this.cart,
    required this.onRetry,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onCheckout,
  });

  final CartState state;
  final Cart? cart;
  final Future<void> Function() onRetry;
  final ValueChanged<CartItem> onIncrease;
  final ValueChanged<CartItem> onDecrease;
  final ValueChanged<CartItem> onRemove;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasLoadedUserCart) {
      return const LoadingStateWidget(message: 'Loading cart...');
    }

    if (state.hasError && !state.hasLoadedUserCart) {
      return ErrorStateWidget(
        title: 'Cart unavailable',
        message: state.errorMessage ?? 'Unable to load cart.',
        onRetry: () => onRetry(),
      );
    }

    final currentCart = cart;

    if (currentCart == null || currentCart.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.shopping_cart_outlined,
        title: 'Cart is empty',
        message: 'Your cart is empty.',
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: ZayColors.primary,
          onRefresh: onRetry,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 340),
            child: Column(
              children: [
                if (state.hasError)
                  _InlineCartError(
                    message: state.errorMessage ?? 'Unable to update cart.',
                    onRetry: onRetry,
                  ),
                ...currentCart.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: _CartItemTile(
                      item: item,
                      isUpdating: state.isLoading,
                      onIncrease: () => onIncrease(item),
                      onDecrease: () => onDecrease(item),
                      onRemove: () => onRemove(item),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _CartSummarySheet(
            cart: currentCart,
            onCheckout: onCheckout,
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.isUpdating,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItem item;
  final bool isUpdating;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final colorText = item.selectedColor ??
        (product.availableColors.isNotEmpty ? product.availableColors.first : null);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _SelectionBox(isSelected: item.isSelected),
            const SizedBox(width: 14),
            GestureDetector(
              onTap: () => ZayRouter.goto(ZayRoutes.productDetails, {
                'productId': product.id,
              }),
              child: SizedBox(
                width: 104,
                height: 104,
                child: ZayNetworkImage(
                  imageUrl: product.thumbnailUrl,
                  borderRadius: BorderRadius.circular(12),
                  placeholderIcon: Icons.shopping_bag_outlined,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 112,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ZayTheme.lightTheme.textTheme.displayLarge
                                ?.copyWith(
                              color: ZayColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _RemoveButton(
                          isUpdating: isUpdating,
                          onRemove: onRemove,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _CartItemMeta(colorText: colorText),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _CartQuantitySelector(
                              quantity: item.quantity,
                              isUpdating: isUpdating,
                              onIncrease: onIncrease,
                              onDecrease: onDecrease,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${_currencySymbol(item.currencyCode ?? product.currencyCode)}${item.subtotal.toStringAsFixed(2)}',
                              style: ZayTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color: ZayColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(height: 1, color: ZayColors.cancel),
      ],
    );
  }
}

class _SelectionBox extends StatelessWidget {
  const _SelectionBox({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isSelected ? ZayColors.primary : ZayColors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isSelected ? ZayColors.primary : ZayColors.inputBorder,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, color: ZayColors.white, size: 20)
          : null,
    );
  }
}

class _CartItemMeta extends StatelessWidget {
  const _CartItemMeta({required this.colorText});

  final String? colorText;

  @override
  Widget build(BuildContext context) {
    if (colorText == null || colorText!.isEmpty) {
      return const SizedBox.shrink();
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
          color: ZayColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        children: [
          const TextSpan(text: 'Color: '),
          TextSpan(
            text: colorText,
            style: const TextStyle(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartQuantitySelector extends StatelessWidget {
  const _CartQuantitySelector({
    required this.quantity,
    required this.isUpdating,
    required this.onIncrease,
    required this.onDecrease,
  });

  final int quantity;
  final bool isUpdating;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: ZayColors.cancel,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CartQuantityButton(
            icon: Icons.remove,
            onTap: !isUpdating && quantity > 1 ? onDecrease : null,
          ),
          SizedBox(
            width: 38,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _CartQuantityButton(
            icon: Icons.add,
            onTap: isUpdating ? null : onIncrease,
          ),
        ],
      ),
    );
  }
}

class _CartQuantityButton extends StatelessWidget {
  const _CartQuantityButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: ZayColors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 19,
          color: onTap == null ? ZayColors.textSecondary : ZayColors.textPrimary,
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({
    required this.isUpdating,
    required this.onRemove,
  });

  final bool isUpdating;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUpdating ? null : onRemove,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: ZayColors.secondary.withAlpha(36),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.delete_outline,
          color: isUpdating ? ZayColors.textSecondary : ZayColors.secondary,
          size: 22,
        ),
      ),
    );
  }
}

class _CartSummarySheet extends StatelessWidget {
  const _CartSummarySheet({
    required this.cart,
    required this.onCheckout,
  });

  final Cart cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final discount = (cart.total - cart.discountedTotal).clamp(0, double.infinity);
    final payableTotal = cart.discountedTotal > 0 ? cart.discountedTotal : cart.total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 22),
      decoration: BoxDecoration(
        color: ZayColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 5,
              decoration: BoxDecoration(
                color: ZayColors.cancel,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 28),
            const _PromoCodeRow(),
            const SizedBox(height: 26),
            _SummaryLine(
              label: 'Subtotal',
              value: '${_currencySymbol('USD')}${cart.total.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 20),
            _SummaryLine(
              label: 'Discount',
              value: '-${_currencySymbol('USD')}${discount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 20),
            _SummaryLine(
              label: 'Total quantity',
              value: '${cart.totalQuantity}',
            ),
            const SizedBox(height: 22),
            const _DashedDivider(),
            const SizedBox(height: 22),
            _SummaryLine(
              label: 'Total amount',
              value:
                  '${_currencySymbol('USD')}${payableTotal.toStringAsFixed(2)}',
              isEmphasized: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZayColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Checkout',
                  style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: ZayColors.white,
                    fontWeight: FontWeight.w800,
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

class _PromoCodeRow extends StatelessWidget {
  const _PromoCodeRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZayColors.inputBorder.withAlpha(90)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.discount_outlined,
            color: ZayColors.inputBorder,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Enter your promo code',
              style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: ZayColors.textSecondary,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: ZayColors.textSecondary,
            size: 30,
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
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
              color: ZayColors.textSecondary,
              fontWeight: isEmphasized ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 14),
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

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 8.0;
        const dashSpace = 8.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1.5,
              child: DecoratedBox(
                decoration: BoxDecoration(color: ZayColors.inputBorder),
              ),
            );
          }),
        );
      },
    );
  }
}

class _InlineCartError extends StatelessWidget {
  const _InlineCartError({
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

String _currencySymbol(String currencyCode) {
  switch (currencyCode.toUpperCase()) {
    case 'USD':
      return r'$';
    default:
      return '$currencyCode ';
  }
}
