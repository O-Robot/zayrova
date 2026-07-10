import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/domain/entities/order_item_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/components/zay_network_image.dart';
import 'package:zayrova/presentation/pages/orders/order_components.dart';
import 'package:zayrova/presentation/pages/orders/order_review_store.dart';
import 'package:zayrova/presentation/providers/feature/order_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class OrderReviewScreen extends ConsumerStatefulWidget {
  const OrderReviewScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends ConsumerState<OrderReviewScreen> {
  StoredOrderReview? _storedReview;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrder());
  }

  Future<void> _loadOrder() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      return;
    }

    _storedReview = await OrderReviewStore.getReview(orderId);
    if (mounted) {
      setState(() {});
    }

    final selectedOrder = ref.read(orderControllerProvider).selectedOrder;
    if (selectedOrder?.id == orderId) {
      return;
    }

    final id = int.tryParse(orderId);
    if (id == null) {
      return;
    }

    await ref.read(orderControllerProvider.notifier).loadOrderById(id);
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
    final state = ref.watch(orderControllerProvider);

    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const OrderHeader(title: 'Order Review'),
            Expanded(
              child:
                  orderId == null || orderId.isEmpty
                      ? const EmptyStateWidget(
                        icon: Icons.rate_review_outlined,
                        title: 'Missing order',
                        message: 'This order cannot be reviewed.',
                      )
                      : _OrderReviewBody(
                        state: state,
                        orderId: orderId,
                        storedReview: _storedReview,
                        onRetry: _loadOrder,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderReviewBody extends StatelessWidget {
  const _OrderReviewBody({
    required this.state,
    required this.orderId,
    required this.storedReview,
    required this.onRetry,
  });

  final OrderState state;
  final String orderId;
  final StoredOrderReview? storedReview;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.selectedOrder == null) {
      return const LoadingStateWidget(message: 'Loading order...');
    }

    if (state.hasError && state.selectedOrder == null) {
      return ErrorStateWidget(
        title: 'Order unavailable',
        message: state.errorMessage ?? 'Unable to load order.',
        onRetry: () => onRetry(),
      );
    }

    final order =
        state.selectedOrder?.id == orderId ? state.selectedOrder : null;
    if (order == null) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No order found',
        message: 'Open this review from an existing order.',
        actionText: 'Back to Orders',
        onAction: () => ZayRouter.goto(ZayRoutes.orders),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewOrderSummary(order: order),
          const SizedBox(height: 24),
          _DeliveryInfo(order: order),
          const SizedBox(height: 24),
          _PurchasedItems(order: order),
          const SizedBox(height: 24),
          _ReviewEntryPoint(order: order, storedReview: storedReview),
        ],
      ),
    );
  }
}

class _ReviewOrderSummary extends StatelessWidget {
  const _ReviewOrderSummary({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ZayColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEEF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber ?? 'Order #${order.id}',
                  style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              OrderStatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          _InfoLine(label: 'Placed', value: formatOrderDate(order.createdAt)),
          const SizedBox(height: 8),
          _InfoLine(
            label: 'Total',
            value: formatCurrency(order.totalAmount, order.currencyCode),
          ),
          if (order.trackingNumber != null &&
              order.trackingNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoLine(label: 'Tracking', value: order.trackingNumber!),
          ],
        ],
      ),
    );
  }
}

class _DeliveryInfo extends StatelessWidget {
  const _DeliveryInfo({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final address = order.shippingAddress;
    final estimated = order.estimatedDeliveryAt;

    return _SectionCard(
      title: 'Delivery Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(
            label: 'Address',
            value:
                address?.formattedAddress.isNotEmpty == true
                    ? address!.formattedAddress
                    : 'Not available',
          ),
          if (estimated != null) ...[
            const SizedBox(height: 8),
            _InfoLine(label: 'Estimated', value: formatOrderDate(estimated)),
          ],
        ],
      ),
    );
  }
}

class _PurchasedItems extends StatelessWidget {
  const _PurchasedItems({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Purchased Items',
      child: Column(
        children:
            order.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ReviewOrderItem(item: item),
              );
            }).toList(),
      ),
    );
  }
}

class _ReviewOrderItem extends StatelessWidget {
  const _ReviewOrderItem({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ZayNetworkImage(
          imageUrl: item.product.thumbnailUrl,
          width: 64,
          height: 64,
          borderRadius: BorderRadius.circular(12),
          placeholderAssetIcon: ZayIcons.cartIcon,
        ),
        const SizedBox(width: 14),
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
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Qty: ${item.quantity}',
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          formatCurrency(item.subtotal, item.currencyCode),
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ReviewEntryPoint extends StatelessWidget {
  const _ReviewEntryPoint({required this.order, required this.storedReview});

  final Order order;
  final StoredOrderReview? storedReview;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: storedReview == null ? 'Review This Order' : 'Your Review',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (storedReview != null) ...[
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < storedReview!.rating ? Icons.star : Icons.star_border,
                  color: ZayColors.primary,
                  size: 22,
                );
              }),
            ),
            if (storedReview!.review.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                storedReview!.review,
                style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                  color: ZayColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 18),
          ] else ...[
            Text(
              'Share how your order went so future review APIs can sync this feedback.',
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
          ],
          ZayButton.primary(
            action:
                () => ZayRouter.goto(ZayRoutes.orderRating, {
                  'orderId': order.id,
                }),
            text: storedReview == null ? 'Rate Order' : 'Update Review',
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: ZayColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
