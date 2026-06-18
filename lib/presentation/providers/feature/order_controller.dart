import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/domain/entities/cart_entity.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/domain/entities/payment_method_entity.dart';
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

  Future<Order?> createOrderFromCheckout({
    required Cart cart,
    required Address shippingAddress,
    required PaymentMethod paymentMethod,
    double deliveryFee = 0,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final orderReference = _generateOrderReference(cart.id);
    final discountAmount =
        cart.discountedTotal > 0 && cart.discountedTotal < cart.total
            ? cart.total - cart.discountedTotal
            : 0.0;
    final payableTotal =
        (cart.discountedTotal > 0 && cart.discountedTotal < cart.total
                ? cart.discountedTotal
                : cart.total) +
            deliveryFee;

    // DummyJSON has carts but no real orders endpoint. Keep this temporary
    // checkout-to-cart adaptation isolated here until an order API exists.
    final result = await ref.read(createOrderUseCaseProvider).call({
          'userId': int.tryParse(cart.userId) ?? 1,
          'products': cart.items
              .map(
                (item) => {
                  'id': int.tryParse(item.product.id) ?? item.product.id,
                  'quantity': item.quantity,
                },
              )
              .toList(),
          'orderNumber': orderReference,
          'status': 'pending',
          'subtotal': cart.total,
          'deliveryFee': deliveryFee,
          'discountAmount': discountAmount,
          'totalAmount': payableTotal,
          'shippingAddress': _addressPayload(shippingAddress),
          'paymentMethod': _paymentMethodPayload(paymentMethod),
        });

    if (result.isSuccess && result.data != null) {
      final createdOrder = result.data!.copyWith(
        orderNumber: result.data!.orderNumber ?? orderReference,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        subtotal: cart.total,
        deliveryFee: deliveryFee,
        discountAmount: discountAmount,
        totalAmount: payableTotal,
        status: OrderStatus.pending,
      );

      state = state.copyWith(
        orders: [createdOrder, ...state.orders],
        selectedOrder: createdOrder,
        isLoading: false,
      );
      return createdOrder;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to create order.',
    );
    return null;
  }

  String _generateOrderReference(String cartId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final normalizedCartId = cartId.isEmpty ? 'cart' : cartId;
    return 'ZYR-$normalizedCartId-$timestamp';
  }

  Map<String, dynamic> _addressPayload(Address address) {
    return {
      'id': address.id,
      'label': address.label,
      'recipientName': address.recipientName,
      'addressLine1': address.addressLine1,
      'addressLine2': address.addressLine2,
      'city': address.city,
      'state': address.state,
      'postalCode': address.postalCode,
      'country': address.country,
      'phoneNumber': address.phoneNumber,
      'isDefault': address.isDefault,
    };
  }

  Map<String, dynamic> _paymentMethodPayload(PaymentMethod method) {
    return {
      'id': method.id,
      'type': method.type.name,
      'title': method.title,
      'subtitle': method.subtitle,
      'provider': method.provider,
      'cardBrand': method.cardBrand,
      'lastFourDigits': method.lastFourDigits,
      'expiryMonth': method.expiryMonth,
      'expiryYear': method.expiryYear,
      'isDefault': method.isDefault,
    };
  }
}
