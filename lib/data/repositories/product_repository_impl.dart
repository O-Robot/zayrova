import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/data/datasources/product_remote_datasource.dart';
import 'package:zayrova/data/repositories/repository_result_guard.dart';
import 'package:zayrova/domain/entities/product_entity.dart';
import 'package:zayrova/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remoteDatasource);

  final ProductRemoteDatasource _remoteDatasource;

  @override
  Future<ApiResult<List<Product>>> getProducts({int? limit, int? skip}) {
    return guardRepositoryCall(() async {
      final products = await _remoteDatasource.getProducts(
        limit: limit,
        skip: skip,
      );
      return products.map((product) => product.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<Product>> getProductById(int id) {
    return guardRepositoryCall(() async {
      final product = await _remoteDatasource.getProductById(id);
      return product.toEntity();
    });
  }

  @override
  Future<ApiResult<List<Product>>> searchProducts(
    String query, {
    int? limit,
    int? skip,
  }) {
    return guardRepositoryCall(() async {
      final products = await _remoteDatasource.searchProducts(
        query,
        limit: limit,
        skip: skip,
      );
      return products.map((product) => product.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<List<Product>>> getProductsByCategory(
    String categorySlug, {
    int? limit,
    int? skip,
  }) {
    return guardRepositoryCall(() async {
      final products = await _remoteDatasource.getProductsByCategory(
        categorySlug,
        limit: limit,
        skip: skip,
      );
      return products.map((product) => product.toEntity()).toList();
    });
  }
}
