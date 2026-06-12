import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/notification_item_entity.dart';
import 'package:zayrova/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  Future<ApiResult<List<NotificationItem>>> call({bool? isRead}) {
    return _repository.getNotifications(isRead: isRead);
  }
}

class MarkNotificationAsReadUseCase {
  const MarkNotificationAsReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<ApiResult<NotificationItem>> call(String id) {
    return _repository.markAsRead(id);
  }
}

class MarkAllNotificationsAsReadUseCase {
  const MarkAllNotificationsAsReadUseCase(this._repository);

  final NotificationRepository _repository;

  Future<ApiResult<List<NotificationItem>>> call() {
    return _repository.markAllAsRead();
  }
}
