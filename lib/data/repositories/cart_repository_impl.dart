import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/data/datasources/cart_remote_datasource.dart';
import 'package:zayrova/data/repositories/repository_result_guard.dart';
import 'package:zayrova/domain/entities/cart_entity.dart';
import 'package:zayrova/domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  const CartRepositoryImpl(this._remoteDatasource);

  final CartRemoteDatasource _remoteDatasource;

  @override
  Future<ApiResult<List<Cart>>> getCarts({int? limit, int? skip}) {
    return guardRepositoryCall(() async {
      final carts = await _remoteDatasource.getCarts(
        limit: limit,
        skip: skip,
      );
      return carts.map((cart) => cart.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<Cart>> getCartById(int id) {
    return guardRepositoryCall(() async {
      final cart = await _remoteDatasource.getCartById(id);
      return cart.toEntity();
    });
  }

  @override
  Future<ApiResult<Cart>> getUserCart(int userId) {
    return guardRepositoryCall(() async {
      final cart = await _remoteDatasource.getUserCart(userId);
      return cart.toEntity();
    });
  }

  @override
  Future<ApiResult<Cart>> addToCart({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) {
    return guardRepositoryCall(() async {
      final cart = await _remoteDatasource.addToCart(
        userId: userId,
        products: products,
      );
      return cart.toEntity();
    });
  }

  @override
  Future<ApiResult<Cart>> updateCart({
    required int cartId,
    required List<Map<String, dynamic>> products,
    bool merge = true,
  }) {
    return guardRepositoryCall(() async {
      final cart = await _remoteDatasource.updateCart(
        cartId: cartId,
        products: products,
        merge: merge,
      );
      return cart.toEntity();
    });
  }

  @override
  Future<ApiResult<bool>> deleteCart(int cartId) {
    return guardRepositoryCall(() => _remoteDatasource.deleteCart(cartId));
  }
}
