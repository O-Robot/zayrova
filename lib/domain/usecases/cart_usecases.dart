import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/cart_entity.dart';
import 'package:zayrova/domain/repositories/cart_repository.dart';

class GetCartsUseCase {
  const GetCartsUseCase(this._repository);

  final CartRepository _repository;

  Future<ApiResult<List<Cart>>> call({int? limit, int? skip}) {
    return _repository.getCarts(limit: limit, skip: skip);
  }
}

class GetCartByIdUseCase {
  const GetCartByIdUseCase(this._repository);

  final CartRepository _repository;

  Future<ApiResult<Cart>> call(int id) {
    return _repository.getCartById(id);
  }
}

class GetUserCartUseCase {
  const GetUserCartUseCase(this._repository);

  final CartRepository _repository;

  Future<ApiResult<Cart>> call(int userId) {
    return _repository.getUserCart(userId);
  }
}

class AddToCartUseCase {
  const AddToCartUseCase(this._repository);

  final CartRepository _repository;

  Future<ApiResult<Cart>> call({
    required int userId,
    required List<Map<String, dynamic>> products,
  }) {
    return _repository.addToCart(userId: userId, products: products);
  }
}

class UpdateCartUseCase {
  const UpdateCartUseCase(this._repository);

  final CartRepository _repository;

  Future<ApiResult<Cart>> call({
    required int cartId,
    required List<Map<String, dynamic>> products,
    bool merge = true,
  }) {
    return _repository.updateCart(
      cartId: cartId,
      products: products,
      merge: merge,
    );
  }
}

class DeleteCartUseCase {
  const DeleteCartUseCase(this._repository);

  final CartRepository _repository;

  Future<ApiResult<bool>> call(int cartId) {
    return _repository.deleteCart(cartId);
  }
}
