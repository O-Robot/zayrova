import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/order_entity.dart';
import 'package:zayrova/domain/repositories/order_repository.dart';

class GetOrdersUseCase {
  const GetOrdersUseCase(this._repository);

  final OrderRepository _repository;

  Future<ApiResult<List<Order>>> call({int? limit, int? skip}) {
    return _repository.getOrders(limit: limit, skip: skip);
  }
}

class GetOrderByIdUseCase {
  const GetOrderByIdUseCase(this._repository);

  final OrderRepository _repository;

  Future<ApiResult<Order>> call(int id) {
    return _repository.getOrderById(id);
  }
}

class CreateOrderUseCase {
  const CreateOrderUseCase(this._repository);

  final OrderRepository _repository;

  Future<ApiResult<Order>> call(Map<String, dynamic> orderPayload) {
    return _repository.createOrder(orderPayload);
  }
}

class TrackOrderUseCase {
  const TrackOrderUseCase(this._repository);

  final OrderRepository _repository;

  Future<ApiResult<Order>> call(int id) {
    return _repository.trackOrder(id);
  }
}
