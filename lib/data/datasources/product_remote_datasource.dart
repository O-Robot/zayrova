import 'package:zayrova/config/api_constants.dart';
import 'package:zayrova/core/services/network/api_client.dart';
import 'package:zayrova/data/models/product_model.dart';

class ProductRemoteDatasource {
  const ProductRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ProductModel>> getProducts({
    int? limit,
    int? skip,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.products,
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (skip != null) 'skip': skip,
      },
    );

    return _productsFromResponse(response);
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await _apiClient.get(ApiConstants.productById(id));
    return ProductModel.fromJson(_mapFromResponse(response));
  }

  Future<List<ProductModel>> searchProducts(
    String query, {
    int? limit,
    int? skip,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.productSearch,
      queryParameters: {
        'q': query,
        if (limit != null) 'limit': limit,
        if (skip != null) 'skip': skip,
      },
    );

    return _productsFromResponse(response);
  }

  Future<List<ProductModel>> getProductsByCategory(
    String categorySlug, {
    int? limit,
    int? skip,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.productsByCategory(categorySlug),
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (skip != null) 'skip': skip,
      },
    );

    return _productsFromResponse(response);
  }

  List<ProductModel> _productsFromResponse(dynamic response) {
    final source = response is Map<String, dynamic>
        ? response['products']
        : response;

    if (source is! List) {
      return const [];
    }

    return source
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();
  }

  Map<String, dynamic> _mapFromResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    return const {};
  }
}
