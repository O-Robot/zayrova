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
    return ref
        .read(cartControllerProvider.notifier)
        .loadUserCart(temporaryDummyJsonCartUserId);
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
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TopNavigation(text: 'My Cart'),
            ),
            const SizedBox(height: 24),
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
      return const _CartLoadingState();
    }

    if (state.hasError && !state.hasLoadedUserCart) {
      return _CartErrorState(
        message: state.errorMessage ?? 'Unable to load cart.',
        onRetry: onRetry,
      );
    }

    final currentCart = cart;

    if (currentCart == null || currentCart.isEmpty) {
      return const _CartMessageState(
        icon: Icons.shopping_cart_outlined,
        message: 'Your cart is empty.',
      );
    }

    return RefreshIndicator(
      color: ZayColors.primary,
      onRefresh: onRetry,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          children: [
            if (state.hasError)
              _InlineCartError(
                message: state.errorMessage ?? 'Unable to update cart.',
                onRetry: onRetry,
              ),
            ...currentCart.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CartItemTile(
                  item: item,
                  isUpdating: state.isLoading,
                  onIncrease: () => onIncrease(item),
                  onDecrease: () => onDecrease(item),
                  onRemove: () => onRemove(item),
                ),
              );
            }),
            const SizedBox(height: 8),
            _CartSummary(cart: currentCart, onCheckout: onCheckout),
          ],
        ),
      ),
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
    final imageUrl = item.product.thumbnailUrl;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ZayColors.white,
        border: Border.all(color: ZayColors.inputBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 72,
              height: 72,
              child: imageUrl == null || imageUrl.isEmpty
                  ? const _CartImageFallback()
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const _CartImageFallback();
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
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                    color: ZayColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _CartQuantityButton(
                      icon: Icons.remove,
                      onTap: !isUpdating && item.quantity > 1
                          ? onDecrease
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${item.quantity}',
                        style:
                            ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                          color: ZayColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _CartQuantityButton(
                      icon: Icons.add,
                      onTap: isUpdating ? null : onIncrease,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isUpdating ? null : onRemove,
            icon: const Icon(Icons.delete_outline),
            color: ZayColors.textSecondary,
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
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: ZayColors.cancel,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? ZayColors.textSecondary : ZayColors.primary,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.cart,
    required this.onCheckout,
  });

  final Cart cart;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ZayColors.cancel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(label: 'Subtotal', value: cart.total),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Discounted Total', value: cart.discountedTotal),
          const SizedBox(height: 8),
          Text(
            'Total Quantity: ${cart.totalQuantity}',
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: ZayColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ZayButton.primary(
              action: onCheckout,
              text: 'Checkout',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
            color: ZayColors.textSecondary,
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

class _CartLoadingState extends StatelessWidget {
  const _CartLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: ZayColors.primary),
    );
  }
}

class _CartErrorState extends StatelessWidget {
  const _CartErrorState({
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

class _CartMessageState extends StatelessWidget {
  const _CartMessageState({
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

class _CartImageFallback extends StatelessWidget {
  const _CartImageFallback();

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
