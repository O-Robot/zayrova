import 'package:zayrova/domain/entities/product_entity.dart';

class CatalogFilterValues {
  const CatalogFilterValues({
    this.categoryName,
    this.minimumRating,
    this.sort = CatalogFilterSort.recommended,
    this.inStockOnly = false,
    this.minimumPrice = 0,
    this.maximumPrice = 3000,
  });

  final String? categoryName;
  final double? minimumRating;
  final CatalogFilterSort sort;
  final bool inStockOnly;
  final double minimumPrice;
  final double maximumPrice;

  bool get hasActiveFilters {
    return categoryName != null ||
        minimumRating != null ||
        sort != CatalogFilterSort.recommended ||
        inStockOnly ||
        minimumPrice > 0 ||
        maximumPrice < 3000;
  }

  int get activeCount {
    var count = 0;
    if (categoryName != null) count++;
    if (minimumRating != null) count++;
    if (sort != CatalogFilterSort.recommended) count++;
    if (inStockOnly) count++;
    if (minimumPrice > 0 || maximumPrice < 3000) count++;
    return count;
  }

  CatalogFilterValues copyWith({
    String? categoryName,
    double? minimumRating,
    CatalogFilterSort? sort,
    bool? inStockOnly,
    double? minimumPrice,
    double? maximumPrice,
    bool clearCategory = false,
    bool clearRating = false,
  }) {
    return CatalogFilterValues(
      categoryName: clearCategory ? null : categoryName ?? this.categoryName,
      minimumRating: clearRating ? null : minimumRating ?? this.minimumRating,
      sort: sort ?? this.sort,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      minimumPrice: minimumPrice ?? this.minimumPrice,
      maximumPrice: maximumPrice ?? this.maximumPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryName': categoryName,
      'minimumRating': minimumRating,
      'sort': sort.name,
      'inStockOnly': inStockOnly,
      'minimumPrice': minimumPrice,
      'maximumPrice': maximumPrice,
    };
  }

  factory CatalogFilterValues.fromMap(Map? map) {
    if (map == null) {
      return const CatalogFilterValues();
    }

    return CatalogFilterValues(
      categoryName: _nullableString(map['categoryName']),
      minimumRating: _nullableDouble(map['minimumRating']),
      sort: CatalogFilterSort.fromName(_nullableString(map['sort'])),
      inStockOnly: map['inStockOnly'] == true,
      minimumPrice: _doubleValue(map['minimumPrice'], 0),
      maximumPrice: _doubleValue(map['maximumPrice'], 3000),
    );
  }

  List<Product> applyTo(List<Product> products) {
    final normalizedCategory = categoryName?.trim().toLowerCase();
    final filtered = products.where((product) {
      if (normalizedCategory != null && normalizedCategory.isNotEmpty) {
        final productCategory = product.categoryName?.trim().toLowerCase();
        final productCategoryId = product.categoryId?.trim().toLowerCase();
        if (productCategory != normalizedCategory &&
            productCategoryId != normalizedCategory) {
          return false;
        }
      }

      if (product.price < minimumPrice || product.price > maximumPrice) {
        return false;
      }

      final rating = product.rating;
      if (minimumRating != null && (rating == null || rating < minimumRating!)) {
        return false;
      }

      if (inStockOnly) {
        final stock = product.stockQuantity;
        if (!product.isAvailable || (stock != null && stock <= 0)) {
          return false;
        }
      }

      return true;
    }).toList();

    switch (sort) {
      case CatalogFilterSort.recommended:
      case CatalogFilterSort.newest:
        return filtered;
      case CatalogFilterSort.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        return filtered;
      case CatalogFilterSort.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        return filtered;
      case CatalogFilterSort.highestRated:
        filtered.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        return filtered;
    }
  }

  static double _doubleValue(dynamic value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double? _nullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'All') {
      return null;
    }

    return text;
  }
}

enum CatalogFilterSort {
  recommended('Recommended'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  highestRated('Highest Rated'),
  newest('Newest');

  const CatalogFilterSort(this.label);

  final String label;

  static CatalogFilterSort fromLabel(String? label) {
    for (final sort in values) {
      if (sort.label == label) {
        return sort;
      }
    }

    return CatalogFilterSort.recommended;
  }

  static CatalogFilterSort fromName(String? name) {
    for (final sort in values) {
      if (sort.name == name) {
        return sort;
      }
    }

    return CatalogFilterSort.recommended;
  }
}
