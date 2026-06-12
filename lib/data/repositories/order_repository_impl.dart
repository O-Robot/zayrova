import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/data/datasources/order_remote_datasource.dart';
import 'package:zayrova/data/repositories/repository_result_guard.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl(this._remoteDatasource);

  final OrderRemoteDatasource _remoteDatasource;

  @override
  Future<ApiResult<List<Order>>> getOrders({int? limit, int? skip}) {
    return guardRepositoryCall(() async {
      final orders = await _remoteDatasource.getOrders(
        limit: limit,
        skip: skip,
      );
      return orders.map((order) => order.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<Order>> getOrderById(int id) {
    return guardRepositoryCall(() async {
      final order = await _remoteDatasource.getOrderById(id);
      return order.toEntity();
    });
  }

  @override
  Future<ApiResult<Order>> createOrder(Map<String, dynamic> orderPayload) {
    return guardRepositoryCall(() async {
      final order = await _remoteDatasource.createOrder(orderPayload);
      return order.toEntity();
    });
  }

  @override
  Future<ApiResult<Order>> trackOrder(int id) {
    // Temporary implementation until the real backend exposes tracking.
    return getOrderById(id);
  }
}
