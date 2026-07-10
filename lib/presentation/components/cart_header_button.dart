import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/presentation/providers/feature/cart_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class CartHeaderButton extends ConsumerStatefulWidget {
  const CartHeaderButton({
    super.key,
    this.dimension = 42,
    this.iconPadding = const EdgeInsets.all(7),
    this.iconColor = ZayColors.textPrimary,
    this.decoration,
    this.iconSize,
  });

  final double dimension;
  final EdgeInsets iconPadding;
  final Color iconColor;
  final BoxDecoration? decoration;
  final double? iconSize;

  @override
  ConsumerState<CartHeaderButton> createState() => _CartHeaderButtonState();
}

class _CartHeaderButtonState extends ConsumerState<CartHeaderButton> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartState = ref.read(cartControllerProvider);
      if (!cartState.hasLoadedUserCart && !cartState.isLoading) {
        ref.read(cartControllerProvider.notifier).loadCurrentUserCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);
    final cart = cartState.userCart;
    final totalQuantity =
        cart == null
            ? 0
            : cart.totalQuantity > 0
            ? cart.totalQuantity
            : cart.items.fold<int>(
              0,
              (sum, item) => sum + item.quantity,
            );
    final badgeText = totalQuantity > 99 ? '99+' : '$totalQuantity';

    return GestureDetector(
      onTap: () => ZayRouter.goto(ZayRoutes.cart),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.dimension,
        height: widget.dimension,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.dimension,
              height: widget.dimension,
              decoration: widget.decoration,
              child: Padding(
                padding: widget.iconPadding,
                child: SvgPicture.asset(
                  ZayIcons.cartIcon,
                  width: widget.iconSize,
                  height: widget.iconSize,
                  colorFilter: ColorFilter.mode(
                    widget.iconColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            if (totalQuantity > 0)
              Positioned(
                top: -2,
                right: -4,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: ZayColors.primary,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: ZayColors.white, width: 2),
                  ),
                  child: Text(
                    badgeText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: ZayColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1,
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
