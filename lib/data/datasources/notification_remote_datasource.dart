import 'package:zayrova/core/services/network/api_client.dart';
import 'package:zayrova/data/models/notification_item_model.dart';

class NotificationRemoteDatasource {
  const NotificationRemoteDatasource(
    this._apiClient, {
    this.endpoint = '/notifications',
  });

  final ApiClient _apiClient;
  final String endpoint;

  Future<List<NotificationItemModel>> getNotifications({
    bool? isRead,
  }) async {
    // TODO: Wire to the real notifications endpoint when backend support exists.
    final response = await _apiClient.get(
      endpoint,
      queryParameters: {if (isRead != null) 'isRead': isRead},
    );

    return _notificationsFromResponse(response);
  }

  Future<NotificationItemModel> markAsRead(String id) async {
    // TODO: Confirm final notification read endpoint shape with the backend.
    final response = await _apiClient.put('$endpoint/$id/read');
    return NotificationItemModel.fromJson(_mapFromResponse(response));
  }

  Future<NotificationItemModel> markAsUnread(String id) async {
    // TODO: Confirm final notification unread endpoint shape with the backend.
    final response = await _apiClient.put('$endpoint/$id/unread');
    return NotificationItemModel.fromJson(_mapFromResponse(response));
  }

  List<NotificationItemModel> _notificationsFromResponse(dynamic response) {
    final source = response is Map<String, dynamic>
        ? response['notifications']
        : response;

    if (source is! List) {
      return const [];
    }

    return source
        .whereType<Map<String, dynamic>>()
        .map(NotificationItemModel.fromJson)
        .toList();
  }

  Map<String, dynamic> _mapFromResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    return const {};
  }
}
