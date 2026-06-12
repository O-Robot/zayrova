import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/cart_entity.dart';

abstract class CartRepository {
  Future<ApiResult<List<Cart>>> getCarts({int? limit, int? skip});

  Future<ApiResult<Cart>> getCartById(int id);

  Future<ApiResult<Cart>> getUserCart(int userId);

  Future<ApiResult<Cart>> addToCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  });

  Future<ApiResult<Cart>> updateCart({
    required int cartId,
    required List<Map<String, dynamic>> products,
    bool merge = true,
  });

  Future<ApiResult<bool>> deleteCart(int cartId);
}
