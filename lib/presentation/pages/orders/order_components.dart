import 'package:flutter/material.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/domain/entities/order_item_entity.dart';
import 'package:zayrova/presentation/components/zay_network_image.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class OrderHeader extends StatelessWidget {
  const OrderHeader({
    super.key,
    required this.title,
    this.showBack = true,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: showBack
                ? GestureDetector(
                    onTap: () => ZayRouter.goBack(),
                    behavior: HitTestBehavior.opaque,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back,
                        color: ZayColors.textPrimary,
                        size: 24,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(
            width: 42,
            height: 42,
            child: trailing ??
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: ZayColors.textPrimary,
                  size: 28,
                ),
          ),
        ],
      ),
    );
  }
}

class OrderTabs extends StatelessWidget {
  const OrderTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _OrderTab(
          label: 'My Order',
          isSelected: selectedIndex == 0,
          onTap: () => onChanged(0),
        ),
        _OrderTab(
          label: 'History',
          isSelected: selectedIndex == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _OrderTab extends StatelessWidget {
  const _OrderTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Text(
              label,
              style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color:
                    isSelected ? ZayColors.textPrimary : ZayColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 180,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? ZayColors.primary : ZayColors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onDetail,
    required this.onPrimaryAction,
    required this.primaryActionText,
  });

  final Order order;
  final VoidCallback onDetail;
  final VoidCallback onPrimaryAction;
  final String primaryActionText;

  @override
  Widget build(BuildContext context) {
    final item = order.items.isNotEmpty ? order.items.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZayColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEEF4)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderItemImage(item: item),
              const SizedBox(width: 16),
              Expanded(child: _OrderCardInfo(order: order, item: item)),
              const SizedBox(width: 12),
              SizedBox(
                width: 112,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    OrderStatusChip(status: order.status),
                    const SizedBox(height: 26),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        formatCurrency(order.totalAmount, order.currencyCode),
                        style:
                            ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: ZayColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ZayButton.outline(
                  action: onDetail,
                  text: 'Detail',
                  fullWidth: true,
                  compact: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ZayButton.primary(
                  action: onPrimaryAction,
                  text: primaryActionText,
                  fullWidth: true,
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderItemImage extends StatelessWidget {
  const _OrderItemImage({required this.item});

  final OrderItem? item;

  @override
  Widget build(BuildContext context) {
    return ZayNetworkImage(
      imageUrl: item?.product.thumbnailUrl,
      width: 84,
      height: 84,
      borderRadius: BorderRadius.circular(12),
      placeholderIcon: Icons.shopping_bag_outlined,
    );
  }
}

class _OrderCardInfo extends StatelessWidget {
  const _OrderCardInfo({required this.order, required this.item});

  final Order order;
  final OrderItem? item;

  @override
  Widget build(BuildContext context) {
    final title = item?.product.title ??
        order.orderNumber ??
        'Order ${order.id.isEmpty ? '' : '#${order.id}'}';
    final colorText = item?.selectedColor;
    final quantity = item?.quantity ?? order.items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: ZayColors.textPrimary,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          colorText == null || colorText.isEmpty
              ? 'Items: ${order.items.length}'
              : 'Color: $colorText',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Qty: $quantity',
          style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
            color: ZayColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final isComplete = status == OrderStatus.delivered;
    final isCancelled =
        status == OrderStatus.cancelled || status == OrderStatus.refunded;
    final color = isComplete
        ? const Color(0xFF10C76F)
        : isCancelled
            ? const Color(0xFFE53935)
            : const Color(0xFF35AFC1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: ZayColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        orderStatusLabel(status),
        style: ZayTheme.lightTheme.textTheme.displayMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String orderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.delivered:
      return 'Completed';
    case OrderStatus.cancelled:
      return 'Cancelled';
    case OrderStatus.refunded:
      return 'Refunded';
    case OrderStatus.pending:
    case OrderStatus.confirmed:
    case OrderStatus.processing:
    case OrderStatus.shipped:
      return 'On Progress';
  }
}

String formatCurrency(double value, String currencyCode) {
  final symbol = currencyCode.toUpperCase() == 'USD' ? r'$' : '$currencyCode ';
  return '$symbol ${value.toStringAsFixed(2)}';
}

String formatOrderDate(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$day/$month/${value.year}';
}
