import 'package:zayrova/domain/entities/product_entity.dart';

class CartItem {
  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.selectedColor,
    this.selectedSize,
    this.selectedVariantId,
    this.unitPrice,
    this.currencyCode,
    this.isSelected = true,
  });

  final String id;
  final Product product;
  final int quantity;
  final String? selectedColor;
  final String? selectedSize;
  final String? selectedVariantId;
  final double? unitPrice;
  final String? currencyCode;
  final bool isSelected;

  double get subtotal => (unitPrice ?? product.price) * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedColor,
    String? selectedSize,
    String? selectedVariantId,
    double? unitPrice,
    String? currencyCode,
    bool? isSelected,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
      selectedVariantId: selectedVariantId ?? this.selectedVariantId,
      unitPrice: unitPrice ?? this.unitPrice,
      currencyCode: currencyCode ?? this.currencyCode,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
