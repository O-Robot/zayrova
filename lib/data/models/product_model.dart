import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/domain/entities/product_entity.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.price,
    super.description,
    super.categoryId,
    super.categoryName,
    super.brand,
    super.sku,
    super.currencyCode,
    super.discountPercentage,
    super.rating,
    super.reviewCount,
    super.stockQuantity,
    super.thumbnailUrl,
    super.imageUrls,
    super.tags,
    super.availableColors,
    super.availableSizes,
    super.isFavorite,
    super.isAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = nullableString(json['category']);

    return ProductModel(
      id: stringValue(json['id']),
      title: stringValue(json['title'], 'Untitled product'),
      description: nullableString(json['description']),
      categoryId: category,
      categoryName: category,
      brand: nullableString(json['brand']),
      sku: nullableString(json['sku']),
      currencyCode: stringValue(json['currencyCode'], 'USD'),
      price: doubleValue(json['price']),
      discountPercentage: json.containsKey('discountPercentage')
          ? doubleValue(json['discountPercentage'])
          : null,
      rating: json.containsKey('rating') ? doubleValue(json['rating']) : null,
      reviewCount: _reviewCount(json['reviews']),
      stockQuantity: json.containsKey('stock') ? intValue(json['stock']) : null,
      thumbnailUrl: nullableString(json['thumbnail'] ?? json['thumbnailUrl']),
      imageUrls: stringListValue(json['images'] ?? json['imageUrls']),
      tags: stringListValue(json['tags']),
      // DummyJSON dimensions/reviews remain data-layer concerns for now.
      availableColors: stringListValue(json['availableColors']),
      availableSizes: stringListValue(json['availableSizes']),
      isFavorite: boolValue(json['isFavorite']),
      isAvailable: boolValue(json['isAvailable'], intValue(json['stock'], 1) > 0),
    );
  }

  Product toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': categoryName ?? categoryId,
      'brand': brand,
      'sku': sku,
      'currencyCode': currencyCode,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stockQuantity,
      'thumbnail': thumbnailUrl,
      'images': imageUrls,
      'tags': tags,
      'availableColors': availableColors,
      'availableSizes': availableSizes,
      'isFavorite': isFavorite,
      'isAvailable': isAvailable,
    };
  }

  static int? _reviewCount(dynamic reviews) {
    if (reviews is List) {
      return reviews.length;
    }

    return null;
  }
}
