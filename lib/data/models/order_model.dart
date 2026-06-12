import 'package:zayrova/data/models/address_model.dart';
import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/data/models/order_item_model.dart';
import 'package:zayrova/data/models/payment_method_model.dart';
import 'package:zayrova/domain/entities/address_entity.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/domain/entities/order_item_entity.dart';
import 'package:zayrova/domain/entities/payment_method_entity.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.items,
    required super.status,
    required super.totalAmount,
    required super.createdAt,
    super.orderNumber,
    super.currencyCode,
    super.subtotal,
    super.deliveryFee,
    super.discountAmount,
    super.shippingAddress,
    super.paymentMethod,
    super.trackingNumber,
    super.estimatedDeliveryAt,
    super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // DummyJSON carts can be adapted into order-like summaries later.
    final products = json['products'] is List ? json['products'] as List : [];
    final items = products
        .whereType<Map<String, dynamic>>()
        .map(OrderItemModel.fromJson)
        .toList();

    return OrderModel(
      id: stringValue(json['id']),
      orderNumber: nullableString(json['orderNumber']),
      items: items,
      status: _statusFromJson(json['status']),
      currencyCode: stringValue(json['currencyCode'], 'USD'),
      totalAmount: doubleValue(
        json['totalAmount'] ?? json['discountedTotal'] ?? json['total'],
      ),
      subtotal: json.containsKey('subtotal') || json.containsKey('total')
          ? doubleValue(json['subtotal'] ?? json['total'])
          : null,
      deliveryFee: json.containsKey('deliveryFee')
          ? doubleValue(json['deliveryFee'])
          : null,
      discountAmount: json.containsKey('discountAmount')
          ? doubleValue(json['discountAmount'])
          : null,
      shippingAddress: _addressFromJson(json['shippingAddress']),
      paymentMethod: _paymentMethodFromJson(json['paymentMethod']),
      trackingNumber: nullableString(json['trackingNumber']),
      createdAt: dateTimeValue(json['createdAt']),
      estimatedDeliveryAt: nullableDateTime(json['estimatedDeliveryAt']),
      updatedAt: nullableDateTime(json['updatedAt']),
    );
  }

  Order toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'items': items.map(_orderItemToJson).toList(),
      'status': enumName(status),
      'currencyCode': currencyCode,
      'totalAmount': totalAmount,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discountAmount': discountAmount,
      'shippingAddress': _addressToJson(shippingAddress),
      'paymentMethod': _paymentMethodToJson(paymentMethod),
      'trackingNumber': trackingNumber,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDeliveryAt': estimatedDeliveryAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static OrderStatus _statusFromJson(dynamic value) {
    final status = stringValue(value, 'pending').toLowerCase();

    switch (status) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
      case 'on_progress':
      case 'onprogress':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }

  static Address? _addressFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return AddressModel.fromJson(value);
    }

    return null;
  }

  static PaymentMethod? _paymentMethodFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return PaymentMethodModel.fromJson(value);
    }

    return null;
  }

  static Map<String, dynamic>? _addressToJson(Address? address) {
    if (address == null) {
      return null;
    }

    if (address is AddressModel) {
      return address.toJson();
    }

    return {
      'id': address.id,
      'label': address.label,
      'addressLine1': address.addressLine1,
      'addressLine2': address.addressLine2,
      'city': address.city,
      'state': address.state,
      'postalCode': address.postalCode,
      'country': address.country,
    };
  }

  static Map<String, dynamic>? _paymentMethodToJson(PaymentMethod? method) {
    if (method == null) {
      return null;
    }

    if (method is PaymentMethodModel) {
      return method.toJson();
    }

    return {
      'id': method.id,
      'type': enumName(method.type),
      'title': method.title,
      'subtitle': method.subtitle,
    };
  }

  static Map<String, dynamic> _orderItemToJson(OrderItem item) {
    if (item is OrderItemModel) {
      return item.toJson();
    }

    return {
      'id': item.id,
      'productId': item.product.id,
      'quantity': item.quantity,
      'unitPrice': item.unitPrice,
      'currencyCode': item.currencyCode,
    };
  }
}
