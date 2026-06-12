import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/domain/entities/order_item_entity.dart';
import 'package:zayrova/domain/entities/payment_method_entity.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    this.orderNumber,
    this.currencyCode = 'USD',
    this.subtotal,
    this.deliveryFee,
    this.discountAmount,
    this.shippingAddress,
    this.paymentMethod,
    this.trackingNumber,
    this.estimatedDeliveryAt,
    this.updatedAt,
  });

  final String id;
  final String? orderNumber;
  final List<OrderItem> items;
  final OrderStatus status;
  final String currencyCode;
  final double totalAmount;
  final double? subtotal;
  final double? deliveryFee;
  final double? discountAmount;
  final Address? shippingAddress;
  final PaymentMethod? paymentMethod;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime? estimatedDeliveryAt;
  final DateTime? updatedAt;

  Order copyWith({
    String? id,
    String? orderNumber,
    List<OrderItem>? items,
    OrderStatus? status,
    String? currencyCode,
    double? totalAmount,
    double? subtotal,
    double? deliveryFee,
    double? discountAmount,
    Address? shippingAddress,
    PaymentMethod? paymentMethod,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? estimatedDeliveryAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      status: status ?? this.status,
      currencyCode: currencyCode ?? this.currencyCode,
      totalAmount: totalAmount ?? this.totalAmount,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discountAmount: discountAmount ?? this.discountAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt ?? this.createdAt,
      estimatedDeliveryAt: estimatedDeliveryAt ?? this.estimatedDeliveryAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
