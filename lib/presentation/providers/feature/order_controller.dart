import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/utils/local_storage.dart';
import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/domain/entities/cart_entity.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/domain/entities/order_item_entity.dart';
import 'package:zayrova/domain/entities/payment_method_entity.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
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
    unawaited(_loadPersistedOrders());
    return const OrderState();
  }

  String get _storageKey {
    final userId = ref.read(authControllerProvider).currentUser?.id;
    return 'zayrova_created_orders_${userId ?? 'guest'}';
  }

  Future<void> loadOrders({int? limit, int? skip}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getOrdersUseCaseProvider).call(
          limit: limit,
          skip: skip,
        );

    if (result.isSuccess && result.data != null) {
      final orders = _mergeOrders(state.orders, result.data!);
      state = state.copyWith(
        orders: orders,
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

  Future<void> loadOrderById(int id) {
    return loadOrderByIdentifier('$id');
  }

  Future<void> loadOrderByIdentifier(String identifier) async {
    final localOrder = _findOrderById(identifier);
    if (localOrder != null) {
      state = state.copyWith(
        selectedOrder: localOrder,
        isLoading: false,
        clearError: true,
      );
      return;
    }

    final id = int.tryParse(identifier);
    if (id == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load order.',
        clearSelectedOrder: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSelectedOrder: true,
    );

    final result = await ref.read(getOrderByIdUseCaseProvider).call(id);

    if (result.isSuccess && result.data != null) {
      final orders = _mergeOrders([result.data!], state.orders);
      state = state.copyWith(
        orders: orders,
        selectedOrder: result.data,
        isLoading: false,
      );
      unawaited(_persistOrders());
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load order.',
    );
  }

  Future<void> trackOrder(int id) {
    return trackOrderByIdentifier('$id');
  }

  Future<void> trackOrderByIdentifier(String identifier) async {
    final localOrder = _findOrderById(identifier);
    if (localOrder != null) {
      state = state.copyWith(
        trackedOrder: localOrder,
        isLoading: false,
        clearError: true,
      );
      return;
    }

    final id = int.tryParse(identifier);
    if (id == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to track order.',
        clearTrackedOrder: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearTrackedOrder: true,
    );

    final result = await ref.read(trackOrderUseCaseProvider).call(id);

    if (result.isSuccess && result.data != null) {
      final orders = _mergeOrders([result.data!], state.orders);
      state = state.copyWith(
        orders: orders,
        trackedOrder: result.data,
        isLoading: false,
      );
      unawaited(_persistOrders());
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

    // Keep the current cart-to-order API adaptation isolated here so a remote
    // order service can replace only this layer later.
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
        id: orderReference,
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
      unawaited(_persistOrders());
      return createdOrder;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to create order.',
    );
    return null;
  }

  Future<void> _loadPersistedOrders() async {
    final stored = await LocalStorage.get(_storageKey, Map);
    if (stored is! Map) {
      return;
    }

    final rawOrders = stored['orders'];
    final orders = rawOrders is List
        ? rawOrders
            .whereType<Map>()
            .map(_orderFromStorage)
            .whereType<Order>()
            .toList()
        : <Order>[];

    if (orders.isEmpty) {
      return;
    }

    state = state.copyWith(
      orders: _mergeOrders(orders, state.orders),
      hasLoadedOrders: state.hasLoadedOrders,
    );
  }

  Future<void> _persistOrders() {
    return LocalStorage.set(_storageKey, {
      'orders': state.orders.map(_orderToStorage).toList(),
    });
  }

  List<Order> _mergeOrders(List<Order> primary, List<Order> secondary) {
    final ordersById = <String, Order>{};
    for (final order in [...secondary, ...primary]) {
      ordersById[order.id] = order;
    }

    final orders = ordersById.values.toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  Order? _findOrderById(String id) {
    for (final order in state.orders) {
      if (order.id == id || order.orderNumber == id) {
        return order;
      }
    }

    return null;
  }

  String _generateOrderReference(String cartId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final normalizedCartId = cartId.isEmpty ? 'cart' : cartId;
    return 'ZYR-$normalizedCartId-$timestamp';
  }

  Map<String, dynamic> _orderToStorage(Order order) {
    return {
      'id': order.id,
      'orderNumber': order.orderNumber,
      'status': order.status.name,
      'currencyCode': order.currencyCode,
      'totalAmount': order.totalAmount,
      'subtotal': order.subtotal,
      'deliveryFee': order.deliveryFee,
      'discountAmount': order.discountAmount,
      'trackingNumber': order.trackingNumber,
      'createdAt': order.createdAt.toIso8601String(),
      'estimatedDeliveryAt': order.estimatedDeliveryAt?.toIso8601String(),
      'updatedAt': order.updatedAt?.toIso8601String(),
      'items': order.items.map(_orderItemToStorage).toList(),
      'shippingAddress': order.shippingAddress == null
          ? null
          : _addressPayload(order.shippingAddress!),
      'paymentMethod': order.paymentMethod == null
          ? null
          : _paymentMethodPayload(order.paymentMethod!),
    };
  }

  Order? _orderFromStorage(Map data) {
    final id = _stringOrNull(data['id']);
    final createdAt = _dateOrNull(data['createdAt']);
    final totalAmount = _doubleOrNull(data['totalAmount']);
    final rawItems = data['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map(_orderItemFromStorage)
            .whereType<OrderItem>()
            .toList()
        : <OrderItem>[];

    if (id == null || createdAt == null || totalAmount == null) {
      return null;
    }

    return Order(
      id: id,
      orderNumber: _stringOrNull(data['orderNumber']),
      items: items,
      status: _orderStatusFromName(_stringOrNull(data['status'])),
      currencyCode: _stringOrNull(data['currencyCode']) ?? 'USD',
      totalAmount: totalAmount,
      subtotal: _doubleOrNull(data['subtotal']),
      deliveryFee: _doubleOrNull(data['deliveryFee']),
      discountAmount: _doubleOrNull(data['discountAmount']),
      shippingAddress: data['shippingAddress'] is Map
          ? _addressFromStorage(data['shippingAddress'] as Map)
          : null,
      paymentMethod: data['paymentMethod'] is Map
          ? _paymentMethodFromStorage(data['paymentMethod'] as Map)
          : null,
      trackingNumber: _stringOrNull(data['trackingNumber']),
      createdAt: createdAt,
      estimatedDeliveryAt: _dateOrNull(data['estimatedDeliveryAt']),
      updatedAt: _dateOrNull(data['updatedAt']),
    );
  }

  Map<String, dynamic> _orderItemToStorage(OrderItem item) {
    return {
      'id': item.id,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'currencyCode': item.currencyCode,
      'selectedColor': item.selectedColor,
      'selectedSize': item.selectedSize,
      'selectedVariantId': item.selectedVariantId,
      'product': _productToStorage(item.product),
    };
  }

  OrderItem? _orderItemFromStorage(Map data) {
    final id = _stringOrNull(data['id']);
    final quantity = _intOrNull(data['quantity']);
    final unitPrice = _doubleOrNull(data['unitPrice']);
    final product = data['product'] is Map
        ? _productFromStorage(data['product'] as Map)
        : null;

    if (id == null || quantity == null || unitPrice == null || product == null) {
      return null;
    }

    return OrderItem(
      id: id,
      product: product,
      quantity: quantity,
      unitPrice: unitPrice,
      currencyCode: _stringOrNull(data['currencyCode']) ?? 'USD',
      selectedColor: _stringOrNull(data['selectedColor']),
      selectedSize: _stringOrNull(data['selectedSize']),
      selectedVariantId: _stringOrNull(data['selectedVariantId']),
    );
  }

  Map<String, dynamic> _productToStorage(Product product) {
    return {
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'categoryId': product.categoryId,
      'categoryName': product.categoryName,
      'brand': product.brand,
      'sku': product.sku,
      'currencyCode': product.currencyCode,
      'price': product.price,
      'discountPercentage': product.discountPercentage,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
      'stockQuantity': product.stockQuantity,
      'thumbnailUrl': product.thumbnailUrl,
      'imageUrls': product.imageUrls,
      'tags': product.tags,
      'availableColors': product.availableColors,
      'availableSizes': product.availableSizes,
      'isAvailable': product.isAvailable,
    };
  }

  Product? _productFromStorage(Map data) {
    final id = _stringOrNull(data['id']);
    final title = _stringOrNull(data['title']);
    final price = _doubleOrNull(data['price']);

    if (id == null || title == null || price == null) {
      return null;
    }

    return Product(
      id: id,
      title: title,
      description: _stringOrNull(data['description']),
      categoryId: _stringOrNull(data['categoryId']),
      categoryName: _stringOrNull(data['categoryName']),
      brand: _stringOrNull(data['brand']),
      sku: _stringOrNull(data['sku']),
      currencyCode: _stringOrNull(data['currencyCode']) ?? 'USD',
      price: price,
      discountPercentage: _doubleOrNull(data['discountPercentage']),
      rating: _doubleOrNull(data['rating']),
      reviewCount: _intOrNull(data['reviewCount']),
      stockQuantity: _intOrNull(data['stockQuantity']),
      thumbnailUrl: _stringOrNull(data['thumbnailUrl']),
      imageUrls: _stringList(data['imageUrls']),
      tags: _stringList(data['tags']),
      availableColors: _stringList(data['availableColors']),
      availableSizes: _stringList(data['availableSizes']),
      isAvailable: data['isAvailable'] != false,
    );
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

  Address? _addressFromStorage(Map data) {
    final id = _stringOrNull(data['id']);
    final label = _stringOrNull(data['label']);
    final addressLine1 = _stringOrNull(data['addressLine1']);
    final city = _stringOrNull(data['city']);
    final country = _stringOrNull(data['country']);

    if (id == null ||
        label == null ||
        addressLine1 == null ||
        city == null ||
        country == null) {
      return null;
    }

    return Address(
      id: id,
      label: label,
      recipientName: _stringOrNull(data['recipientName']),
      addressLine1: addressLine1,
      addressLine2: _stringOrNull(data['addressLine2']),
      city: city,
      state: _stringOrNull(data['state']),
      postalCode: _stringOrNull(data['postalCode']),
      country: country,
      phoneNumber: _stringOrNull(data['phoneNumber']),
      isDefault: data['isDefault'] == true,
    );
  }

  PaymentMethod? _paymentMethodFromStorage(Map data) {
    final id = _stringOrNull(data['id']);
    final title = _stringOrNull(data['title']);
    final typeName = _stringOrNull(data['type']);

    if (id == null || title == null || typeName == null) {
      return null;
    }

    return PaymentMethod(
      id: id,
      type: _paymentMethodTypeFromName(typeName),
      title: title,
      subtitle: _stringOrNull(data['subtitle']),
      provider: _stringOrNull(data['provider']),
      cardBrand: _stringOrNull(data['cardBrand']),
      lastFourDigits: _safeLastFour(_stringOrNull(data['lastFourDigits'])),
      expiryMonth: _intOrNull(data['expiryMonth']),
      expiryYear: _intOrNull(data['expiryYear']),
      isDefault: data['isDefault'] == true,
    );
  }

  PaymentMethodType _paymentMethodTypeFromName(String name) {
    for (final type in PaymentMethodType.values) {
      if (type.name == name) {
        return type;
      }
    }

    return PaymentMethodType.other;
  }

  OrderStatus _orderStatusFromName(String? name) {
    for (final status in OrderStatus.values) {
      if (status.name == name) {
        return status;
      }
    }

    return OrderStatus.pending;
  }

  DateTime? _dateOrNull(Object? value) {
    return value is String ? DateTime.tryParse(value) : null;
  }

  List<String> _stringList(Object? value) {
    return value is List ? value.whereType<String>().toList() : const [];
  }

  double? _doubleOrNull(Object? value) {
    return value is num ? value.toDouble() : null;
  }

  int? _intOrNull(Object? value) {
    return value is int ? value : null;
  }

  String? _stringOrNull(Object? value) {
    return value is String ? value : null;
  }

  String? _safeLastFour(String? value) {
    final digits = value?.replaceAll(RegExp(r'\D'), '');
    if (digits == null || digits.isEmpty) {
      return null;
    }

    return digits.length <= 4
        ? digits.padLeft(4, '*')
        : digits.substring(digits.length - 4);
  }
}
