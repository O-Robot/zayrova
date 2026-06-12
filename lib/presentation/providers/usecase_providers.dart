import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zayrova/domain/usecases/auth_usecases.dart';
import 'package:zayrova/domain/usecases/cart_usecases.dart';
import 'package:zayrova/domain/usecases/category_usecases.dart';
import 'package:zayrova/domain/usecases/message_usecases.dart';
import 'package:zayrova/domain/usecases/notification_usecases.dart';
import 'package:zayrova/domain/usecases/order_usecases.dart';
import 'package:zayrova/domain/usecases/product_usecases.dart';
import 'package:zayrova/domain/usecases/user_usecases.dart';
import 'package:zayrova/presentation/providers/repository_providers.dart';

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.watch(productRepositoryProvider));
});

final getProductByIdUseCaseProvider = Provider<GetProductByIdUseCase>((ref) {
  return GetProductByIdUseCase(ref.watch(productRepositoryProvider));
});

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  return SearchProductsUseCase(ref.watch(productRepositoryProvider));
});

final getProductsByCategoryUseCaseProvider =
    Provider<GetProductsByCategoryUseCase>((ref) {
      return GetProductsByCategoryUseCase(ref.watch(productRepositoryProvider));
    });

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  return GetCategoriesUseCase(ref.watch(categoryRepositoryProvider));
});

final getCartsUseCaseProvider = Provider<GetCartsUseCase>((ref) {
  return GetCartsUseCase(ref.watch(cartRepositoryProvider));
});

final getCartByIdUseCaseProvider = Provider<GetCartByIdUseCase>((ref) {
  return GetCartByIdUseCase(ref.watch(cartRepositoryProvider));
});

final getUserCartUseCaseProvider = Provider<GetUserCartUseCase>((ref) {
  return GetUserCartUseCase(ref.watch(cartRepositoryProvider));
});

final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  return AddToCartUseCase(ref.watch(cartRepositoryProvider));
});

final updateCartUseCaseProvider = Provider<UpdateCartUseCase>((ref) {
  return UpdateCartUseCase(ref.watch(cartRepositoryProvider));
});

final deleteCartUseCaseProvider = Provider<DeleteCartUseCase>((ref) {
  return DeleteCartUseCase(ref.watch(cartRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getUsersUseCaseProvider = Provider<GetUsersUseCase>((ref) {
  return GetUsersUseCase(ref.watch(userRepositoryProvider));
});

final getUserByIdUseCaseProvider = Provider<GetUserByIdUseCase>((ref) {
  return GetUserByIdUseCase(ref.watch(userRepositoryProvider));
});

final getOrdersUseCaseProvider = Provider<GetOrdersUseCase>((ref) {
  return GetOrdersUseCase(ref.watch(orderRepositoryProvider));
});

final getOrderByIdUseCaseProvider = Provider<GetOrderByIdUseCase>((ref) {
  return GetOrderByIdUseCase(ref.watch(orderRepositoryProvider));
});

final createOrderUseCaseProvider = Provider<CreateOrderUseCase>((ref) {
  return CreateOrderUseCase(ref.watch(orderRepositoryProvider));
});

final trackOrderUseCaseProvider = Provider<TrackOrderUseCase>((ref) {
  return TrackOrderUseCase(ref.watch(orderRepositoryProvider));
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  return GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsReadUseCase>((ref) {
      return MarkNotificationAsReadUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final markAllNotificationsAsReadUseCaseProvider =
    Provider<MarkAllNotificationsAsReadUseCase>((ref) {
      return MarkAllNotificationsAsReadUseCase(
        ref.watch(notificationRepositoryProvider),
      );
    });

final getConversationsUseCaseProvider = Provider<GetConversationsUseCase>((
  ref,
) {
  return GetConversationsUseCase(ref.watch(messageRepositoryProvider));
});

final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  return GetMessagesUseCase(ref.watch(messageRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.watch(messageRepositoryProvider));
});
