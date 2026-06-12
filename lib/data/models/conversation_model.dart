import 'package:zayrova/data/models/message_model.dart';
import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/domain/entities/conversation_entity.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.title,
    required super.createdAt,
    super.participantIds,
    super.lastMessage,
    super.unreadCount,
    super.updatedAt,
    super.isClosed,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: stringValue(json['id']),
      title: stringValue(json['title'], 'Conversation'),
      participantIds: stringListValue(json['participantIds']),
      lastMessage: _messageFromJson(json['lastMessage']),
      unreadCount: intValue(json['unreadCount']),
      createdAt: dateTimeValue(json['createdAt']),
      updatedAt: nullableDateTime(json['updatedAt']),
      isClosed: boolValue(json['isClosed']),
    );
  }

  Conversation toEntity() => this;

  Map<String, dynamic> toJson() {
    final message = lastMessage;

    return {
      'id': id,
      'title': title,
      'participantIds': participantIds,
      'lastMessage': message is MessageModel ? message.toJson() : null,
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isClosed': isClosed,
    };
  }

  static MessageModel? _messageFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return MessageModel.fromJson(value);
    }

    return null;
  }
}
