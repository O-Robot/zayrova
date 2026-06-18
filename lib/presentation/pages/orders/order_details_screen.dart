import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/domain/entities/order_item_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/components/zay_network_image.dart';
import 'package:zayrova/presentation/pages/orders/order_components.dart';
import 'package:zayrova/presentation/providers/feature/order_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrder());
  }

  Future<void> _loadOrder() async {
    final id = int.tryParse(widget.orderId ?? '');
    if (id == null) {
      return;
    }

    final selectedOrder = ref.read(orderControllerProvider).selectedOrder;
    if (selectedOrder?.id == widget.orderId) {
      return;
    }

    await ref.read(orderControllerProvider.notifier).loadOrderById(id);
  }

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(widget.orderId ?? '');
    final state = ref.watch(orderControllerProvider);

    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const OrderHeader(title: 'Order Detail'),
            Expanded(
              child: id == null
                  ? const EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: 'Missing order',
                      message: 'This order could not be opened.',
                    )
                  : _OrderDetailsBody(
                      state: state,
                      onRetry: _loadOrder,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailsBody extends StatelessWidget {
  const _OrderDetailsBody({
    required this.state,
    required this.onRetry,
  });

  final OrderState state;
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

    final order = state.selectedOrder;
    if (order == null) {
      return const EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No order found',
        message: 'The selected order is not available.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderSummaryHeader(order: order),
          const SizedBox(height: 28),
          Text(
            'Products (${order.items.length})',
            style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: ZayColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _DetailOrderItem(item: item),
            );
          }),
          const SizedBox(height: 12),
          _TotalsPanel(order: order),
          const SizedBox(height: 28),
          ZayButton.primary(
            action: () => ZayRouter.goto(ZayRoutes.orderTracking, {
              'orderId': order.id,
            }),
            text: 'Track Order',
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryHeader extends StatelessWidget {
  const _OrderSummaryHeader({required this.order});

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
          Text(
            'Placed on ${formatOrderDate(order.createdAt)}',
            style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
              color: ZayColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (order.trackingNumber != null &&
              order.trackingNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Tracking: ${order.trackingNumber}',
              style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
                color: ZayColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailOrderItem extends StatelessWidget {
  const _DetailOrderItem({required this.item});

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ZayNetworkImage(
          imageUrl: item.product.thumbnailUrl,
          width: 72,
          height: 72,
          borderRadius: BorderRadius.circular(12),
          placeholderIcon: Icons.shopping_bag_outlined,
        ),
        const SizedBox(width: 16),
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
              const SizedBox(height: 8),
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

class _TotalsPanel extends StatelessWidget {
  const _TotalsPanel({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final subtotal = order.subtotal ?? order.items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );
    final deliveryFee = order.deliveryFee ?? 0;
    final discount = order.discountAmount ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _TotalRow(label: 'Subtotal', value: subtotal, order: order),
          const SizedBox(height: 12),
          _TotalRow(label: 'Discount', value: -discount, order: order),
          const SizedBox(height: 12),
          _TotalRow(label: 'Delivery fee', value: deliveryFee, order: order),
          const Divider(height: 28, color: ZayColors.inputBorder),
          _TotalRow(
            label: 'Total amount',
            value: order.totalAmount,
            order: order,
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
    required this.order,
    this.isEmphasized = false,
  });

  final String label;
  final double value;
  final Order order;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final style = isEmphasized
        ? ZayTheme.lightTheme.textTheme.bodyLarge
        : ZayTheme.lightTheme.textTheme.displayMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style?.copyWith(
            color: ZayColors.textSecondary,
            fontWeight: isEmphasized ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        Text(
          formatCurrency(value, order.currencyCode),
          style: style?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: isEmphasized ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
