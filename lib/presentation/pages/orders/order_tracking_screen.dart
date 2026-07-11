import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/assets.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
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
      body:
          !hasOrderId
              ? const SafeArea(
                child: EmptyStateWidget(
                  icon: Icons.local_shipping_outlined,
                  title: 'Missing order',
                  message: 'This order cannot be tracked.',
                ),
              )
              : _TrackingBody(state: state, onRetry: _trackOrder),
    );
  }
}

class _TrackingBody extends StatefulWidget {
  const _TrackingBody({required this.state, required this.onRetry});

  final OrderState state;
  final Future<void> Function() onRetry;

  @override
  State<_TrackingBody> createState() => _TrackingBodyState();
}

class _TrackingBodyState extends State<_TrackingBody> {
  static const double _minSheetSize = 0.40;
  static const double _initialSheetSize = 0.60;
  static const double _maxSheetSize = 0.88;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final onRetry = widget.onRetry;

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

    return Stack(
      children: [
        const Positioned.fill(child: _TrackingMap()),
        _TrackingHeader(title: 'Order Tracking'),
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: _initialSheetSize,
          minChildSize: _minSheetSize,
          maxChildSize: _maxSheetSize,
          snap: true,
          snapSizes: const [_minSheetSize, _initialSheetSize, _maxSheetSize],
          builder: (context, scrollController) {
            return _TrackingSheet(
              order: order,
              scrollController: scrollController,
              sheetController: _sheetController,
              minSheetSize: _minSheetSize,
              initialSheetSize: _initialSheetSize,
              maxSheetSize: _maxSheetSize,
            );
          },
        ),
      ],
    );
  }
}

class _TrackingMap extends StatelessWidget {
  const _TrackingMap();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                ZayAssets.orderTrackingMap,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withAlpha(20),
                      Colors.transparent,
                      Colors.white.withAlpha(22),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 118,
              child: _MapPin(
                icon: Icons.circle,
                color: ZayColors.white,
                borderColor: ZayColors.primary,
              ),
            ),
            Positioned(
              left: 40,
              top: 158,
              child: SizedBox(
                width: 186,
                height: 180,
                child: CustomPaint(painter: _TrackingRoutePainter()),
              ),
            ),
            Positioned(
              left: 126,
              bottom: 78,
              child: _MapPin(
                icon: Icons.local_shipping_outlined,
                color: ZayColors.primary,
                borderColor: ZayColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
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

class _TrackingRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint =
        Paint()
          ..color = ZayColors.primary
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final path =
        Path()
          ..moveTo(18, 8)
          ..lineTo(18, 98)
          ..lineTo(92, 98)
          ..lineTo(92, 136)
          ..lineTo(132, 136)
          ..lineTo(132, size.height - 18);

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrackingHeader extends StatelessWidget {
  const _TrackingHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, topInset + 10, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back,
                  color: ZayColors.textPrimary,
                  size: 28,
                ),
              ),
            ),
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
          const SizedBox(width: 42, height: 42),
        ],
      ),
    );
  }
}

class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({
    required this.order,
    required this.scrollController,
    required this.sheetController,
    required this.minSheetSize,
    required this.initialSheetSize,
    required this.maxSheetSize,
  });

  final Order order;
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;
  final double minSheetSize;
  final double initialSheetSize;
  final double maxSheetSize;

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
            _SheetDragHandle(
              controller: sheetController,
              minSheetSize: minSheetSize,
              initialSheetSize: initialSheetSize,
              maxSheetSize: maxSheetSize,
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
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  _TrackingTimeline(order: order),
                ],
              ),
            ),
            const SizedBox(height: 12),
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
              text:
                  order.status == OrderStatus.delivered
                      ? 'Order Completed'
                      : 'Mark as Done',
              isDisabled: order.status == OrderStatus.delivered,
              fullWidth: true,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle({
    required this.controller,
    required this.minSheetSize,
    required this.initialSheetSize,
    required this.maxSheetSize,
  });

  final DraggableScrollableController controller;
  final double minSheetSize;
  final double initialSheetSize;
  final double maxSheetSize;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    Future<void> animateTo(double size) {
      return controller.animateTo(
        size,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        final currentSize = controller.isAttached ? controller.size : initialSheetSize;
        final nextSize = (currentSize - (details.delta.dy / screenHeight)).clamp(
          minSheetSize,
          maxSheetSize,
        );
        controller.jumpTo(nextSize);
      },
      onVerticalDragEnd: (details) {
        final currentSize = controller.isAttached ? controller.size : initialSheetSize;
        final velocity = details.primaryVelocity ?? 0;

        if (velocity <= -250) {
          animateTo(maxSheetSize);
          return;
        }

        if (velocity >= 250) {
          animateTo(minSheetSize);
          return;
        }

        if (currentSize >= (initialSheetSize + maxSheetSize) / 2) {
          animateTo(maxSheetSize);
          return;
        }

        if (currentSize <= (minSheetSize + initialSheetSize) / 2) {
          animateTo(minSheetSize);
          return;
        }

        animateTo(initialSheetSize);
      },
      child: Center(
        child: Container(
          width: 62,
          height: 7,
          decoration: BoxDecoration(
            color: ZayColors.cancel,
            borderRadius: BorderRadius.circular(20),
          ),
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
            decoration: BoxDecoration(
              color: ZayColors.cancel,
              borderRadius: BorderRadius.circular(18),
              image: const DecorationImage(
                image: AssetImage(ZayIllustrations.getStarted),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alexander Jr',
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
    final delivered = order.status == OrderStatus.delivered;
    final inTransit =
        order.status == OrderStatus.processing ||
        order.status == OrderStatus.shipped ||
        delivered;

    final steps = [
      _TimelineStep(
        title:
            order.items.isNotEmpty
                ? order.items.first.product.title
                : 'Upbox Bag',
        subtitle: 'Shop',
        timeLabel: _formatTrackingTime(order.createdAt),
        icon: Icons.storefront_outlined,
        isComplete: true,
      ),
      _TimelineStep(
        title: 'On the way',
        subtitle: 'Delivery',
        timeLabel: _formatTrackingTime(order.updatedAt ?? order.createdAt),
        icon: Icons.pedal_bike_outlined,
        isComplete: inTransit,
      ),
      _TimelineStep(
        title:
            order.shippingAddress?.formattedAddress.isNotEmpty == true
                ? order.shippingAddress!.formattedAddress
                : 'Delivery address pending',
        subtitle: 'Houser',
        timeLabel: _formatTrackingTime(
          order.estimatedDeliveryAt ?? order.updatedAt ?? order.createdAt,
        ),
        icon: Icons.location_on_outlined,
        isComplete: delivered,
      ),
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        return _TimelineTile(step: step, isLast: index == steps.length - 1);
      }),
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.icon,
    required this.isComplete,
  });

  final String title;
  final String subtitle;
  final String timeLabel;
  final IconData icon;
  final bool isComplete;
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.step, required this.isLast});

  final _TimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = step.isComplete ? ZayColors.primary : const Color(0xFFF1F2F6);
    final iconColor = step.isComplete ? ZayColors.white : ZayColors.textPrimary;
    final lineColor =
        step.isComplete ? ZayColors.primary : const Color(0xFFE4E7EF);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(step.icon, color: iconColor),
              ),
              if (!isLast)
                Expanded(child: Container(width: 3, color: lineColor)),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ZayTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: ZayColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${step.subtitle}  •  ${step.timeLabel}',
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

String _formatTrackingTime(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}
