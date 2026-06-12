import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<ApiResult<List<List<CartItem>>>> getCarts({int? limit, int? skip});

  Future<ApiResult<List<CartItem>>> getCartById(int id);

  Future<ApiResult<List<CartItem>>> getUserCart(int userId);

  Future<ApiResult<List<CartItem>>> addToCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  });

  Future<ApiResult<List<CartItem>>> updateCart({
    required int cartId,
    required List<Map<String, dynamic>> products,
    bool merge = true,
  });

  Future<ApiResult<bool>> deleteCart(int cartId);
}
