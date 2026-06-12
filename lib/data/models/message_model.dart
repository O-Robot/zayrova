import 'package:zayrova/data/models/model_parse_helpers.dart';
import 'package:zayrova/domain/entities/message_entity.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderType,
    required super.body,
    required super.createdAt,
    super.status,
    super.attachmentUrls,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: stringValue(json['id']),
      conversationId: stringValue(json['conversationId']),
      senderId: stringValue(json['senderId']),
      senderType: _senderTypeFromJson(json['senderType']),
      body: stringValue(json['body'] ?? json['message'] ?? json['text']),
      status: _statusFromJson(json['status']),
      attachmentUrls: stringListValue(json['attachmentUrls']),
      createdAt: dateTimeValue(json['createdAt']),
    );
  }

  Message toEntity() => this;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderType': enumName(senderType),
      'body': body,
      'status': enumName(status),
      'attachmentUrls': attachmentUrls,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static MessageSenderType _senderTypeFromJson(dynamic value) {
    final type = stringValue(value).toLowerCase();

    switch (type) {
      case 'support':
      case 'agent':
        return MessageSenderType.support;
      case 'system':
        return MessageSenderType.system;
      default:
        return MessageSenderType.customer;
    }
  }

  static MessageStatus _statusFromJson(dynamic value) {
    final status = stringValue(value, 'sent').toLowerCase();

    switch (status) {
      case 'sending':
        return MessageStatus.sending;
      case 'delivered':
        return MessageStatus.delivered;
      case 'read':
        return MessageStatus.read;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }
}
