import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/domain/entities/notification_item_entity.dart';

class NotificationItemModel extends NotificationItem {
  const NotificationItemModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    super.type,
    super.imageUrl,
    super.actionRoute,
    super.relatedId,
    super.isRead,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: stringValue(json['id']),
      title: stringValue(json['title'], 'Notification'),
      message: stringValue(json['message'] ?? json['body']),
      createdAt: dateTimeValue(json['createdAt']),
      type: _typeFromJson(json['type']),
      imageUrl: nullableString(json['imageUrl'] ?? json['image']),
      actionRoute: nullableString(json['actionRoute'] ?? json['route']),
      relatedId: nullableString(json['relatedId']),
      isRead: boolValue(json['isRead']),
    );
  }

  NotificationItem toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': enumName(type),
      'imageUrl': imageUrl,
      'actionRoute': actionRoute,
      'relatedId': relatedId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static NotificationType _typeFromJson(dynamic value) {
    final type = stringValue(value).toLowerCase();

    switch (type) {
      case 'order':
        return NotificationType.order;
      case 'promotion':
      case 'promo':
        return NotificationType.promotion;
      case 'account':
        return NotificationType.account;
      case 'system':
        return NotificationType.system;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.other;
    }
  }
}
