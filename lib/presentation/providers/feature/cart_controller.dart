import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/entities/cart_entity.dart';
import 'package:zayrova/presentation/providers/feature/auth_controller.dart';
import 'package:zayrova/presentation/providers/usecase_providers.dart';

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

const int _publicApiFallbackCartUserId = 1;

class CartState {
  const CartState({
    this.carts = const [],
    this.selectedCart,
    this.userCart,
    this.isLoading = false,
    this.errorMessage,
    this.hasLoadedCarts = false,
    this.hasLoadedSelectedCart = false,
    this.hasLoadedUserCart = false,
  });

  final List<Cart> carts;
  final Cart? selectedCart;
  final Cart? userCart;
  final bool isLoading;
  final String? errorMessage;
  final bool hasLoadedCarts;
  final bool hasLoadedSelectedCart;
  final bool hasLoadedUserCart;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  bool get areCartsEmpty => hasLoadedCarts && carts.isEmpty;

  bool get isSelectedCartEmpty {
    return hasLoadedSelectedCart &&
        (selectedCart == null || selectedCart!.isEmpty);
  }

  bool get isUserCartEmpty {
    return hasLoadedUserCart && (userCart == null || userCart!.isEmpty);
  }

  CartState copyWith({
    List<Cart>? carts,
    Cart? selectedCart,
    Cart? userCart,
    bool? isLoading,
    String? errorMessage,
    bool? hasLoadedCarts,
    bool? hasLoadedSelectedCart,
    bool? hasLoadedUserCart,
    bool clearSelectedCart = false,
    bool clearUserCart = false,
    bool clearError = false,
  }) {
    return CartState(
      carts: carts ?? this.carts,
      selectedCart: clearSelectedCart
          ? null
          : selectedCart ?? this.selectedCart,
      userCart: clearUserCart ? null : userCart ?? this.userCart,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      hasLoadedCarts: hasLoadedCarts ?? this.hasLoadedCarts,
      hasLoadedSelectedCart:
          hasLoadedSelectedCart ?? this.hasLoadedSelectedCart,
      hasLoadedUserCart: hasLoadedUserCart ?? this.hasLoadedUserCart,
    );
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    return const CartState();
  }

  Future<void> loadCarts({int? limit, int? skip}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getCartsUseCaseProvider).call(
      limit: limit,
      skip: skip,
    );

    if (result.isSuccess) {
      state = state.copyWith(
        carts: result.data ?? const [],
        isLoading: false,
        hasLoadedCarts: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load carts.',
    );
  }

  Future<void> loadCartById(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getCartByIdUseCaseProvider).call(id);

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(
        selectedCart: result.data,
        isLoading: false,
        hasLoadedSelectedCart: true,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load cart.',
    );
  }

  Future<void> loadUserCart(int userId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(getUserCartUseCaseProvider).call(userId);

    if (result.isSuccess) {
      state = state.copyWith(
        userCart: result.data,
        isLoading: false,
        hasLoadedUserCart: true,
        clearUserCart: result.data == null,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to load user cart.',
    );
  }

  int currentCartOwnerId() {
    final currentUserId = ref.read(authControllerProvider).currentUser?.id;
    return int.tryParse(currentUserId ?? '') ?? _publicApiFallbackCartUserId;
  }

  Future<void> loadCurrentUserCart() {
    return loadUserCart(currentCartOwnerId());
  }

  Future<void> addToCurrentUserCart({
    required List<Map<String, dynamic>> products,
  }) {
    return addToCart(
      userId: currentCartOwnerId(),
      products: products,
    );
  }

  Future<void> addToCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(addToCartUseCaseProvider).call(
      userId: userId,
      products: products,
    );

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(userCart: result.data, isLoading: false);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to add product to cart.',
    );
  }

  Future<void> updateCart({
    required int cartId,
    required List<Map<String, dynamic>> products,
    bool merge = true,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(updateCartUseCaseProvider).call(
      cartId: cartId,
      products: products,
      merge: merge,
    );

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(
        selectedCart: result.data,
        userCart: result.data,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to update cart.',
    );
  }

  Future<void> deleteCart(int cartId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(deleteCartUseCaseProvider).call(cartId);

    if (result.isSuccess && result.data == true) {
      state = state.copyWith(
        carts: state.carts.where((cart) => cart.id != '$cartId').toList(),
        isLoading: false,
        clearSelectedCart: state.selectedCart?.id == '$cartId',
        clearUserCart: state.userCart?.id == '$cartId',
      );
      return;
    }

    state = state.copyWith(
      isLoading: false,
      errorMessage: result.message ?? 'Unable to delete cart.',
    );
  }
}
