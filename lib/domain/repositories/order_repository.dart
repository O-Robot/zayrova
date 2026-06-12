import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/order_entity.dart';

abstract class OrderRepository {
  Future<ApiResult<List<Order>>> getOrders({int? limit, int? skip});

  Future<ApiResult<Order>> getOrderById(int id);

  Future<ApiResult<Order>> createOrder(Map<String, dynamic> orderPayload);

  Future<ApiResult<Order>> trackOrder(int id);
}
