import 'package:zayrova/domain/entities/product_entity.dart';

class OrderItem {
  const OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.selectedColor,
    this.selectedSize,
    this.selectedVariantId,
    this.currencyCode = 'USD',
  });

  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;
  final String? selectedColor;
  final String? selectedSize;
  final String? selectedVariantId;
  final String currencyCode;

  double get subtotal => unitPrice * quantity;
}
