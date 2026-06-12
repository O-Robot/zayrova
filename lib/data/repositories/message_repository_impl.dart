import 'package:zayrova/core/utils/api_result.dart';
import 'package:zayrova/data/datasources/message_remote_datasource.dart';
import 'package:zayrova/data/repositories/repository_result_guard.dart';
import 'package:zayrova/domain/entities/conversation_entity.dart';
import 'package:zayrova/domain/entities/message_entity.dart';
import 'package:zayrova/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  const MessageRepositoryImpl(this._remoteDatasource);

  final MessageRemoteDatasource _remoteDatasource;

  @override
  Future<ApiResult<List<Conversation>>> getConversations() {
    return guardRepositoryCall(() async {
      final conversations = await _remoteDatasource.getConversations();
      return conversations
          .map((conversation) => conversation.toEntity())
          .toList();
    });
  }

  @override
  Future<ApiResult<List<Message>>> getMessages(String conversationId) {
    return guardRepositoryCall(() async {
      final messages = await _remoteDatasource.getMessages(conversationId);
      return messages.map((message) => message.toEntity()).toList();
    });
  }

  @override
  Future<ApiResult<Message>> sendMessage({
    required String conversationId,
    required String body,
    List<String> attachmentUrls = const [],
  }) {
    return guardRepositoryCall(() async {
      final message = await _remoteDatasource.sendMessage(
        conversationId: conversationId,
        body: body,
        attachmentUrls: attachmentUrls,
      );
      return message.toEntity();
    });
  }
}
