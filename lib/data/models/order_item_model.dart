import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/data/models/product_model.dart';
import 'package:zayrova/domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required ProductModel super.product,
    required super.quantity,
    required super.unitPrice,
    super.selectedColor,
    super.selectedSize,
    super.selectedVariantId,
    super.currencyCode,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : json;
    final product = ProductModel.fromJson(productJson);

    return OrderItemModel(
      id: stringValue(json['id'] ?? product.id),
      product: product,
      quantity: intValue(json['quantity'], 1),
      unitPrice: doubleValue(json['unitPrice'] ?? json['price']),
      selectedColor: nullableString(json['selectedColor'] ?? json['color']),
      selectedSize: nullableString(json['selectedSize'] ?? json['size']),
      selectedVariantId: nullableString(json['selectedVariantId']),
      currencyCode: stringValue(json['currencyCode'], product.currencyCode),
    );
  }

  OrderItem toEntity() => this;

  Map<String, dynamic> toJson() {
    final productModel = product is ProductModel
        ? product as ProductModel
        : null;

    return {
      'id': id,
      'product': productModel?.toJson(),
      'productId': product.id,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
      'selectedVariantId': selectedVariantId,
      'currencyCode': currencyCode,
    };
  }
}
