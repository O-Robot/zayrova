import 'package:zayrova/config/api_constants.dart';
import 'package:zayrova/core/services/network/api_client.dart';
import 'package:zayrova/data/models/order_model.dart';

class OrderRemoteDatasource {
  const OrderRemoteDatasource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<OrderModel>> getOrders({
    int? limit,
    int? skip,
  }) async {
    // TODO: Replace DummyJSON cart adaptation when a real orders API exists.
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
        .map(OrderModel.fromJson)
        .toList();
  }

  Future<OrderModel> getOrderById(int id) async {
    // TODO: Replace DummyJSON cart adaptation when a real orders API exists.
    final response = await _apiClient.get(ApiConstants.cartById(id));
    return OrderModel.fromJson(_mapFromResponse(response));
  }

  Future<List<OrderModel>> getUserOrders(int userId) async {
    // TODO: Replace DummyJSON cart adaptation when a real orders API exists.
    final response = await _apiClient.get(ApiConstants.cartsByUser(userId));
    final carts = response is Map<String, dynamic> ? response['carts'] : null;

    if (carts is! List) {
      return const [];
    }

    return carts
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
  }

  Future<OrderModel> createOrder(Map<String, dynamic> orderPayload) async {
    // TODO: Point this to a real order endpoint when the backend supports it.
    final response = await _apiClient.post(
      ApiConstants.addCart,
      body: orderPayload,
    );

    return OrderModel.fromJson(_mapFromResponse(response));
  }

  Map<String, dynamic> _mapFromResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    return const {};
  }
}
