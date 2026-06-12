import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<ApiResult<List<Product>>> getProducts({int? limit, int? skip});

  Future<ApiResult<Product>> getProductById(int id);

  Future<ApiResult<List<Product>>> searchProducts(
    String query, {
    int? limit,
    int? skip,
  });

  Future<ApiResult<List<Product>>> getProductsByCategory(
    String categorySlug, {
    int? limit,
    int? skip,
  });
}
