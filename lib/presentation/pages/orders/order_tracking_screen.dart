import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/pages/orders/order_components.dart';
import 'package:zayrova/presentation/providers/feature/order_controller.dart';
import 'package:zayrova/presentation/widgets/button.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  const OrderTrackingScreen({super.key, this.orderId});

  final String? orderId;

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _trackOrder());
  }

  Future<void> _trackOrder() async {
    final orderId = widget.orderId;
    if (orderId == null || orderId.isEmpty) {
      return;
    }

    await ref
        .read(orderControllerProvider.notifier)
        .trackOrderByIdentifier(orderId);
  }

  @override
  Widget build(BuildContext context) {
    final hasOrderId = widget.orderId != null && widget.orderId!.isNotEmpty;
    final state = ref.watch(orderControllerProvider);

    return Scaffold(
      backgroundColor: ZayColors.white,
      body: SafeArea(
        child: !hasOrderId
            ? const EmptyStateWidget(
                icon: Icons.local_shipping_outlined,
                title: 'Missing order',
                message: 'This order cannot be tracked.',
              )
            : _TrackingBody(state: state, onRetry: _trackOrder),
      ),
    );
  }
}

class _TrackingBody extends StatelessWidget {
  const _TrackingBody({
    required this.state,
    required this.onRetry,
  });

  final OrderState state;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.trackedOrder == null) {
      return const LoadingStateWidget(message: 'Loading tracking...');
    }

    if (state.hasError && state.trackedOrder == null) {
      return ErrorStateWidget(
        title: 'Tracking unavailable',
        message: state.errorMessage ?? 'Unable to track this order.',
        onRetry: () => onRetry(),
      );
    }

    final order = state.trackedOrder;
    if (order == null) {
      return const EmptyStateWidget(
        icon: Icons.local_shipping_outlined,
        title: 'No tracking found',
        message: 'Tracking information is not available for this order.',
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              const Positioned.fill(child: _TrackingMap()),
              const OrderHeader(
                title: 'Order Tracking',
                trailing: SizedBox.shrink(),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 6,
          child: _TrackingSheet(order: order),
        ),
      ],
    );
  }
}

class _TrackingMap extends StatelessWidget {
  const _TrackingMap();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrackingMapPainter(),
      child: Stack(
        children: [
          Positioned(
            left: 42,
            top: 130,
            child: _MapPin(
              icon: Icons.circle,
              color: ZayColors.white,
              borderColor: ZayColors.primary,
            ),
          ),
          Positioned(
            right: 118,
            bottom: 54,
            child: _MapPin(
              icon: Icons.local_shipping_outlined,
              color: ZayColors.primary,
              borderColor: ZayColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFEDEFF2);
    canvas.drawRect(Offset.zero & size, background);

    final parkPaint = Paint()..color = const Color(0xFF8BD9A9);
    canvas.drawCircle(Offset(size.width * .2, size.height * .12), 70, parkPaint);
    canvas.drawCircle(Offset(size.width * .9, size.height * .54), 88, parkPaint);

    final roadPaint = Paint()
      ..color = ZayColors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 9; i++) {
      final y = size.height * (.12 + i * .09);
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 46), roadPaint);
    }

    for (var i = 0; i < 7; i++) {
      final x = size.width * (.05 + i * .15);
      canvas.drawLine(Offset(x, 0), Offset(x + 68, size.height), roadPaint);
    }

    final routePaint = Paint()
      ..color = ZayColors.primary
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(64, 148)
      ..lineTo(64, size.height * .48)
      ..lineTo(size.width * .48, size.height * .48)
      ..lineTo(size.width * .48, size.height * .72)
      ..lineTo(size.width * .66, size.height * .72);
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.icon,
    required this.color,
    required this.borderColor,
  });

  final IconData icon;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 6),
      ),
      child: Icon(
        icon,
        color: color == ZayColors.primary ? ZayColors.white : ZayColors.primary,
        size: 22,
      ),
    );
  }
}

class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      decoration: const BoxDecoration(
        color: ZayColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 62,
                height: 7,
                decoration: BoxDecoration(
                  color: ZayColors.cancel,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 26),
            const _CourierCard(),
            const SizedBox(height: 32),
            Text(
              'Progress of your Order',
              style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: ZayColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: _TrackingTimeline(order: order)),
            ZayButton.outline(
              action: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Order status cannot be updated from the app right now.',
                    ),
                  ),
                );
              },
              text: order.status == OrderStatus.delivered
                  ? 'Order Completed'
                  : 'Mark as Done',
              isDisabled: order.status == OrderStatus.delivered,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourierCard extends StatelessWidget {
  const _CourierCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEEF4)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: ZayColors.cancel,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: ZayColors.textSecondary),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Courier',
                  style: ZayTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: ZayColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Delivery partner',
                  style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                    color: ZayColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _CircleAction(icon: Icons.language),
          const SizedBox(width: 12),
          _CircleAction(icon: Icons.call_outlined),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFEDEEF4)),
      ),
      child: Icon(icon, color: ZayColors.textSecondary),
    );
  }
}

class _TrackingTimeline extends StatelessWidget {
  const _TrackingTimeline({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        title: order.items.isNotEmpty
            ? order.items.first.product.title
            : 'Order placed',
        subtitle: 'Shop',
        icon: Icons.storefront_outlined,
        isComplete: true,
      ),
      _TimelineStep(
        title: 'On the way',
        subtitle: 'Delivery',
        icon: Icons.route_outlined,
        isComplete: order.status != OrderStatus.pending,
      ),
      _TimelineStep(
        title: order.shippingAddress?.formattedAddress ??
            'Delivery address pending',
        subtitle: 'House',
        icon: Icons.location_on_outlined,
        isComplete: order.status == OrderStatus.delivered,
      ),
    ];

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final step = steps[index];
        return _TimelineTile(
          step: step,
          isLast: index == steps.length - 1,
        );
      },
      itemCount: steps.length,
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isComplete,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isComplete;
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.step,
    required this.isLast,
  });

  final _TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = step.isComplete ? ZayColors.primary : ZayColors.cancel;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step.icon,
                  color: step.isComplete
                      ? ZayColors.white
                      : ZayColors.textSecondary,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    color:
                        step.isComplete ? ZayColors.primary : ZayColors.cancel,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: ZayColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${step.subtitle}  •  ${step.isComplete ? 'Done' : 'Pending'}',
                    style: ZayTheme.lightTheme.textTheme.displayLarge?.copyWith(
                      color: ZayColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
