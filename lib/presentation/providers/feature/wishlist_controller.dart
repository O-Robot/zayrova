import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/entities/product_entity.dart';

final wishlistControllerProvider =
    NotifierProvider<WishlistController, WishlistState>(
  WishlistController.new,
);

class WishlistState {
  const WishlistState({
    this.productsById = const {},
  });

  // Temporary in-memory wishlist until profile/wishlist persistence APIs exist.
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
    return const WishlistState();
  }

  void addProduct(Product product) {
    state = state.copyWith(
      productsById: {
        ...state.productsById,
        product.id: product,
      },
    );
  }

  void removeProduct(String productId) {
    final updated = {...state.productsById};
    updated.remove(productId);
    state = state.copyWith(productsById: updated);
  }

  void toggleProduct(Product product) {
    if (state.contains(product.id)) {
      removeProduct(product.id);
      return;
    }

    addProduct(product);
  }
}
