import 'package:zayrova/domain/entities/cart_item_entity.dart';

class Cart {
  const Cart({
    required this.id,
    required this.userId,
    this.items = const [],
    this.total = 0,
    this.discountedTotal = 0,
    this.totalProducts = 0,
    this.totalQuantity = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String userId;
  final List<CartItem> items;
  final double total;
  final double discountedTotal;
  final int totalProducts;
  final int totalQuantity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;
}
