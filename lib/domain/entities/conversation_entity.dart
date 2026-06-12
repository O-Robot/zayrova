import 'package:zayrova/domain/entities/message_entity.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    this.participantIds = const [],
    this.lastMessage,
    this.unreadCount = 0,
    this.updatedAt,
    this.isClosed = false,
  });

  final String id;
  final String title;
  final List<String> participantIds;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isClosed;

  Conversation copyWith({
    String? id,
    String? title,
    List<String>? participantIds,
    Message? lastMessage,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isClosed,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      participantIds: participantIds ?? this.participantIds,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}
