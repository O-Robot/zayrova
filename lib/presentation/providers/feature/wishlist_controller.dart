import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/core/utils/local_storage.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';

final wishlistControllerProvider =
    NotifierProvider<WishlistController, WishlistState>(
  WishlistController.new,
);

class WishlistState {
  const WishlistState({
    this.productsById = const {},
  });

  final Map<String, Product> productsById;

  List<Product> get products => productsById.values.toList();

  bool contains(String productId) {
    return productsById.containsKey(productId);
  }

  WishlistState copyWith({
    Map<String, Product>? productsById,
  }) {
    return WishlistState(
      productsById: productsById ?? this.productsById,
    );
  }
}

class WishlistController extends Notifier<WishlistState> {
  @override
  WishlistState build() {
    unawaited(_loadPersistedState());
    return const WishlistState();
  }

  String get _storageKey {
    final userId = ref.read(authControllerProvider).currentUser?.id;
    return 'zayrova_wishlist_products_${userId ?? 'guest'}';
  }

  void addProduct(Product product) {
    state = state.copyWith(
      productsById: {
        ...state.productsById,
        product.id: product,
      },
    );
    unawaited(_persistState());
  }

  void removeProduct(String productId) {
    final updated = {...state.productsById};
    updated.remove(productId);
    state = state.copyWith(productsById: updated);
    unawaited(_persistState());
  }

  void toggleProduct(Product product) {
    if (state.contains(product.id)) {
      removeProduct(product.id);
      return;
    }

    addProduct(product);
  }

  Future<void> _loadPersistedState() async {
    final stored = await LocalStorage.get(_storageKey, Map);
    if (stored is! Map) {
      return;
    }

    final rawProducts = stored['products'];
    final products = rawProducts is List
        ? rawProducts
            .whereType<Map>()
            .map(_productFromStorage)
            .whereType<Product>()
            .toList()
        : <Product>[];

    state = state.copyWith(
      productsById: {
        for (final product in products) product.id: product,
      },
    );
  }

  Future<void> _persistState() {
    return LocalStorage.set(_storageKey, {
      'products': state.products.map(_productToStorage).toList(),
    });
  }

  Map<String, dynamic> _productToStorage(Product product) {
    return {
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'categoryId': product.categoryId,
      'categoryName': product.categoryName,
      'brand': product.brand,
      'sku': product.sku,
      'currencyCode': product.currencyCode,
      'price': product.price,
      'discountPercentage': product.discountPercentage,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
      'stockQuantity': product.stockQuantity,
      'thumbnailUrl': product.thumbnailUrl,
      'imageUrls': product.imageUrls,
      'tags': product.tags,
      'availableColors': product.availableColors,
      'availableSizes': product.availableSizes,
      'isAvailable': product.isAvailable,
    };
  }

  Product? _productFromStorage(Map data) {
    final id = _stringOrNull(data['id']);
    final title = _stringOrNull(data['title']);
    final price = _doubleOrNull(data['price']);

    if (id == null || title == null || price == null) {
      return null;
    }

    return Product(
      id: id,
      title: title,
      description: _stringOrNull(data['description']),
      categoryId: _stringOrNull(data['categoryId']),
      categoryName: _stringOrNull(data['categoryName']),
      brand: _stringOrNull(data['brand']),
      sku: _stringOrNull(data['sku']),
      currencyCode: _stringOrNull(data['currencyCode']) ?? 'USD',
      price: price,
      discountPercentage: _doubleOrNull(data['discountPercentage']),
      rating: _doubleOrNull(data['rating']),
      reviewCount: _intOrNull(data['reviewCount']),
      stockQuantity: _intOrNull(data['stockQuantity']),
      thumbnailUrl: _stringOrNull(data['thumbnailUrl']),
      imageUrls: _stringList(data['imageUrls']),
      tags: _stringList(data['tags']),
      availableColors: _stringList(data['availableColors']),
      availableSizes: _stringList(data['availableSizes']),
      isFavorite: true,
      isAvailable: data['isAvailable'] != false,
    );
  }

  List<String> _stringList(Object? value) {
    return value is List ? value.whereType<String>().toList() : const [];
  }

  double? _doubleOrNull(Object? value) {
    return value is num ? value.toDouble() : null;
  }

  int? _intOrNull(Object? value) {
    return value is int ? value : null;
  }

  String? _stringOrNull(Object? value) {
    return value is String ? value : null;
  }
}
