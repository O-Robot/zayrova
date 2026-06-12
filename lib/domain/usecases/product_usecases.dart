import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/domain/repositories/product_repository.dart';

class GetProductsUseCase {
  const GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<ApiResult<List<Product>>> call({int? limit, int? skip}) {
    return _repository.getProducts(limit: limit, skip: skip);
  }
}

class GetProductByIdUseCase {
  const GetProductByIdUseCase(this._repository);

  final ProductRepository _repository;

  Future<ApiResult<Product>> call(int id) {
    return _repository.getProductById(id);
  }
}

class SearchProductsUseCase {
  const SearchProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<ApiResult<List<Product>>> call(
    String query, {
    int? limit,
    int? skip,
  }) {
    return _repository.searchProducts(query, limit: limit, skip: skip);
  }
}

class GetProductsByCategoryUseCase {
  const GetProductsByCategoryUseCase(this._repository);

  final ProductRepository _repository;

  Future<ApiResult<List<Product>>> call(
    String categorySlug, {
    int? limit,
    int? skip,
  }) {
    return _repository.getProductsByCategory(
      categorySlug,
      limit: limit,
      skip: skip,
    );
  }
}
