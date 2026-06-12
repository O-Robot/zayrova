enum MessageSenderType { customer, support, system }

enum MessageStatus { sending, sent, delivered, read, failed }

class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderType,
    required this.body,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.attachmentUrls = const [],
  });

  final String id;
  final String conversationId;
  final String senderId;
  final MessageSenderType senderType;
  final String body;
  final MessageStatus status;
  final List<String> attachmentUrls;
  final DateTime createdAt;

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    MessageSenderType? senderType,
    String? body,
    MessageStatus? status,
    List<String>? attachmentUrls,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderType: senderType ?? this.senderType,
      body: body ?? this.body,
      status: status ?? this.status,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
