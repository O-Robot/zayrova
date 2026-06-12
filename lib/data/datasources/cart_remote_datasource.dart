import 'package:zayrova/config/api_constants.dart';
import 'package:zayrova/core/services/network/api_client.dart';
import 'package:zayrova/data/models/cart_item_model.dart';

class CartRemoteDatasource {
  const CartRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<List<CartItemModel>>> getCarts({
    int? limit,
    int? skip,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.carts,
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (skip != null) 'skip': skip,
      },
    );
    final carts = response is Map<String, dynamic> ? response['carts'] : null;

    if (carts is! List) {
      return const [];
    }

    return carts
        .whereType<Map<String, dynamic>>()
        .map(_cartItemsFromResponse)
        .toList();
  }

  Future<List<CartItemModel>> getCartById(int id) async {
    final response = await _apiClient.get(ApiConstants.cartById(id));
    return _cartItemsFromResponse(response);
  }

  Future<List<CartItemModel>> getUserCart(int userId) async {
    final response = await _apiClient.get(ApiConstants.cartsByUser(userId));
    final carts = response is Map<String, dynamic> ? response['carts'] : null;

    if (carts is List && carts.isNotEmpty) {
      final firstCart = carts.first;
      return _cartItemsFromResponse(firstCart);
    }

    return _cartItemsFromResponse(response);
  }

  Future<List<CartItemModel>> addToCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.addCart,
      body: {'userId': userId, 'products': products},
    );

    return _cartItemsFromResponse(response);
  }

  Future<List<CartItemModel>> updateCart({
    required int cartId,
    required List<Map<String, dynamic>> products,
    bool merge = true,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.cartById(cartId),
      body: {'merge': merge, 'products': products},
    );

    return _cartItemsFromResponse(response);
  }

  Future<bool> deleteCart(int cartId) async {
    final response = await _apiClient.delete(ApiConstants.cartById(cartId));

    if (response is Map<String, dynamic>) {
      return response['isDeleted'] == true || response['deletedOn'] != null;
    }

    return false;
  }

  List<CartItemModel> _cartItemsFromResponse(dynamic response) {
    final source = response is Map<String, dynamic>
        ? response['products']
        : response;

    if (source is! List) {
      return const [];
    }

    return source
        .whereType<Map<String, dynamic>>()
        .map(CartItemModel.fromJson)
        .toList();
  }
}
