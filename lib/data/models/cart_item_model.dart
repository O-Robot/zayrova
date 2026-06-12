import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/data/models/product_model.dart';
import 'package:zayrova/domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required ProductModel super.product,
    required super.quantity,
    super.selectedColor,
    super.selectedSize,
    super.selectedVariantId,
    super.unitPrice,
    super.currencyCode,
    super.isSelected,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // DummyJSON cart products are partial product objects plus quantity totals.
    final product = ProductModel.fromJson(json);

    return CartItemModel(
      id: stringValue(json['cartItemId'] ?? json['id']),
      product: product,
      quantity: intValue(json['quantity'], 1),
      selectedColor: nullableString(json['selectedColor'] ?? json['color']),
      selectedSize: nullableString(json['selectedSize'] ?? json['size']),
      selectedVariantId: nullableString(json['selectedVariantId']),
      unitPrice: json.containsKey('price') ? doubleValue(json['price']) : null,
      currencyCode: nullableString(json['currencyCode']) ?? product.currencyCode,
      isSelected: boolValue(json['isSelected'], true),
    );
  }

  CartItem toEntity() => this;

  Map<String, dynamic> toJson() {
    final productModel = product is ProductModel
        ? product as ProductModel
        : null;

    return {
      'id': id,
      'product': productModel?.toJson(),
      'productId': product.id,
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
      'selectedVariantId': selectedVariantId,
      'unitPrice': unitPrice,
      'currencyCode': currencyCode,
      'isSelected': isSelected,
    };
  }
}
