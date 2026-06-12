import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/data/repositories/auth_repository_impl.dart';
import 'package:zayrova/data/repositories/cart_repository_impl.dart';
import 'package:zayrova/data/repositories/category_repository_impl.dart';
import 'package:zayrova/data/repositories/message_repository_impl.dart';
import 'package:zayrova/data/repositories/notification_repository_impl.dart';
import 'package:zayrova/data/repositories/order_repository_impl.dart';
import 'package:zayrova/data/repositories/product_repository_impl.dart';
import 'package:zayrova/data/repositories/user_repository_impl.dart';
import 'package:zayrova/domain/repositories/auth_repository.dart';
import 'package:zayrova/domain/repositories/cart_repository.dart';
import 'package:zayrova/domain/repositories/category_repository.dart';
import 'package:zayrova/domain/repositories/message_repository.dart';
import 'package:zayrova/domain/repositories/notification_repository.dart';
import 'package:zayrova/domain/repositories/order_repository.dart';
import 'package:zayrova/domain/repositories/product_repository.dart';
import 'package:zayrova/domain/repositories/user_repository.dart';
import 'package:zayrova/presentation/providers/datasource_providers.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productRemoteDatasourceProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(categoryRemoteDatasourceProvider));
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(ref.watch(cartRemoteDatasourceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDatasourceProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.watch(userRemoteDatasourceProvider));
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(orderRemoteDatasourceProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    ref.watch(notificationRemoteDatasourceProvider),
  );
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(ref.watch(messageRemoteDatasourceProvider));
});
