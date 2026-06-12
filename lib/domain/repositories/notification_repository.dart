import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/domain/entities/notification_item_entity.dart';

abstract class NotificationRepository {
  Future<ApiResult<List<NotificationItem>>> getNotifications({bool? isRead});

  Future<ApiResult<NotificationItem>> markAsRead(String id);

  Future<ApiResult<List<NotificationItem>>> markAllAsRead();
}
