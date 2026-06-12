class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    this.description,
    this.categoryId,
    this.categoryName,
    this.brand,
    this.sku,
    this.currencyCode = 'USD',
    this.discountPercentage,
    this.rating,
    this.reviewCount,
    this.stockQuantity,
    this.thumbnailUrl,
    this.imageUrls = const [],
    this.tags = const [],
    this.availableColors = const [],
    this.availableSizes = const [],
    this.isFavorite = false,
    this.isAvailable = true,
  });

  final String id;
  final String title;
  final String? description;
  final String? categoryId;
  final String? categoryName;
  final String? brand;
  final String? sku;
  final String currencyCode;
  final double price;
  final double? discountPercentage;
  final double? rating;
  final int? reviewCount;
  final int? stockQuantity;
  final String? thumbnailUrl;
  final List<String> imageUrls;
  final List<String> tags;
  final List<String> availableColors;
  final List<String> availableSizes;
  final bool isFavorite;
  final bool isAvailable;
}
