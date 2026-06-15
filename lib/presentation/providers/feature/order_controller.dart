import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/presentation/providers/usecase_providers.dart';

final orderControllerProvider =
    NotifierProvider<OrderController, OrderState>(OrderController.new);

class OrderState {
  const OrderState({
    this.orders = const [],
    this.selectedOrder,
    this.trackedOrder,
    this.isLoading = false,
    this.errorMessage,
    this.hasLoadedOrders = false,
  });

  final List<Order> orders;
  final Order? selectedOrder;
  final Order? trackedOrder;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoadedOrders;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  List<Order> get activeOrders {
    return orders.where((order) {
      return order.status != OrderStatus.delivered &&
          order.status != OrderStatus.cancelled &&
          order.status != OrderStatus.refunded;
    }).toList();
  }

  List<Order> get historyOrders {
    return orders.where((order) {
      return order.status == OrderStatus.delivered ||
          order.status == OrderStatus.cancelled ||
          order.status == OrderStatus.refunded;
    }).toList();
  }

  OrderState copyWith({
    List<Order>? orders,
    Order? selectedOrder,
    Order? trackedOrder,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoadedOrders,
    bool clearSelectedOrder = false,
    bool clearTrackedOrder = false,
    bool clearError = false,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      selectedOrder:
          clearSelectedOrder ? null : selectedOrder ?? this.selectedOrder,
      trackedOrder: clearTrackedOrder ? null : trackedOrder ?? this.trackedOrder,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      hasLoadedOrders: hasLoadedOrders ?? this.hasLoadedOrders,
    );
  }
}

class OrderController extends Notifier<OrderState> {
  @override
  OrderState build() {
    return const OrderState();
  }

  Future<void> loadOrders({int? limit, int? skip}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getOrdersUseCaseProvider).call(
          limit: limit,
          skip: skip,
        );

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(
        orders: result.data,
        isLoading: false,
        hasLoadedOrders: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load orders.',
      hasLoadedOrders: true,
    );
  }

  Future<void> loadOrderById(int id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSelectedOrder: true,
    );

    final result = await ref.read(getOrderByIdUseCaseProvider).call(id);

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(selectedOrder: result.data, isLoading: false);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load order.',
    );
  }

  Future<void> trackOrder(int id) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearTrackedOrder: true,
    );

    final result = await ref.read(trackOrderUseCaseProvider).call(id);

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(trackedOrder: result.data, isLoading: false);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to track order.',
    );
  }
}
