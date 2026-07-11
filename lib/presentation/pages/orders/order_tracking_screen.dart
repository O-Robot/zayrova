import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/core/themes/zay_theme.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/features/tracking/models/tracking_model.dart';
import 'package:zayrova/features/tracking/tracking_provider.dart';
import 'package:zayrova/features/tracking/widgets/courier_card.dart';
import 'package:zayrova/features/tracking/widgets/delivery_progress.dart';
import 'package:zayrova/features/tracking/widgets/tracking_map.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/providers/feature/address_controller.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
import 'package:zayrova/presentation/providers/feature/order_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
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
              ? SafeArea(
                child: const EmptyStateWidget(
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
  static const double _initialSheetSize = 0.60;
  static const double _maxSheetSize = 0.90;

  late double _sheetSize = _initialSheetSize;
  bool _isDragging = false;

  void _updateSheetSize(double nextSize, double minSheetSize) {
    setState(() {
      _isDragging = true;
      _sheetSize = nextSize.clamp(minSheetSize, _maxSheetSize);
    });
  }

  void _snapSheet(double velocity, double minSheetSize) {
    final snapPoints = [minSheetSize, _initialSheetSize, _maxSheetSize];

    double target;
    if (velocity <= -250) {
      target = _maxSheetSize;
    } else if (velocity >= 250) {
      target = minSheetSize;
    } else {
      target = snapPoints.first;
      var minDistance = (_sheetSize - target).abs();

      for (final point in snapPoints.skip(1)) {
        final distance = (_sheetSize - point).abs();
        if (distance < minDistance) {
          target = point;
          minDistance = distance;
        }
      }
    }

    setState(() {
      _isDragging = false;
      _sheetSize = target.clamp(minSheetSize, _maxSheetSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final onRetry = widget.onRetry;

    if (state.isLoading && state.trackedOrder == null) {
      return const SafeArea(
        child: LoadingStateWidget(message: 'Loading tracking...'),
      );
    }

    if (state.hasError && state.trackedOrder == null) {
      return SafeArea(
        child: ErrorStateWidget(
          title: 'Tracking unavailable',
          message: state.errorMessage ?? 'Unable to track this order.',
          onRetry: () => onRetry(),
        ),
      );
    }

    final order = state.trackedOrder;
    if (order == null) {
      return const SafeArea(
        child: EmptyStateWidget(
          icon: Icons.local_shipping_outlined,
          title: 'No tracking found',
          message: 'Tracking information is not available for this order.',
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final savedAddress =
            ref.watch(addressControllerProvider).selectedAddress;
        final profileAddress =
            ref.watch(authControllerProvider).currentUser?.defaultAddress;
        final trackingRequest = (
          order: order,
          fallbackAddress: savedAddress ?? profileAddress,
        );
        final tracking = ref.watch(trackingModelProvider(trackingRequest));

        return tracking.when(
          loading:
              () => const SafeArea(
                child: LoadingStateWidget(
                  message: 'Preparing live tracking...',
                ),
              ),
          error:
              (error, _) => SafeArea(
                child: ErrorStateWidget(
                  title: 'Map unavailable',
                  message: 'Unable to prepare tracking map right now.',
                  onRetry: () => ref.refresh(
                    trackingModelProvider(trackingRequest),
                  ),
                ),
              ),
          data:
              (trackingData) => _TrackingScaffold(
                order: order,
                tracking: trackingData,
                sheetSize: _sheetSize,
                initialSheetSize: _initialSheetSize,
                maxSheetSize: _maxSheetSize,
                isDragging: _isDragging,
                onDragUpdate: _updateSheetSize,
                onDragEnd: _snapSheet,
              ),
        );
      },
    );
  }
}

class _TrackingScaffold extends StatelessWidget {
  const _TrackingScaffold({
    required this.order,
    required this.tracking,
    required this.sheetSize,
    required this.initialSheetSize,
    required this.maxSheetSize,
    required this.isDragging,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final Order order;
  final TrackingModel tracking;
  final double sheetSize;
  final double initialSheetSize;
  final double maxSheetSize;
  final bool isDragging;
  final void Function(double nextSize, double minSheetSize) onDragUpdate;
  final void Function(double velocity, double minSheetSize) onDragEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomInset = MediaQuery.of(context).padding.bottom;
        const progressPreviewHeight = 92.0;
        final minSheetHeight =
            18 +
            19 +
            26 +
            112 +
            24 +
            56 +
            16 +
            progressPreviewHeight +
            bottomInset;
        final minSheetSize = (minSheetHeight / constraints.maxHeight).clamp(
          0.42,
          0.54,
        );
        final effectiveSheetSize = sheetSize.clamp(minSheetSize, maxSheetSize);

        return Stack(
          children: [
            Positioned.fill(child: TrackingMap(tracking: tracking)),
            const _TrackingHeader(title: 'Order Tracking'),
            Align(
              alignment: Alignment.bottomCenter,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: effectiveSheetSize,
                  end: effectiveSheetSize,
                ),
                duration:
                    isDragging
                        ? Duration.zero
                        : const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                builder: (context, animatedSize, child) {
                  return FractionallySizedBox(
                    heightFactor: animatedSize,
                    widthFactor: 1,
                    alignment: Alignment.bottomCenter,
                    child: child,
                  );
                },
                child: _TrackingSheet(
                  order: order,
                  tracking: tracking,
                  sheetSize: effectiveSheetSize,
                  minSheetSize: minSheetSize,
                  initialSheetSize: initialSheetSize,
                  maxSheetSize: maxSheetSize,
                  onDragUpdate: (delta) {
                    onDragUpdate(
                      effectiveSheetSize - (delta / constraints.maxHeight),
                      minSheetSize,
                    );
                  },
                  onDragEnd: (velocity) => onDragEnd(velocity, minSheetSize),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrackingHeader extends StatelessWidget {
  const _TrackingHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topInset + 10,
      left: 24,
      right: 24,
      child: Row(
        children: [
          GestureDetector(
            onTap: ZayRouter.goBack,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.arrow_back,
                  color: ZayColors.textPrimary,
                  size: 24,
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
    required this.tracking,
    required this.sheetSize,
    required this.minSheetSize,
    required this.initialSheetSize,
    required this.maxSheetSize,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final Order order;
  final TrackingModel tracking;
  final double sheetSize;
  final double minSheetSize;
  final double initialSheetSize;
  final double maxSheetSize;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double> onDragEnd;

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
              sheetSize: sheetSize,
              minSheetSize: minSheetSize,
              initialSheetSize: initialSheetSize,
              maxSheetSize: maxSheetSize,
              onDragUpdate: onDragUpdate,
              onDragEnd: onDragEnd,
            ),
            const SizedBox(height: 26),
            CourierCard(tracking: tracking),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 20),
                child: DeliveryProgress(tracking: tracking),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle({
    required this.sheetSize,
    required this.minSheetSize,
    required this.initialSheetSize,
    required this.maxSheetSize,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final double sheetSize;
  final double minSheetSize;
  final double initialSheetSize;
  final double maxSheetSize;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double> onDragEnd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (sheetSize < (initialSheetSize + maxSheetSize) / 2) {
          onDragEnd(-300);
          return;
        }
        onDragEnd(300);
      },
      onVerticalDragUpdate: (details) => onDragUpdate(details.delta.dy),
      onVerticalDragEnd: (details) => onDragEnd(details.primaryVelocity ?? 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
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
      ),
    );
  }
}
