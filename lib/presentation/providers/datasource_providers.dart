import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/data/datasources/auth_remote_datasource.dart';
import 'package:zayrova/data/datasources/cart_remote_datasource.dart';
import 'package:zayrova/data/datasources/category_remote_datasource.dart';
import 'package:zayrova/data/datasources/message_remote_datasource.dart';
import 'package:zayrova/data/datasources/notification_remote_datasource.dart';
import 'package:zayrova/data/datasources/order_remote_datasource.dart';
import 'package:zayrova/data/datasources/product_remote_datasource.dart';
import 'package:zayrova/data/datasources/user_remote_datasource.dart';
import 'package:zayrova/presentation/providers/core_providers.dart';

final productRemoteDatasourceProvider = Provider<ProductRemoteDatasource>((ref) {
  return ProductRemoteDatasource(ref.watch(apiClientProvider));
});

final categoryRemoteDatasourceProvider = Provider<CategoryRemoteDatasource>((
  ref,
) {
  return CategoryRemoteDatasource(ref.watch(apiClientProvider));
});

final cartRemoteDatasourceProvider = Provider<CartRemoteDatasource>((ref) {
  return CartRemoteDatasource(ref.watch(apiClientProvider));
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasource(ref.watch(apiClientProvider));
});

final userRemoteDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  return UserRemoteDatasource(ref.watch(apiClientProvider));
});

final orderRemoteDatasourceProvider = Provider<OrderRemoteDatasource>((ref) {
  return OrderRemoteDatasource(ref.watch(apiClientProvider));
});

final notificationRemoteDatasourceProvider =
    Provider<NotificationRemoteDatasource>((ref) {
      return NotificationRemoteDatasource(ref.watch(apiClientProvider));
    });

final messageRemoteDatasourceProvider = Provider<MessageRemoteDatasource>((ref) {
  return MessageRemoteDatasource(ref.watch(apiClientProvider));
});
