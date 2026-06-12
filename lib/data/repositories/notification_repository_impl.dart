import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/data/datasources/notification_remote_datasource.dart';
import 'package:zayrova/data/repositories/repository_result_guard.dart';
import 'package:zayrova/domain/entities/notification_item_entity.dart';
import 'package:zayrova/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._remoteDatasource);

  final NotificationRemoteDatasource _remoteDatasource;

  @override
  Future<ApiResult<List<NotificationItem>>> getNotifications({bool? isRead}) {
    return guardRepositoryCall(() async {
      final notifications = await _remoteDatasource.getNotifications(
        isRead: isRead,
      );
      return notifications
          .map((notification) => notification.toEntity())
          .toList();
    });
  }

  @override
  Future<ApiResult<NotificationItem>> markAsRead(String id) {
    return guardRepositoryCall(() async {
      final notification = await _remoteDatasource.markAsRead(id);
      return notification.toEntity();
    });
  }

  @override
  Future<ApiResult<List<NotificationItem>>> markAllAsRead() {
    return guardRepositoryCall(() async {
      final unreadNotifications = await _remoteDatasource.getNotifications(
        isRead: false,
      );
      final updatedNotifications = <NotificationItem>[];

      for (final notification in unreadNotifications) {
        final updated = await _remoteDatasource.markAsRead(notification.id);
        updatedNotifications.add(updated.toEntity());
      }

      return updatedNotifications;
    });
  }
}
