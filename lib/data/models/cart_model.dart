import 'package:zayrova/data/models/cart_item_model.dart';
import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/domain/entities/cart_entity.dart';
import 'package:zayrova/domain/entities/cart_item_entity.dart';

class CartModel extends Cart {
  const CartModel({
    required super.id,
    required super.userId,
    super.items,
    super.total,
    super.discountedTotal,
    super.totalProducts,
    super.totalQuantity,
    super.createdAt,
    super.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // DummyJSON cart responses include cart totals and a `products` array.
    final products = json['products'] is List ? json['products'] as List : [];
    final items = products
        .whereType<Map<String, dynamic>>()
        .map(CartItemModel.fromJson)
        .toList();

    return CartModel(
      id: stringValue(json['id']),
      userId: stringValue(json['userId']),
      items: items,
      total: doubleValue(json['total']),
      discountedTotal: doubleValue(json['discountedTotal'] ?? json['total']),
      totalProducts: intValue(json['totalProducts'], items.length),
      totalQuantity: intValue(
        json['totalQuantity'],
        items.fold<int>(0, (total, item) => total + item.quantity),
      ),
      createdAt: nullableDateTime(json['createdAt']),
      updatedAt: nullableDateTime(json['updatedAt']),
    );
  }

  Cart toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'products': items.map(_cartItemToJson).toList(),
      'total': total,
      'discountedTotal': discountedTotal,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic> _cartItemToJson(CartItem item) {
    if (item is CartItemModel) {
      return item.toJson();
    }

    return {
      'id': item.id,
      'productId': item.product.id,
      'quantity': item.quantity,
      'selectedColor': item.selectedColor,
      'selectedSize': item.selectedSize,
      'selectedVariantId': item.selectedVariantId,
      'unitPrice': item.unitPrice,
      'currencyCode': item.currencyCode,
      'isSelected': item.isSelected,
    };
  }
}
