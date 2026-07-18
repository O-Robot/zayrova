import 'package:zayrova/core/exceptions/api_exceptions.dart';
import 'package:zayrova/core/services/network/api_client.dart';
import 'package:zayrova/data/models/conversation_model.dart';
import 'package:zayrova/data/models/message_model.dart';
import 'package:zayrova/domain/entities/message_entity.dart';

class MessageRemoteDatasource {
  MessageRemoteDatasource(this._apiClient, {this.endpoint = '/messages'})
    : _localMessagesByConversation = _buildSeedMessagesByConversation();

  final ApiClient _apiClient;
  final String endpoint;
  final Map<String, List<MessageModel>> _localMessagesByConversation;

  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _apiClient.get('$endpoint/conversations');
      final conversations = _conversationListFromResponse(response);
      if (conversations.isNotEmpty) {
        return conversations;
      }
    } on AppException {
      // Fall back to seeded conversations until a real messages API exists.
    }

    return _seedConversations();
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final trimmedConversationId = conversationId.trim();
    if (trimmedConversationId.isEmpty) {
      return const [];
    }

    try {
      final response = await _apiClient.get(
        '$endpoint/conversations/$trimmedConversationId/messages',
      );
      final messages = _messageListFromResponse(response);
      if (messages.isNotEmpty) {
        return messages;
      }
    } on AppException {
      // Fall back to seeded messages until a real messages API exists.
    }

    return List<MessageModel>.unmodifiable(
      _messagesForConversation(trimmedConversationId),
    );
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String body,
    List<String> attachmentUrls = const [],
  }) async {
    final trimmedConversationId = conversationId.trim();
    final trimmedBody = body.trim();

    if (trimmedConversationId.isEmpty || trimmedBody.isEmpty) {
      return _buildLocalMessage(
        conversationId: trimmedConversationId,
        body: trimmedBody,
        attachmentUrls: attachmentUrls,
      );
    }

    try {
      final response = await _apiClient.post(
        '$endpoint/conversations/$trimmedConversationId/messages',
        body: {'body': trimmedBody, 'attachmentUrls': attachmentUrls},
      );

      if (response is Map<String, dynamic>) {
        return MessageModel.fromJson(response);
      }
    } on AppException {
      // Fall back to local message creation until a real messages API exists.
    }

    final message = _buildLocalMessage(
      conversationId: trimmedConversationId,
      body: trimmedBody,
      attachmentUrls: attachmentUrls,
    );

    _localMessagesByConversation
        .putIfAbsent(trimmedConversationId, () => <MessageModel>[])
        .add(message);

    return message;
  }

  List<ConversationModel> _conversationListFromResponse(dynamic response) {
    final source =
        response is Map<String, dynamic> ? response['conversations'] : response;
    if (source is! List) {
      return const [];
    }

    return source
        .whereType<Map<String, dynamic>>()
        .map(ConversationModel.fromJson)
        .where((conversation) => conversation.id.trim().isNotEmpty)
        .toList();
  }

  List<MessageModel> _messageListFromResponse(dynamic response) {
    final source =
        response is Map<String, dynamic> ? response['messages'] : response;
    if (source is! List) {
      return const [];
    }

    return source
        .whereType<Map<String, dynamic>>()
        .map(MessageModel.fromJson)
        .where(
          (message) =>
              message.id.trim().isNotEmpty &&
              message.conversationId.trim().isNotEmpty &&
              message.body.trim().isNotEmpty,
        )
        .toList();
  }

  List<ConversationModel> _seedConversations() {
    final conversations =
        _seedConversationDefinitions.map((definition) {
          final messages = _messagesForConversation(definition.id);
          final lastMessage = messages.isEmpty ? null : messages.last;
          final updatedAt =
              lastMessage?.createdAt ??
              definition.updatedAt ??
              definition.createdAt;

          return ConversationModel(
            id: definition.id,
            title: definition.title,
            participantIds: definition.participantIds,
            lastMessage: lastMessage,
            unreadCount: definition.unreadCount,
            createdAt: definition.createdAt,
            updatedAt: updatedAt,
            isClosed: definition.isClosed,
          );
        }).toList();

    conversations.sort((a, b) {
      final left = a.updatedAt ?? a.lastMessage?.createdAt ?? a.createdAt;
      final right = b.updatedAt ?? b.lastMessage?.createdAt ?? b.createdAt;
      return right.compareTo(left);
    });

    return List<ConversationModel>.unmodifiable(conversations);
  }

  List<MessageModel> _messagesForConversation(String conversationId) {
    final messages =
        _localMessagesByConversation[conversationId] ?? const <MessageModel>[];
    final sorted = [...messages]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sorted;
  }

  MessageModel _buildLocalMessage({
    required String conversationId,
    required String body,
    required List<String> attachmentUrls,
  }) {
    final now = DateTime.now();

    return MessageModel(
      id: 'local-$conversationId-${now.microsecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: 'current-user',
      senderType: MessageSenderType.customer,
      body: body,
      createdAt: now,
      status: MessageStatus.sent,
      attachmentUrls: attachmentUrls,
    );
  }

  static Map<String, List<MessageModel>> _buildSeedMessagesByConversation() {
    final now = DateTime.now();

    return {
      'support-order-1458': [
        MessageModel(
          id: 'msg-1458-1',
          conversationId: 'support-order-1458',
          senderId: 'support-amy',
          senderType: MessageSenderType.support,
          body:
              'Hi there, your order #1458 is packed and waiting for courier pickup.',
          createdAt: now.subtract(const Duration(hours: 6, minutes: 20)),
          status: MessageStatus.read,
        ),
        MessageModel(
          id: 'msg-1458-2',
          conversationId: 'support-order-1458',
          senderId: 'current-user',
          senderType: MessageSenderType.customer,
          body: 'Thanks. Can you confirm the delivery window for today?',
          createdAt: now.subtract(const Duration(hours: 5, minutes: 52)),
          status: MessageStatus.read,
        ),
        MessageModel(
          id: 'msg-1458-3',
          conversationId: 'support-order-1458',
          senderId: 'support-amy',
          senderType: MessageSenderType.support,
          body: 'Yes, it is scheduled between 2:00 PM and 5:00 PM local time.',
          createdAt: now.subtract(const Duration(hours: 5, minutes: 45)),
          status: MessageStatus.delivered,
        ),
      ],
      'seller-headphones': [
        MessageModel(
          id: 'msg-headphones-1',
          conversationId: 'seller-headphones',
          senderId: 'seller-audiohub',
          senderType: MessageSenderType.support,
          body: 'Your color choice is reserved. We will ship it tomorrow.',
          createdAt: now.subtract(const Duration(days: 1, hours: 2)),
          status: MessageStatus.read,
        ),
        MessageModel(
          id: 'msg-headphones-2',
          conversationId: 'seller-headphones',
          senderId: 'current-user',
          senderType: MessageSenderType.customer,
          body: 'Perfect, please keep the black finish.',
          createdAt: now.subtract(
            const Duration(days: 1, hours: 1, minutes: 40),
          ),
          status: MessageStatus.read,
        ),
      ],
      'returns-wallet': [
        MessageModel(
          id: 'msg-wallet-1',
          conversationId: 'returns-wallet',
          senderId: 'system-returns',
          senderType: MessageSenderType.system,
          body:
              'Return request approved. Please drop the item off within 5 days.',
          createdAt: now.subtract(const Duration(days: 2, hours: 3)),
          status: MessageStatus.delivered,
        ),
      ],
      'support-payments': [
        MessageModel(
          id: 'msg-payments-1',
          conversationId: 'support-payments',
          senderId: 'support-jules',
          senderType: MessageSenderType.support,
          body:
              'We noticed your last payment attempt failed. You can try again from checkout.',
          createdAt: now.subtract(const Duration(days: 3, hours: 4)),
          status: MessageStatus.read,
        ),
      ],
    };
  }
}

class _SeedConversationDefinition {
  const _SeedConversationDefinition({
    required this.id,
    required this.title,
    required this.createdAt,
    this.participantIds = const [],
    this.unreadCount = 0,
    this.updatedAt,
    this.isClosed = false,
  });

  final String id;
  final String title;
  final List<String> participantIds;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isClosed;
}

final List<_SeedConversationDefinition> _seedConversationDefinitions = [
  _SeedConversationDefinition(
    id: 'support-order-1458',
    title: 'Zayrova Support',
    participantIds: ['current-user', 'support-amy'],
    unreadCount: 2,
    createdAt: DateTime(2026, 7, 16, 9, 30),
    updatedAt: DateTime(2026, 7, 18, 11, 15),
  ),
  _SeedConversationDefinition(
    id: 'seller-headphones',
    title: 'AudioHub Store',
    participantIds: ['current-user', 'seller-audiohub'],
    unreadCount: 0,
    createdAt: DateTime(2026, 7, 15, 14, 10),
    updatedAt: DateTime(2026, 7, 17, 16, 20),
  ),
  _SeedConversationDefinition(
    id: 'returns-wallet',
    title: 'Returns Center',
    participantIds: ['current-user', 'system-returns'],
    unreadCount: 1,
    createdAt: DateTime(2026, 7, 14, 10, 0),
    updatedAt: DateTime(2026, 7, 16, 18, 5),
    isClosed: true,
  ),
  _SeedConversationDefinition(
    id: 'support-payments',
    title: 'Billing Support',
    participantIds: ['current-user', 'support-jules'],
    unreadCount: 0,
    createdAt: DateTime(2026, 7, 13, 8, 45),
    updatedAt: DateTime(2026, 7, 15, 12, 0),
  ),
];
