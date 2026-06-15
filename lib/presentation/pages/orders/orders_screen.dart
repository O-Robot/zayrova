import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/constants/colors.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/presentation/components/bottom_navigation.dart';
import 'package:zayrova/presentation/components/empty_state.dart';
import 'package:zayrova/presentation/components/error_state.dart';
import 'package:zayrova/presentation/components/loading_state.dart';
import 'package:zayrova/presentation/pages/orders/order_components.dart';
import 'package:zayrova/presentation/providers/feature/order_controller.dart';
import 'package:zayrova/presentation/routes/zay_router.dart';
import 'package:zayrova/presentation/routes/zay_routes.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  late int selectedTab;

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() {
    return ref.read(orderControllerProvider.notifier).loadOrders(limit: 20);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderControllerProvider);
    final visibleOrders =
        selectedTab == 0 ? state.activeOrders : state.historyOrders;

    return Scaffold(
      backgroundColor: ZayColors.white,
      bottomNavigationBar: const BottomNavigation(),
      body: SafeArea(
        child: Column(
          children: [
            const OrderHeader(title: 'My Order', showBack: false),
            const SizedBox(height: 42),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: OrderTabs(
                selectedIndex: selectedTab,
                onChanged: (index) => setState(() => selectedTab = index),
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: _OrdersBody(
                state: state,
                orders: visibleOrders,
                isHistory: selectedTab == 1,
                onRetry: _loadOrders,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersBody extends StatelessWidget {
  const _OrdersBody({
    required this.state,
    required this.orders,
    required this.isHistory,
    required this.onRetry,
  });

  final OrderState state;
  final List<Order> orders;
  final bool isHistory;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasLoadedOrders) {
      return const LoadingStateWidget(message: 'Loading orders...');
    }

    if (state.hasError && !state.hasLoadedOrders) {
      return ErrorStateWidget(
        title: 'Orders unavailable',
        message: state.errorMessage ?? 'Unable to load orders.',
        onRetry: () => onRetry(),
      );
    }

    if (orders.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.local_shipping_outlined,
        title: isHistory ? 'No order history' : 'No active orders',
        message: isHistory
            ? 'Completed and cancelled orders will appear here.'
            : 'Orders you place will appear here while they are in progress.',
        actionText: 'Refresh',
        onAction: () => onRetry(),
      );
    }

    return RefreshIndicator(
      color: ZayColors.primary,
      onRefresh: onRetry,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        itemBuilder: (context, index) {
          final order = orders[index];

          return OrderCard(
            order: order,
            primaryActionText: isHistory ? 'Received Order' : 'Tracking',
            onDetail: () => ZayRouter.goto(ZayRoutes.orderDetails, {
              'orderId': order.id,
            }),
            onPrimaryAction: () => ZayRouter.goto(
              isHistory ? ZayRoutes.orderDetails : ZayRoutes.orderTracking,
              {'orderId': order.id},
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemCount: orders.length,
      ),
    );
  }
}
